#include <Rinternals.h>
#include <openssl/opensslconf.h>
#include <openssl/opensslv.h>

#include <openssl/evp.h>
#ifdef EVP_PKEY_ED25519
#define HAS_ECX
#endif

SEXP R_openssl_config() {
  int has_ec = 1;
  #ifdef OPENSSL_NO_EC
  has_ec = 0;
  #endif
  int has_x25519 = 0;
  #ifdef HAS_ECX
  has_x25519 = 1;
  #endif
  int has_fips = 0;
  #ifdef OPENSSL_FIPS
  has_fips = 1;
  #endif
  SEXP res = PROTECT(allocVector(VECSXP, 4));
  SET_VECTOR_ELT(res, 0, mkString(OPENSSL_VERSION_TEXT));
  SET_VECTOR_ELT(res, 1, ScalarLogical(has_ec));
  SET_VECTOR_ELT(res, 2, ScalarLogical(has_x25519));
  SET_VECTOR_ELT(res, 3, ScalarLogical(has_fips));
  UNPROTECT(1);
  return res;
}
