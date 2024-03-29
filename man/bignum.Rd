% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bignum.R
\name{bignum}
\alias{bignum}
\alias{bignum_mod_exp}
\alias{bignum_mod_inv}
\title{Big number arithmetic}
\usage{
bignum(x, hex = FALSE)

bignum_mod_exp(a, b, m)

bignum_mod_inv(a, m)
}
\arguments{
\item{x}{an integer, string (hex or dec) or raw vector}

\item{hex}{set to TRUE to parse strings as hex rather than decimal notation}

\item{a}{bignum value for \code{(a^b \%\% m)}}

\item{b}{bignum value for \code{(a^b \%\% m)}}

\item{m}{bignum value for \code{(a^b \%\% m)}}
}
\description{
Basic operations for working with large integers. The \code{bignum}
function converts a positive integer, string or raw vector into a bignum type.
All basic \link{Arithmetic} and \link{Comparison} operators such as
\code{+}, \code{-}, \code{*}, \code{^}, \code{\%\%}, \code{\%/\%}, \code{==},
\code{!=}, \code{<}, \code{<=}, \code{>} and \code{>=} are implemented for
bignum objects. The
\href{https://en.wikipedia.org/wiki/Modular_exponentiation}{Modular exponent}
(\code{a^b \%\% m}) can be calculated using \code{\link[=bignum_mod_exp]{bignum_mod_exp()}}
when \code{b} is too large for calculating \code{a^b} directly.
}
\examples{
# create a bignum
x <- bignum(123L)
y <- bignum("123456789123456789")
z <- bignum("D41D8CD98F00B204E9800998ECF8427E", hex = TRUE)

# Basic arithmetic
div <- z \%/\% y
mod <- z \%\% y
z2 <- div * y + mod
stopifnot(z2 == z)
stopifnot(div < z)
}
