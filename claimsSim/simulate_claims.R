
# setup
{
  called_dir <- getwd() # dir this script was called from
  # make sure we're inside 'claimsSim', fail if we can't get there
  cur_dir <- called_dir
  if (basename(cur_dir) != "claimsSim") {
    cur_dir <- file.path(cur_dir, "claimsSim")
    # If we can't change to the claimsSim dir, fail!
    if (!dir.exists(cur_dir)) {
      stop("Please run this script from within the 'claimsSim' or 'portfolio' directories.")
    }
    setwd(cur_dir)
  }
  
  # make sure the 'data' directory exists
  data_dir <- file.path(cur_dir, "data")
  if (!dir.exists(data_dir)) {
    print('** making the data dir')
    dir.create(data_dir, recursive = TRUE)
  }
}

set.seed(123) # for reproducibility

n_policies <- 500
policy_ids <- 1:n_policies

# For each policy, generate # of claims from Poisson
lambda <- 0.3
freq_vector <- rpois(n_policies, lambda)

# store rows in a data frame
simulated_data_list <- vector("list", length = sum(freq_vector > 0))
idx <- 1

# if a policy has claims, then find their severities & add them
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

# get unique filename - Ymd_HMS
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
filename <- file.path(data_dir, paste0("claimSim_", timestamp, ".csv"))

# Write to csv
write.csv(simulated_data, filename, row.names = FALSE)
print(paste("Data saved to", filename))

# reset to dir this script was called from
setwd(called_dir)