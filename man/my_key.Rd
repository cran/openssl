% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mykey.R
\name{my_key}
\alias{my_key}
\alias{my_pubkey}
\title{Default key}
\usage{
my_key()

my_pubkey()
}
\description{
The default user key can be set in the \code{USER_KEY} variable and otherwise
is \verb{~/.ssh/id_rsa}. Note that on Windows we treat \code{~} as the windows user
home (and not the documents folder).
}
\details{
The \code{my_pubkey()} function looks for the public key by appending \code{.pub}
to the above key path. If this file does not exist, it reads the private key file
and automatically derives the corresponding pubkey. In the latter case the user
may be prompted for a passphrase if the private key is protected.
}
\examples{
# Set random RSA key as default
key <- rsa_keygen()
write_pem(key, tmp <- tempfile(), password = "")
rm(key)
Sys.setenv("USER_KEY" = tmp)

# Check the new keys
print(my_key())
print(my_pubkey())
}
