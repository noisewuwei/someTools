#pragma once
#include <string>
using namespace std;
#define  IV_LEN 24
#define  KEY_LEN 16
class Crypto_xchacha20_poly1305
{
public:
	Crypto_xchacha20_poly1305(const string& key);
	~Crypto_xchacha20_poly1305();
	void Encrypt(const char* inputData, unsigned long long dataLen, char* outputData, unsigned long long& outLen);
	void Decrypt(const char* inputData, unsigned long long dataLen, char* outputData, unsigned long long& outLen);
	void InitCryptor();
private:
	std::string key_;
	std::string iv_;
};

