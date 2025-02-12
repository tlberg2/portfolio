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
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    level <- toupper(level)

    # format log
    log_entry <- paste0("[", timestamp, "] [", level, "] ", message)

    if (level %in% c("ERROR", "WARNING")) {
      message(log_entry) # Print warnings/errors to stderr
    } else {
      cat(log_entry, "\n") # Print to console
    }

    # Append log entry to log file
    write(log_entry, file = log_file, append = TRUE)
  }

  # customStop() will log the error, output a message (prefixed with "ERROR:")
  # so that VBA can catch it, and then quit appropriately.
  customStop <- function(calledFromVBA, status, error_message) {
    # Log the error
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
    return(value) # Return as character if it's not a number
  }
}

#-------------------------------
# 0. Setup - make sure we know where we are so we can log and save the data
#-------------------------------
{
  ##################### Figure out if we're coming from VBA
  # Get command-line args (excluding the script name)
  args <- commandArgs(trailingOnly = TRUE)

  # Check for VBA flag
  calledFromVBA <- "--calledFromVBA" %in% args
  args <- args[args != "--calledFromVBA"]
  #####################

  # Get this script's directory
  if (interactive()) {
    # If running in RStudio or another interactive session
    if ("rstudioapi" %in% installed.packages()) {
      library(rstudioapi)
      cur_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
    } else {
      # Use customStop here so the error is logged and output properly
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
    source(file.path(cur_dir, "enums.R"))
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

    # freq. dist. options
    freqDist <- gsub(" ", "_", tolower(args[1])) # "poisson" or "binomial" rn
    freqLambda <- sanitize_input(args[2], NULL) # for poisson
    freqProb <- sanitize_input(args[3], NULL) # for binomial: p
    freqTrials <- sanitize_input(args[4], NULL) # for binomial: num 'trials' each policy holder will encounter during the course of their policy

    # severity dist. options
    sevDist <- args[5] # e.g. "gamma"
    sevAlpha <- sanitize_input(args[6], NULL) # for gamma
    sevTheta <- sanitize_input(args[7], NULL) # for gamma
    sevMu <- sanitize_input(args[8], NULL) # for lognormal
    sevSigma <- sanitize_input(args[9], NULL) # for lognormal

    n_policies <- 500 # can add this as a param too

    # Build frequency parameters list based on distribution
    freq_params <- list()
    if (freqDist == "poisson") {
      freq_params$lambda <- freqLambda
    } else if (freqDist == "binomial") {
      freq_params$p <- freqProb
      freq_params$trials <- freqTrials
    } else if (freqDist == "negative_binomial") {
      customStop(FALSE, 1, "The negative binomial distribution is not currently supported.")
    }

    # Build severity parameters list
    sev_params <- list()
    if (tolower(sevDist) == "gamma") {
      sev_params$alpha <- sevAlpha
      sev_params$theta <- sevTheta
    } else if (tolower(sevDist) == "lognormal") {
      sev_params$mu <- sevMu
      sev_params$sdlog <- sevSigma
      # Rename sigma to sdlog
      names(sev_params)[names(sev_params) == "sigma"] <- "sdlog"
    }

    # Log the parsed arguments
    log_message(paste(
      "Parsed input parameters -",
      "Freq Dist:", freqDist, "| Lambda:", freqLambda, "| Prob:", freqProb, "| Trials:", freqTrials,
      "Sev Dist:", sevDist, "| Alpha:", sevAlpha, "| Theta:", sevTheta, "| Mu:", sevMu, "| Sigma:", sevSigma
    ), log_file, "DEBUG")
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
    set.seed(123) # For reproducibility

    # Generate the number of claims for each policy
    freq_vector <- simulate_frequency(freqDist, freq_params, n_policies)
    policy_ids <- seq_len(n_policies)

    # store each policy's claims in a list, then rbind at the end
    simulated_data_list <- vector("list", length = sum(freq_vector))
    idx <- 1

    for (i in seq_len(n_policies)) {
      n_claims <- freq_vector[i]
      if (n_claims > 0) {
        # Generate claim severities
        claim_sevs <- simulate_severity(sevDist, sev_params, n_claims)
        # Generate random claim dates
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

    # Combine all claim rows into one data frame
    simulated_data <- do.call(rbind, simulated_data_list)

    # Write the simulation results to a CSV (to be read by Excel Power Query)
    output_file <- file.path(data_dir, "claimSimResults.csv")
    write.csv(simulated_data, output_file, row.names = FALSE)

    log_message(paste("Simulation complete. Data saved to", output_file), log_file)
  },
  error = function(e) {
    log_message(list.files(cur_dir), log_file, "ERROR")
    customStop(calledFromVBA, 1, paste0("ERROR when simulating!! ", e$message))
  }
)
