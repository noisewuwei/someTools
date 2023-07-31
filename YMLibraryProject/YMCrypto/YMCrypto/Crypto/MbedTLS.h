#ifndef _MbedTLS_H_
#define _MbedTLS_H_

#include "include/mbedtls/md5.h"
#include "include/mbedtls/cipher.h"
#include "include/mbedtls/hkdf.h"
#define MBEDTLS_ERR_HKDF_BAD_PARAM  -0x5300  /**< Bad parameter */

class MbedTLS
{
public:
	const static int MBEDTLS_ENCRYPT = 1;
	const static int MBEDTLS_DECRYPT = 0;

	static unsigned char* MD5(unsigned char* input,int len)
	{
		unsigned char* output = new unsigned char[16];
		memset(output,0,16);
		if (mbedtls_md5_ret(input, len, output) != 0)
		{
//            OutputDebugStringA("mbedtls: MD5 failure");
			return NULL;
		}
		return output;
	}
	static int cipher_get_size_ex()
	{
		return sizeof(mbedtls_cipher_context_t);
	}
	static void cipher_init(mbedtls_cipher_context_t* ctx)
	{
		mbedtls_cipher_init(ctx);
	}
	static int cipher_setup(mbedtls_cipher_context_t *ctx, const mbedtls_cipher_info_t *cipher_info)
	{
		return mbedtls_cipher_setup(ctx,cipher_info);
	}
	static const mbedtls_cipher_info_t* cipher_info_from_string(const char* name)
	{
		return mbedtls_cipher_info_from_string(name);
	}
	static int cipher_setkey(mbedtls_cipher_context_t *ctx, const unsigned char *key,int key_bitlen, const mbedtls_operation_t operation )
	{
		return mbedtls_cipher_setkey(ctx,key,key_bitlen,operation);
	}
	static int cipher_set_iv( mbedtls_cipher_context_t *ctx,const unsigned char *iv, size_t iv_len )
	{
		return mbedtls_cipher_set_iv(ctx,iv,iv_len);
	}
	static int cipher_reset(mbedtls_cipher_context_t *ctx)
	{
		return mbedtls_cipher_reset(ctx);
	}
	static int cipher_update(mbedtls_cipher_context_t *ctx, const unsigned char *input,size_t ilen, unsigned char *output, size_t *olen)
	{
		return mbedtls_cipher_update(ctx,input,ilen,output,olen);
	}
	static void cipher_free(mbedtls_cipher_context_t *ctx)
	{
		return mbedtls_cipher_free(ctx);
	}
	/* HKDF-Extract(salt, IKM) -> PRK */
	static int dmbedtls_hkdf_extract(const mbedtls_md_info_t *md, const unsigned char *salt,int salt_len, const unsigned char *ikm, int ikm_len, unsigned char *prk)
	{
		int hash_len;
		unsigned char null_salt[MBEDTLS_MD_MAX_SIZE] = { '\0' };

		if (salt_len < 0) {
			return MBEDTLS_ERR_HKDF_BAD_PARAM;
		}

		hash_len = mbedtls_md_get_size(md);

		if (salt == NULL) {
			salt = null_salt;
			salt_len = hash_len;
		}

		return mbedtls_md_hmac(md, salt, salt_len, ikm, ikm_len, prk);
	}

	/* HKDF-Expand(PRK, info, L) -> OKM */
	static int dmbedtls_hkdf_expand(const mbedtls_md_info_t *md, const unsigned char *prk, int prk_len, const unsigned char *info, int info_len, unsigned char *okm, int okm_len)
	{
		int hash_len;
		int N;
		int T_len = 0, where = 0, i, ret;
		mbedtls_md_context_t ctx;
		unsigned char T[MBEDTLS_MD_MAX_SIZE];

		if (info_len < 0 || okm_len < 0 || okm == NULL) {
			return MBEDTLS_ERR_HKDF_BAD_PARAM;
		}

		hash_len = mbedtls_md_get_size(md);

		if (prk_len < hash_len) {
			return MBEDTLS_ERR_HKDF_BAD_PARAM;
		}

		if (info == NULL) {
			info = (const unsigned char *)"";
		}

		N = okm_len / hash_len;

		if ((okm_len % hash_len) != 0) {
			N++;
		}

		if (N > 255) {
			return MBEDTLS_ERR_HKDF_BAD_PARAM;
		}

		mbedtls_md_init(&ctx);

		if ((ret = mbedtls_md_setup(&ctx, md, 1)) != 0) {
			mbedtls_md_free(&ctx);
			return ret;
		}

		/* Section 2.3. */
		for (i = 1; i <= N; i++) {
			unsigned char c = i;

			ret = mbedtls_md_hmac_starts(&ctx, prk, prk_len) ||
				  mbedtls_md_hmac_update(&ctx, T, T_len) ||
				  mbedtls_md_hmac_update(&ctx, info, info_len) ||
				  /* The constant concatenated to the end of each T(n) is a single
					 octet. */
				  mbedtls_md_hmac_update(&ctx, &c, 1) ||
				  mbedtls_md_hmac_finish(&ctx, T);

			if (ret != 0) {
				mbedtls_md_free(&ctx);
				return ret;
			}

			memcpy(okm + where, T, (i != N) ? hash_len : (okm_len - where));
			where += hash_len;
			T_len = hash_len;
		}

		mbedtls_md_free(&ctx);

		return 0;
	}

	static int hkdf(const unsigned char* salt,int salt_len, const unsigned char* ikm, int ikm_len,const unsigned char* info, int info_len, unsigned char* okm,int okm_len)
	{
		const mbedtls_md_info_t *md = mbedtls_md_info_from_type(MBEDTLS_MD_SHA1);

		unsigned char prk[MBEDTLS_MD_MAX_SIZE];

		return dmbedtls_hkdf_extract(md, salt, salt_len, ikm, ikm_len, prk) ||dmbedtls_hkdf_expand(md, prk, mbedtls_md_get_size(md), info, info_len,okm, okm_len);
	}
	static int cipher_auth_encrypt(mbedtls_cipher_context_t *ctx,const unsigned char *iv, size_t iv_len,const unsigned char *ad, size_t ad_len,const unsigned char *input, size_t ilen,unsigned char *output, size_t *olen,unsigned char *tag, size_t tag_len )
	{
		return mbedtls_cipher_auth_encrypt(ctx,iv,iv_len,ad,ad_len,input,ilen,output,olen,tag,tag_len);
	}
	static int cipher_auth_decrypt(mbedtls_cipher_context_t *ctx,const unsigned char *iv, size_t iv_len,const unsigned char *ad, size_t ad_len,const unsigned char *input, size_t ilen,unsigned char *output, size_t *olen,const unsigned char *tag, size_t tag_len)
	{
		return mbedtls_cipher_auth_decrypt(ctx,iv,iv_len,ad,ad_len,input,ilen,output,olen,tag,tag_len);
	}
};
#endif
