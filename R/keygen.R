#' Generate Key pair
#'
#' The `keygen` functions generate a random private key. Use `as.list(key)$pubkey`
#' to derive the corresponding public key. Use [write_pem] to save a private key
#' to a file, optionally with a password.
#'
#' @export
#' @rdname keygen
#' @name keygen
#' @useDynLib openssl R_keygen_rsa
#' @param bits bitsize of the generated RSA/DSA key
#' @param curve which NIST curve to use
#' @examples # Generate keypair
#' key <- rsa_keygen()
#' pubkey <- as.list(key)$pubkey
#'
#' # Write/read the key with a passphrase
#' write_pem(key, "id_rsa", password = "supersecret")
#' read_key("id_rsa", password = "supersecret")
#' unlink("id_rsa")
rsa_keygen <- function(bits = 2048){
  key <- .Call(R_keygen_rsa, as.integer(bits))
  structure(key, class = c("key", "rsa"))
}

#' @export
#' @rdname keygen
#' @useDynLib openssl R_keygen_dsa
dsa_keygen <- function(bits = 1024){
  key <- .Call(R_keygen_dsa, as.integer(bits))
  structure(key, class = c("key", "dsa"))
}

#' @export
#' @rdname keygen
#' @useDynLib openssl R_keygen_ecdsa
ec_keygen <- function(curve = c("P-256", "P-384", "P-521")){
  key <- .Call(R_keygen_ecdsa, match.arg(curve))
  structure(key, class = c("key", "ecdsa"))
}

#' @export
#' @rdname keygen
#' @useDynLib openssl R_keygen_x25519
x25519_keygen <- function(){
  key <- .Call(R_keygen_x25519)
  structure(key, class = c("key", "x25519"))
}

#' @export
#' @rdname keygen
#' @useDynLib openssl R_keygen_ed25519
ed25519_keygen <- function(){
  key <- .Call(R_keygen_ed25519)
  structure(key, class = c("key", "ed25519"))
}
