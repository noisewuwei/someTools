#include "Crypto_xchacha20_poly1305.h"
#include "sodium.h"
#include "include/sodium/randombytes.h"

Crypto_xchacha20_poly1305::Crypto_xchacha20_poly1305(const string& key):key_(key)
{

}

Crypto_xchacha20_poly1305::~Crypto_xchacha20_poly1305()
{
}

void Crypto_xchacha20_poly1305::Encrypt(const char* inputData, unsigned long long dataLen, char* outputData, unsigned long long& outLen)
{
	InitCryptor();
    sodium_crypto_aead_xchacha20poly1305_ietf_encrypt((unsigned char*)outputData+IV_LEN, &outLen, (const unsigned char*)inputData, dataLen, NULL, 0, NULL, (const unsigned char*)iv_.c_str(), (const unsigned char*)key_.c_str());
	memcpy(outputData, iv_.c_str(), IV_LEN);
	//crypto_aead_xchacha20poly1305_ietf_decrypt((unsigned char*)inputData, &dataLen, NULL, (const unsigned char*)outputData + IV_LEN, outLen, NULL, NULL, (const unsigned char*)iv_.c_str(), (const unsigned char*)key_.c_str());

	outLen += IV_LEN;
}

void Crypto_xchacha20_poly1305::Decrypt(const char* inputData, unsigned long long dataLen, char* outputData, unsigned long long& outLen)
{
	char randomIv[25] = { 0 };
	memcpy(randomIv, inputData, IV_LEN);
	iv_ = (char*)randomIv;
    sodium_crypto_aead_xchacha20poly1305_ietf_decrypt((unsigned char*)outputData, &outLen, NULL, (const unsigned char*)inputData+ IV_LEN, dataLen-IV_LEN, NULL, NULL, (const unsigned char*)iv_.c_str(), (const unsigned char*)key_.c_str());
}

void Crypto_xchacha20_poly1305::InitCryptor()
{
	unsigned char randomIv[25] = { 0 };
	randombytes_buf(randomIv, IV_LEN);
	iv_ = (char*)randomIv;
}
