
# Goal of this file is to remove boilerplate from simulate_claims.R (but it's not really working rn)

# Map the name of the dist to the fxn to simulate it
frequency_simulators <- list(
  poisson = function(params, n) {
    if (is.null(params$lambda)) stop("Lambda param missing for poisson freq.")
    rpois(n, lambda = params$lambda)
  },
  binomial = function(params, n) {
    if (is.null(params$p)) stop("Probability param missing for Bin. freq.")
    if (is.null(params$trials)) stop("Trial param missing for Bin. freq.")
    rbinom(n, size = params$trials, prob = params$p)
  },
  negative_binomial = function(params, r) {
    stop("Negative binomial is not supported (yet)")
    # TODO: support it!
  },
  negative_binomial = function(params, n) {
      if (is.null(params$r) || is.null(params$p)) 
          stop("r and p are required for Negative Binomial distribution.")
      rnbinom(n, size = params$r, prob = params$p)
  }
)

simulate_frequency <- function(dist, params, n) {
  dist_lower <- gsub(" ", "_", tolower(dist))
  simulator <- frequency_simulators[[dist_lower]]
  
  if (is.null(simulator)) stop(paste("Unsupported freq. dist: ", dist))
  simulator(params, n)
}


### Severity sims!

severity_simulators <- list(
  gamma = function(params, n) {
    if (is.null(params$alpha) || is.null(params$theta))
        stop("Alpha and Theta are required for the Gamma distribution.")
    rgamma(n, shape = params$alpha, rate = params$theta)
  },
  lognormal = function(params, n) {
    if (is.null(params$mu) || is.null(params$sdlog))
      stop("Mu and sigma are required for the Lognormal distribution")
    rlnorm(n, meanlog = params$mu, sdlog = params$sdlog)
  }
)

simulate_severity <- function(dist, params, n) {
  dist_lower <- gsub(" ", "_", tolower(dist))
  simulator <- severity_simulators[[dist_lower]]
  if (is.null(simulator)) stop(paste("Unsupported sev. dist: ", dist))
  simulator(params, n)
}
