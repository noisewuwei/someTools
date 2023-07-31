#ifndef _EncryptorFactory_H_
#define _EncryptorFactory_H_

#include "IEncryptor.h"
#include <string>
#include <map>

class EncryptorFactory
{
public:
	EncryptorFactory();
	~EncryptorFactory();

public:
	static IEncryptor*  GetEncryptor(char* method, char* password);
};
#endif
