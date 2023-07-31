#ifndef TODESK_ENCRYPTOR_H
#define TODESK_ENCRYPTOR_H

#include <stddef.h>

class Encryptor {
public:
    Encryptor(const unsigned char* key, size_t len);
    ~Encryptor();

public:
    size_t Encrypt(const unsigned char *src, size_t slen, unsigned char *desc, size_t *dlen, int mode);
    size_t Decrypt(const unsigned char *src, size_t slen, unsigned char *desc, size_t *dlen, int mode);

private:
    void generate_salt(unsigned char *salt);
    void generate_key(const unsigned char *key, size_t len);
    int  generate_session(const unsigned char *salt, unsigned char* session);

private:
    unsigned char m_key[32];
};

#endif // TODESK_ENCRYPTOR_H
