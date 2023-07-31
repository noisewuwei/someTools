#include "EncryptorFactory.h"
#include "AEADSodiumEncryptor.h"
EncryptorFactory::EncryptorFactory()
{
	//methodlist_.insert(std::make_pair("chacha20",0));
}
EncryptorFactory::~EncryptorFactory()
{

}

IEncryptor* EncryptorFactory::GetEncryptor(char* method, char* password)
{
	if (method == NULL || password == NULL || strlen(method) == 0 || strlen(password) == 0)
	{
		return NULL;
	}
	std::string methods = method;
// 	std::map<std::string, int>::iterator it = methodlist_.find(methods);
// 	if(it == methodlist_.end())
// 		return NULL;

	IEncryptor* result = NULL;
	if(strcmp(method,"chacha20-ietf-poly1305") == 0)
	{
		result = new AEADSodiumEncryptor(method,password);
	}
	else if(strcmp(method,"xchacha20-ietf-poly1305") == 0)
	{
		result = new AEADSodiumEncryptor(method,password);
	}
	
	return result;
}
