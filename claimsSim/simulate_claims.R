# simulate_claims.R

# sample cmds from commandline:
# ex: Should error out since missing lambda and using poisson: Rscript simulate_claims.R "poisson" "NULL" "0.2" "3" "gamma" "NULL" "1" "0" "1" "500"

# NOTE: vba flow expects an 'ERROR:' SUFFIX IF THERE'S AN ERROR!
# NOTE: remember, to debug just run it from the commandline
# TODO: make a 'runRScript.R' wrapper or something that handles all the setup -> can just be a router to a script -> then you can just return stuff normally here, and catch it in a try catch in that file

#-------------------------------
# 0.0 Helper functions
#-------------------------------
{
  log_message <- function(message, log_file, level = "INFO") {

    if (!dir.exists(dirname(log_file))) {
        dir.create(dirname(log_file), recursive = TRUE)
        log_message("Created the log directory.", log_file)
    }

    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    level <- toupper(level)
    log_entry <- paste0("[", timestamp, "] [", level, "] ", message)

    if (level %in% c("ERROR", "WARNING")) {
      message(log_entry) # Print warnings/errors to stderr
    } else {
      cat(log_entry, "\n") # Print to console
    }

    write(log_entry, file = log_file, append = TRUE)
  }

  # customStop() will log the error, output a message (ending with "ERROR")
  # so that VBA can catch it, and then quit appropriately.
  customStop <- function(calledFromVBA, status, error_message) {
    log_message(paste("ERROR:", error_message), log_file, "ERROR")
    # Print error message to stdout (so that AppleScript receives it) (vba looks for an 'ERROR' suffix now)
    cat(error_message, "ERROR")
    # Quit: if coming from VBA, force exit status 0 so that AppleScript doesn't
    # raise a system error; otherwise, quit with the provided status.
    if (calledFromVBA) {
      quit(status = 0)
    }
    quit(status = status)
  }
  # sanitize input values from VBA
  sanitize_input <- function(value, default = NA) {
    if (is.null(value) || value == "NULL" || value == "" || is.na(value)) {
      return(default)
    }

    num_value <- suppressWarnings(as.numeric(value))
    if (!is.na(num_value)) {
      return(num_value)
    }
    return(value)
  }

  parse_parameters <- function(args, log_file) {
    params <- list(
      freqDist = gsub(" ", "_", tolower(args[1])),
      freqLambda = sanitize_input(args[2], NULL),
      freqProb = sanitize_input(args[3], NULL),
      freqTrials = sanitize_input(args[4], NULL),

      sevDist = args[5],
      sevAlpha = sanitize_input(args[6], NULL),
      sevTheta = sanitize_input(args[7], NULL),
      sevMu = sanitize_input(args[8], NULL),
      sevSigma = sanitize_input(args[9], NULL),

      n_policies = 500 # should let users choose this
    )

    # Log the parsed arguments
    log_message(paste(
      "Parsed input parameters -",
      "Freq Dist:", params$freqDist, "| Lambda:", params$freqLambda, "| Prob:", params$freqProb, "| Trials:", params$freqTrials,
      "Sev Dist:", params$sevDist, "| Alpha:", params$sevAlpha, "| Theta:", params$sevTheta, "| Mu:", params$sevMu, "| Sigma:", params$sevSigma
    ), log_file, "DEBUG")

    return(params)
  }

  build_frequency_params <- function(freqDist, freqLambda, freqProb, freqTrials) {
    params <- list(
      # for poisson
      lambda = freqLambda,
      # for binomial
      p = freqProb,
      trials = freqTrials
    )

    return(params)
  }

  build_severity_params <- function(sevDist, sevAlpha, sevTheta, sevMu, sevSigma) {
    params <- list(
      # gamma
      alpha = sevAlpha,
      theta = sevTheta,
      # lognormal
      mu = sevMu,
      sdlog = sevSigma
    )
    return(params)
  }

  # simple simulation fxn -> sims claim frequencies then their severities
  simulate_claims <- function(n_policies, freq_vector, sevDist, sev_params) {
    policy_ids <- seq_len(n_policies)
    simulated_data_list <- vector("list", length = sum(freq_vector))
    idx <- 1

    for (i in seq_len(n_policies)) {
      n_claims <- freq_vector[i]
      if (n_claims > 0) {
        claim_sevs <- simulate_severity(sevDist, sev_params, n_claims)
        claim_dates <- sample(seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "day"),
          size = n_claims, replace = TRUE
        )

        simulated_data_list[[idx]] <- data.frame(
          PolicyID = policy_ids[i],
          ClaimAmount = claim_sevs,
          ClaimDate = claim_dates
        )
        idx <- idx + 1
      }
    }

    simulated_data <- do.call(rbind, simulated_data_list)
    return(simulated_data)
  }
}

