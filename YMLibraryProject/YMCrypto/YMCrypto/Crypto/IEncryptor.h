#ifndef _IEncryptor_H_
#define _IEncryptor_H_
//#include <Windows.h>
#include <string>

class IEncryptor
{
public:
	IEncryptor()
	{
		len_ = 0;
	}
	virtual ~IEncryptor(){}

public:
	int GetBufferLen(){return len_;}
	void SetBufferLen(int len){len_ = len;}
	virtual void Encrypt(char* buf, int length, char* outbuf, int& outlength) = 0;
	virtual void Decrypt(char* buf, int length, char* outbuf, int& outlength) = 0;

	virtual void EncryptUDP(char* buf, int length, char* outbuf, int& outlength) = 0;
	virtual void DecryptUDP(char* buf, int length, char* outbuf, int& outlength) = 0;
private:
	int len_;
};
#endif
