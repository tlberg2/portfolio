# helper function(s)
{
  log_message <- function(message, log_file, level = "INFO") {
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    level <- toupper(level)
    
    # format log
    log_entry <- paste0("[", timestamp, "] [", level, "] ", message)
    
    # print to console
    if (level %in% c("ERROR", "WARNING")) {
      message(log_entry)  # Print warnings/errors in red (stderr)
    } else {
      cat(log_entry, "\n")  # Print normally
    }
    
    # write to log
    write(log_entry, file = log_file, append = TRUE)
  }
}

# setup
{
  # Get script directory
  if (interactive()) {
    # If running in RStudio or an interactive session
    if ("rstudioapi" %in% installed.packages()) {
      library(rstudioapi)
      cur_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
    } else {
      stop("Don't know how to get script path in interactive mode without RStudio.")
    }
  } else {
    # If running with Rscript, get the script file path from commandArgs()
    args <- commandArgs(trailingOnly = FALSE)
    script_path <- sub("^--file=", "", args[grep("^--file=", args)])
    
    if (length(script_path) == 0) {
      stop("Could not find script path (called with Rscript).")
    }
    
    cur_dir <- dirname(normalizePath(script_path))
  }

  log_file <- file.path(cur_dir, "logs", "log.log")
  # make sure the 'data' directory exists
  data_dir <- file.path(cur_dir, "data")
  if (!dir.exists(data_dir)) {
    log_message('** making the data dir', log_file)
    dir.create(data_dir, recursive = TRUE)
  }
  log_message(paste0('** cur_dir is: ', cur_dir), log_file)
}

### sim:

set.seed(123)

n_policies <- 500
policy_ids <- 1:n_policies

# For each policy, generate # of claims from Poisson
lambda <- 0.3
freq_vector <- rpois(n_policies, lambda)

# store rows in data frame
simulated_data_list <- vector("list", length = sum(freq_vector > 0))
idx <- 1

# if a policy has claims, find their severities & add them
for (i in 1:n_policies) {
  policy_id <- policy_ids[i]
  n_claims  <- freq_vector[i]

  if(n_claims > 0) {
    # Claim severities from Gamma
    claim_sevs <- rgamma(n_claims, shape = 2, scale = 1000)
    # Give each claim a date
    claim_dates <- sample(seq(as.Date("2024-01-01"),
                              as.Date("2024-12-31"), by="day"),
                          size=n_claims, replace=TRUE)
    
    # Add data row
    simulated_data_list[[idx]] <- data.frame(
      PolicyID    = policy_id,
      ClaimAmount = claim_sevs,
      ClaimDate   = claim_dates
    )
    idx <- idx + 1
  }
}

# Combine all data frames in the list
simulated_data <- do.call(rbind, simulated_data_list)

# excel pulls data from this file
filename <- file.path(data_dir, "claimSimResults.csv")

# Write to csv
write.csv(simulated_data, filename, row.names = FALSE)
log_message(paste("Data saved to", filename), log_file)
