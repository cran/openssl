# Generate random bytes with OpenSSL
#
# These functions interface to the OpenSSL random number generators. They
# can generate crypto secure random numbers in R.
#
#' @title Generate random bytes and numbers with OpenSSL
#' @aliases rand_num
#' @rdname rand_bytes
#' @description this set of functions generates random bytes or numbers from OpenSSL. This
#' provides a cryptographically secure alternative to R's default random number generator.
#' `rand_bytes` generates `n` random cryptographically secure bytes
#' @useDynLib openssl R_RAND_bytes
#' @param n number of random bytes or numbers to generate
#' @references OpenSSL manual: <https://docs.openssl.org/1.1.1/man3/RAND_bytes/>
#' @examples rnd <- rand_bytes(10)
#' as.numeric(rnd)
#' as.character(rnd)
#' as.logical(rawToBits(rnd))
#'
#' # bytes range from 0 to 255
#' rnd <- rand_bytes(100000)
#' hist(as.numeric(rnd), breaks=-1:255)
#'
#' # Generate random doubles between 0 and 1
#' rand_num(5)
#'
#' # Use CDF to map [0,1] into random draws from a distribution
#' x <- qnorm(rand_num(1000), mean=100, sd=15)
#' hist(x)
#'
#' y <- qbinom(rand_num(1000), size=10, prob=0.3)
#' hist(y)
#' @export
rand_bytes <- function(n = 1){
  if(!is.numeric(n)){
    stop("Please provide a numeric value for n")
  }
  .Call(R_RAND_bytes, n)
}

#' @rdname rand_bytes
#' @export
rand_num <- function(n = 1){
  # 64 bit double requires 8 bytes.
  x <- matrix(as.numeric(rand_bytes(n*8)), ncol = 8)
  as.numeric(x %*% 256^-(1:8))
}
