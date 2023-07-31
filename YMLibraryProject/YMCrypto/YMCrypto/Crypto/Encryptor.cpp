#include "Encryptor.h"
#include <string.h>
#include <random>
#include "include/mbedtls/md5.h"
#include "include/mbedtls/hkdf.h"
#include "include/sodium/crypto_aead_chacha20poly1305.h"
#include "include/sodium/crypto_aead_xchacha20poly1305.h"

#define KEY_SIZE 32
#define SALT_SIZE 32
#define MD5_LEN 16
const static unsigned char nonce[24] = { 0 };

Encryptor::Encryptor(const unsigned char* key, size_t len)
{
    memset(m_key, '\0', KEY_SIZE);
    generate_key(key, len);
}

Encryptor::~Encryptor()
{}

size_t Encryptor::Encrypt(const unsigned char *src, size_t slen, unsigned char *desc, size_t *dlen, int mode)
{
    // generate salt
    unsigned char salt[SALT_SIZE];
    memset(salt, '\0', SALT_SIZE);
    generate_salt(salt);

    // generate session
    unsigned char session[KEY_SIZE];
    memset(session, '\0', KEY_SIZE);
    if (0 != generate_session(salt, session))
        return 0;

    // add salt
    memcpy(desc, salt, SALT_SIZE);

    // encrypt
    unsigned long long olen = 0;
    int result = 0;
    if (mode == 1) {
        result = crypto_aead_chacha20poly1305_ietf_encrypt(desc + SALT_SIZE, &olen, src, slen, NULL, 0, NULL, nonce, session);
    } else if (mode == 2) {
        result = crypto_aead_xchacha20poly1305_ietf_encrypt(desc + SALT_SIZE, &olen, src, slen, NULL, 0, NULL, nonce, session);
    }
    if (0 != result)
        return 0;

    *dlen = olen + SALT_SIZE;
    return *dlen;
}

size_t Encryptor::Decrypt(const unsigned char *src, size_t slen, unsigned char *desc, size_t *dlen, int mode)
{
    // generate session
    unsigned char session[KEY_SIZE];
    memset(session, '\0', KEY_SIZE);
    if (0 != generate_session(src, session))
        return 0;

    // decrypt
    unsigned long long olen = 0;
    int result = 0;
    if (mode == 1) {
        result = crypto_aead_chacha20poly1305_ietf_decrypt(desc, &olen,  NULL, src + SALT_SIZE, slen - SALT_SIZE, NULL, 0, nonce, session);
    } else if (mode == 2) {
        result = crypto_aead_xchacha20poly1305_ietf_decrypt(desc, &olen,  NULL, src + SALT_SIZE, slen - SALT_SIZE, NULL, 0, nonce, session);
    }
    if (0 != result)
        return 0;

    *dlen = olen;
    return olen;
}

void Encryptor::generate_salt(unsigned char *salt)
{
    for (int i=0; i<32; i++) {
        std::random_device rd;
        std::default_random_engine engine(rd());
        std::uniform_int_distribution<int> dis(0, 254);
        salt[i] = dis(engine);
    }
}

void Encryptor::generate_key(const unsigned char *key, size_t len)
{
    unsigned char md5sum[MD5_LEN];
    memset(md5sum, '\0', MD5_LEN);

    // first
    mbedtls_md5_ret(key, len, md5sum);
    memcpy(m_key, md5sum, MD5_LEN);

    // second
    int resultlen = len + MD5_LEN;
    unsigned char *result = new unsigned char[resultlen];
    memset(result, '\0', resultlen);
    memcpy(result, md5sum, MD5_LEN);
    memcpy(result + MD5_LEN, key, len);
    memset(md5sum, '\0', MD5_LEN);
    mbedtls_md5_ret(result, resultlen, md5sum);
    memcpy(m_key + MD5_LEN, md5sum, MD5_LEN);

    delete [] result;
    result = NULL;
}

int Encryptor::generate_session(const unsigned char *salt, unsigned char* session)
{
    unsigned char info[] = {'s','s','-','s','u','b','k','e','y'};
    const mbedtls_md_info_t *md = mbedtls_md_info_from_type(MBEDTLS_MD_SHA1);
    return mbedtls_hkdf(md, salt, SALT_SIZE, m_key, KEY_SIZE, info, 9, session, KEY_SIZE);
}
