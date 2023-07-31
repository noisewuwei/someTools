#ifndef _sodium_H_
#define _sodium_H_
#include "include/sodium/core.h"
#include "include/sodium/utils.h"
#include "include/sodium/crypto_aead_chacha20poly1305.h"
#include "include/sodium/crypto_aead_xchacha20poly1305.h"
static bool encryption_sodium_init()
{
	if (sodium_init() == -1)
	{
//        OutputDebugStringA("sodium_init error");
		return false;
	}
	
	return true;
}
static void sodium_sodium_increment(unsigned char* n, int nlen)
{
	return sodium_increment(n,nlen);
}
	
static int sodium_crypto_aead_chacha20poly1305_ietf_encrypt(unsigned char *c, unsigned long long *clen_p, const unsigned char *m,unsigned long long mlen,
																const unsigned char *ad, unsigned long long adlen, const unsigned char *nsec, const unsigned char *npub,const unsigned char *k)
{
	return crypto_aead_chacha20poly1305_ietf_encrypt(c,clen_p,m,mlen,ad,adlen,nsec,npub,k);
}

static int sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(unsigned char *c, unsigned long long *clen_p, const unsigned char *m,unsigned long long mlen,
																const unsigned char *ad, unsigned long long adlen, const unsigned char *nsec, const unsigned char *npub,const unsigned char *k)
{
	return crypto_aead_xchacha20poly1305_ietf_encrypt(c,clen_p,m,mlen,ad,adlen,nsec,npub,k);
}


static int sodium_crypto_aead_chacha20poly1305_ietf_decrypt(unsigned char *m, unsigned long long *mlen_p, unsigned char *nsec,const unsigned char *c,
																unsigned long long clen, const unsigned char *ad, unsigned long long adlen, const unsigned char *npub,const unsigned char *k)
{
	return crypto_aead_chacha20poly1305_ietf_decrypt(m,mlen_p,nsec,c,clen,ad,adlen,npub,k);
}

static int sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(unsigned char *m, unsigned long long *mlen_p, unsigned char *nsec,const unsigned char *c,
																unsigned long long clen, const unsigned char *ad, unsigned long long adlen, const unsigned char *npub,const unsigned char *k)
{
	return crypto_aead_xchacha20poly1305_ietf_decrypt(m,mlen_p,nsec,c,clen,ad,adlen,npub,k);
}

#endif
