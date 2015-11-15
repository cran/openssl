#include <R.h>
#include <Rinternals.h>
#include "apple.h"
#include "utils.h"
#include <openssl/pem.h>
#include <openssl/bn.h>

SEXP R_cert_info(SEXP bin){
  X509 *cert = X509_new();
  const unsigned char *ptr = RAW(bin);
  bail(!!d2i_X509(&cert, &ptr, LENGTH(bin)));

  //out list
  int bufsize = 8192;
  char buf[bufsize];
  int len;
  X509_NAME *name;
  BIO *b;
  SEXP out = PROTECT(allocVector(VECSXP, 6));

  //Note: for some reason XN_FLAG_MULTILINE messes up UTF8

  //subject name
  name = X509_get_subject_name(cert);
  b = BIO_new(BIO_s_mem());
  bail(X509_NAME_print_ex(b, name, 0, XN_FLAG_ONELINE & ~ASN1_STRFLGS_ESC_MSB));
  len = BIO_read(b, buf, bufsize);
  BIO_free(b);
  SET_VECTOR_ELT(out, 0, allocVector(STRSXP, 1));
  SET_STRING_ELT(VECTOR_ELT(out, 0), 0, mkCharLenCE(buf, len, CE_UTF8));
  X509_NAME_free(name);

  //issuer name name
  name = X509_get_issuer_name(cert);
  b = BIO_new(BIO_s_mem());
  bail(X509_NAME_print_ex(b, name, 0, XN_FLAG_ONELINE & ~ASN1_STRFLGS_ESC_MSB));
  len = BIO_read(b, buf, bufsize);
  BIO_free(b);
  SET_VECTOR_ELT(out, 1, allocVector(STRSXP, 1));
  SET_STRING_ELT(VECTOR_ELT(out, 1), 0, mkCharLenCE(buf, len, CE_UTF8));
  X509_NAME_free(name);

  //sign algorithm
  OBJ_obj2txt(buf, sizeof(buf), cert->sig_alg->algorithm, 0);
  SET_VECTOR_ELT(out, 2, mkString(buf));

  //signature
  SET_VECTOR_ELT(out, 3, allocVector(RAWSXP, cert->signature->length));
  memcpy(RAW(VECTOR_ELT(out, 3)), cert->signature->data, cert->signature->length);

  //start date
  SET_VECTOR_ELT(out, 4, allocVector(STRSXP, 2));
  b = BIO_new(BIO_s_mem());
  bail(ASN1_TIME_print(b, cert->cert_info->validity->notBefore));
  len = BIO_read(b, buf, bufsize);
  BIO_free(b);
  SET_STRING_ELT(VECTOR_ELT(out, 4), 0, mkCharLen(buf, len));

  //expiration date
  b = BIO_new(BIO_s_mem());
  bail(ASN1_TIME_print(b, cert->cert_info->validity->notAfter));
  len = BIO_read(b, buf, bufsize);
  BIO_free(b);
  SET_STRING_ELT(VECTOR_ELT(out, 4), 1, mkCharLen(buf, len));

  //test for self signed
  SET_VECTOR_ELT(out, 5, ScalarLogical(X509_verify(cert, X509_get_pubkey(cert))));

  //return
  UNPROTECT(1);
  return out;
}

SEXP R_pubkey_verify_cert(SEXP cert, SEXP pubkey){
  const unsigned char *ptr = RAW(cert);
  X509 *crt = d2i_X509(NULL, &ptr, LENGTH(cert));
  bail(!!crt);
  const unsigned char *ptr2 = RAW(pubkey);
  EVP_PKEY *pkey = d2i_PUBKEY(NULL, &ptr2, LENGTH(pubkey));
  bail(!!pkey);
  int res = X509_verify(crt, pkey);
  X509_free(crt);
  EVP_PKEY_free(pkey);
  return ScalarLogical(res);
}

SEXP R_cert_verify_cert(SEXP cert, SEXP chain, SEXP bundle) {
  /* load cert */
  const unsigned char *ptr = RAW(cert);
  X509 *crt = d2i_X509(NULL, &ptr, LENGTH(cert));
  bail(!!crt);

  /* init ca bundle store */
  X509_STORE *store = X509_STORE_new();
  X509_STORE_CTX *ctx = X509_STORE_CTX_new();
  STACK_OF(X509) *sk = sk_X509_new_null();
  X509_STORE_CTX_init(ctx, store, crt, sk);

  /* add chain certs */
  for(int i = 0; i < LENGTH(chain); i++){
    ptr = RAW(VECTOR_ELT(chain, i));
    crt = d2i_X509(NULL, &ptr, LENGTH(VECTOR_ELT(chain, i)));
    bail(!!crt);
    sk_X509_push(sk, crt);
  }

  /* Add parent certs */
  for(int i = 0; i < LENGTH(bundle); i++){
    ptr = RAW(VECTOR_ELT(bundle, i));
    crt = d2i_X509(NULL, &ptr, LENGTH(VECTOR_ELT(bundle, i)));
    bail(!!crt);
    bail(X509_STORE_add_cert(store, crt));
  }

  const char *err = NULL;
  if(X509_verify_cert(ctx) < 1)
    err = X509_verify_cert_error_string(X509_STORE_CTX_get_error(ctx));

  sk_X509_free(sk);
  X509_STORE_CTX_free(ctx);
  X509_STORE_free(store);
  X509_free(crt);

  if(err)
    error("Certificate validation failed: %s", err);

  return ScalarLogical(TRUE);
}
