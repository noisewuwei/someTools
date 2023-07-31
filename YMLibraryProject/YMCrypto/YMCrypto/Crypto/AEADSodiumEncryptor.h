#ifndef _AEADSodiumEncryptor_H_
#define _AEADSodiumEncryptor_H_
#include "AEADEncryptor.h"
#include "sodium.h"
#include "include/sodium/crypto_stream_salsa20.h"
#include "include/sodium/crypto_stream_chacha20.h"

const int CIPHER_CHACHA20IETFPOLY1305 = 1;
const int CIPHER_XCHACHA20IETFPOLY1305 = 2;


class AEADSodiumEncryptor : public AEADEncryptor
{
public:
	char* _sodiumEncSubkey;
	char* _sodiumDecSubkey;
private:
	std::map<std::string,EncryptorInfo*> _ciphers;
public:
	AEADSodiumEncryptor(char* method, char* password):AEADEncryptor(method, password)
	{
		InitEncryptorInfo(method);

		setdata();
		_sodiumEncSubkey = new char[_keyLen];
		memset(_sodiumEncSubkey, 0 , _keyLen);

		_sodiumDecSubkey = new char[_keyLen];
		memset(_sodiumDecSubkey, 0 , _keyLen);

		InitKey(password);

		
	}
	virtual ~AEADSodiumEncryptor()
	{
		if(_sodiumEncSubkey)
		{
			delete _sodiumEncSubkey;
			_sodiumEncSubkey = NULL;
		}
		if(_sodiumDecSubkey)
		{
			delete _sodiumDecSubkey;
			_sodiumDecSubkey = NULL;
		}

		std::map<std::string,EncryptorInfo*>::iterator it_begin = _ciphers.begin();
		std::map<std::string,EncryptorInfo*>::iterator it_end = _ciphers.end();
		for(;it_begin != it_end; it_begin++)
		{
			EncryptorInfo *info = it_begin->second;
            if (info != NULL) {
                delete info;
                info = NULL;
            }
		}
		_ciphers.clear();
	}
	virtual EncryptorInfo*  getCiphers(std::string method)
	{
		if(_ciphers.size() == 0)
		{
			_ciphers.insert(std::make_pair("chacha20-ietf-poly1305",new EncryptorInfo(32, 32, 12, 16, CIPHER_CHACHA20IETFPOLY1305)));
			_ciphers.insert(std::make_pair("xchacha20-ietf-poly1305",new EncryptorInfo(32, 32, 24, 16, CIPHER_XCHACHA20IETFPOLY1305)));
		}
		EncryptorInfo* encryptoinfo = NULL;
		std::map<std::string,EncryptorInfo*>::iterator it = _ciphers.find(method);
		if(it != _ciphers.end())
		{
			encryptoinfo = it->second;
		}
		return encryptoinfo;
	}
	virtual void initCipher(char* salt, bool isEncrypt, bool isUdp)
	{
		AEADEncryptor::initCipher(salt, isEncrypt, isUdp);
		DeriveSessionKey((unsigned char*)(isEncrypt ? _encryptSalt : _decryptSalt), _Masterkey,(unsigned char*)(isEncrypt ? _sodiumEncSubkey : _sodiumDecSubkey));
	}

	virtual void cipherEncrypt(const unsigned char* plaintext, unsigned int plen, unsigned char* ciphertext, unsigned int& clen)
	{
		int ret;
		unsigned long long encClen = 0;

		switch (_cipher)
		{
		case CIPHER_CHACHA20IETFPOLY1305:
			ret = sodium_crypto_aead_chacha20poly1305_ietf_encrypt(ciphertext, &encClen,plaintext, (unsigned long) plen, NULL, 0,NULL, _encNonce,(const unsigned char *)_sodiumEncSubkey);
			break;
		case CIPHER_XCHACHA20IETFPOLY1305:
			ret = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(ciphertext,&encClen,plaintext, (unsigned long)plen,	NULL, 0,NULL, _encNonce,(const unsigned char *)_sodiumEncSubkey);
			break;
		default:
                break;  //edit by youqu
//            OutputDebugStringA("not implemented");
		}
		if (ret != 0) 
		{
//            OutputDebugStringA("ret is {0}");
		}
		clen = (unsigned int)encClen;
	}

	virtual void cipherDecrypt(const unsigned char* ciphertext, unsigned int clen, unsigned char* plaintext, unsigned int& plen)
	{
		int ret;
		unsigned long long decPlen = 0;
		switch (_cipher)
		{
		case CIPHER_CHACHA20IETFPOLY1305:
			ret = sodium_crypto_aead_chacha20poly1305_ietf_decrypt(plaintext, &decPlen,NULL,ciphertext, (unsigned long)clen,NULL, 0,_decNonce, (const unsigned char *)_sodiumDecSubkey);
			break;
		case CIPHER_XCHACHA20IETFPOLY1305:
			ret = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(plaintext,&decPlen,NULL,ciphertext,(unsigned long)clen,NULL, 0,_decNonce, (const unsigned char *)_sodiumDecSubkey);
			break;
		default:
                break;  //add by youqu
//            OutputDebugStringA("dec not implemented");
		}
		if (ret != 0) 
		{
//            OutputDebugStringA("de ret is {0}");
		}
		//logger.Dump("after cipherDecrypt: plain", plaintext, (int) decPlen);
		plen = (unsigned int)decPlen;
	}

	virtual void Dispose()
	{

	}
};
#endif
