#' @export
as.list.key <- function(x, ...){
  key <- x
  pubkey <- derive_pubkey(key)
  pk <- as.list(pubkey)
  list(
    type = pk$type,
    size = pk$size,
    pubkey = pubkey,
    data = decompose(key)
  )
}

#' @export
as.list.pubkey <- function(x, ...){
  pubkey <- x
  data <- decompose(pubkey)
  type <- ifelse(inherits(pubkey, "ed25519"), "ed25519", pubkey_type(pubkey))
  size <- pubkey_bitsize(pubkey)
  header <- switch(type,
   "rsa" = "ssh-rsa",
   "dsa" = "ssh-dss",
   "ed25519" = "ssh-ed25519",
   "x25519" = "(no-ssh)",
   "ecdsa" = paste0("ecdsa-sha2-nistp", substring(data$curve, 3)),
   stop("Unsupported keytype: ", type)
  )
  fp <- unlist(unname(fpdata(pubkey)))
  list(
    type = type,
    size = size,
    ssh = paste(header, base64_encode(fp)),
    fingerprint = fingerprint(pubkey),
    data = data
  )
}

#' @export
as.list.cert <- function(x, ..., name_format = NULL){
  cert <- x
  info <- cert_info(cert, name_format = name_format)
  info$pubkey <- cert_pubkey(cert)
  info
}