set.seed(123)

{
  ##################### Figure out if we're coming from VBA
  # Get command-line args (excluding the script name)
  args <- commandArgs(trailingOnly = TRUE)

  # Check for VBA flag
  calledFromVBA <- "--calledFromVBA" %in% args
  args <- args[args != "--calledFromVBA"]

  # Get this script's directory
  if (interactive()) {
    # If running in RStudio or another interactive session
    if ("rstudioapi" %in% installed.packages()) {
      library(rstudioapi)
      cur_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
    } else {
      customStop(FALSE, 1, "Don't know how to get script path in interactive mode without RStudio.")
    }
  } else {
    # If running with Rscript, get the script file path from commandArgs()
    args_full <- commandArgs(trailingOnly = FALSE)
    script_path <- sub("^--file=", "", args_full[grep("^--file=", args_full)])

    if (length(script_path) == 0) {
      customStop(calledFromVBA, 1, "Could not find script path (called with Rscript).")
    }

    cur_dir <- dirname(normalizePath(script_path))
  }

  # Get log and data directories
  log_file <- file.path(cur_dir, "logs", "log.log")
  data_dir <- file.path(cur_dir, "data")
  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
    log_message("Created the data directory.", log_file)
  }
  log_message(paste0("** cur_dir is: ", cur_dir), log_file)
}

# ==============================================================================
# 1. Parse Command-Line Args (& Check for VBA Flag)
# ==============================================================================
{
  # basic input validation logic
  validateArgs <- function(args) {
    if (length(args) < 9) {
      customStop(calledFromVBA, 1, "Not enough arguments passed. Expected 9 arguments: freqDist, freqParam1, freqParam2, sevDist, sevParam1, sevParam2, nPolicies")
    }

    # Log the args for debugging
    log_message(paste("Command-line arguments:", paste(args, collapse = " ")), log_file, "DEBUG")
    if (calledFromVBA) {
      log_message("Called from VBA", log_file, "DEBUG")
    } else {
      log_message("Not called from VBA", log_file, "DEBUG")
    }
  }
  validateArgs(args)
}

#-------------------------------
# 2. Source files we'll need
#-------------------------------
tryCatch(
  {
    source(file.path(cur_dir, "simulation_functions.R"))
  },
  error = function(e) {
    log_message(list.files(cur_dir), log_file, "ERROR")
    customStop(calledFromVBA, 1, paste0("ERROR when sourcing files: ", e$message))
  }
)

#-------------------------------
# 3. Parse command-line arguments
#-------------------------------

tryCatch(
  {
    params <- parse_parameters(args, log_file)
    # # TODO: need a usage msg at the top of this script
    #
    # Here are the params that are passed in from vba (in order):
    #
    # frequency_distribution = Quote(GetValOrDflt("frequency_distribution"))
    # frequency_lambda = Quote(GetValOrDflt("frequency_lambda"))
    # frequency_prob = Quote(GetValOrDflt("frequency_prob"))
    # frequency_trials = Quote(GetValOrDflt("frequency_trials"))
    #
    # severity_distribution = Quote(GetValOrDflt("severity_distribution"))
    # severity_alpha = Quote(GetValOrDflt("severity_alpha"))
    # severity_theta = Quote(GetValOrDflt("severity_theta"))
    # severity_mu = Quote(GetValOrDflt("severity_mu"))
    # severity_sigma = Quote(GetValOrDflt("severity_sigma"))

    freq_params <- build_frequency_params(params$freqDist, params$freqLambda, params$freqProb, params$freqTrials)
    sev_params <- build_severity_params(params$sevDist, params$sevAlpha, params$sevTheta, params$sevMu, params$sevSigma)
  },
  error = function(e) {
    log_message("failed trying to parseCmdLineArgs", log_file, "ERROR")
    customStop(calledFromVBA, 1, paste0("ERROR in parseCmdLineArgs: ", e$message))
  }
)

#-------------------------------
# 4. Simulation
#-------------------------------

tryCatch(
  {
    freq_vector <- simulate_frequency(params$freqDist, freq_params, params$n_policies)
    simulated_data <- simulate_claims(params$n_policies, freq_vector, params$sevDist, sev_params)

    output_file <- file.path(data_dir, "claimSimResults.csv")
    write.csv(simulated_data, output_file, row.names = FALSE)

    log_message(paste0("Simulation complete. Output saved to", output_file), log_file)
  },
  error = function(e) {
    log_message(list.files(cur_dir), log_file, "ERROR")
    customStop(calledFromVBA, 1, paste0("ERROR when simulating!! ", e$message))
  }
)
