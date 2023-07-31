#ifndef _EncryptorBase_H_
#define _EncryptorBase_H_
#include "IEncryptor.h"

const int MAX_INPUT_SIZE = 1024*1024;

#define MAX_DOMAIN_LEN = 255;
#define ATYP_IPv4 = 0x01;
#define ATYP_DOMAIN = 0x03;
#define ATYP_IPv6 = 0x04;

const int ADDR_PORT_LEN = 2;
const int ADDR_ATYP_LEN = 1;

#define MD5_LEN  16;

const int SODIUM_BLOCK_SIZE = 64;


const int RecvSize = 1024;
const int CHUNK_LEN_BYTES = 2;
const int CHUNK_LEN_MASK = 0x3FFF;
const int MaxChunkSize = CHUNK_LEN_MASK + CHUNK_LEN_BYTES + 16 * 2;
const int BufferSize = /*RecvSize + (int)MaxChunkSize + 32  max salt len */1024*1024;

const int ChunkOverheadSize = 16 * 2  + CHUNK_LEN_BYTES;

//class DriticalSection
//{
//public:
//    DriticalSection() throw()
//    {
//        memset(&m_sec, 0, sizeof(CRITICAL_SECTION));
//    }
//    ~DriticalSection()
//    {
//    }
//    HRESULT Lock() throw()
//    {
//        EnterCriticalSection(&m_sec);
//        return S_OK;
//    }
//    HRESULT Unlock() throw()
//    {
//        LeaveCriticalSection(&m_sec);
//        return S_OK;
//    }
//    HRESULT Init() throw()
//    {
//        HRESULT hRes = E_FAIL;
//        __try
//        {
//            InitializeCriticalSection(&m_sec);
//            hRes = S_OK;
//        }
//        // structured exception may be raised in low memory situations
//        __except (STATUS_NO_MEMORY == GetExceptionCode())
//        {
//            hRes = E_OUTOFMEMORY;
//        }
//        return hRes;
//    }
//
//    HRESULT Term() throw()
//    {
//        DeleteCriticalSection(&m_sec);
//        return S_OK;
//    }
//    CRITICAL_SECTION m_sec;
//};
//
//class AutoDriticalSection : public DriticalSection
//{
//public:
//    AutoDriticalSection()
//    {
//        DriticalSection::Init();
//    }
//    ~AutoDriticalSection() throw()
//    {
//        DriticalSection::Term();
//    }
//private:
//    HRESULT Init();
//    HRESULT Term();
//};
//
//class AutoDLock
//{
//public:
//    AutoDLock(AutoDriticalSection& cs) : m_cs(cs)
//    {
//        m_cs.Lock();
//    }
//
//    virtual ~AutoDLock()
//    {
//        m_cs.Unlock();
//    }
//
//private:
//    AutoDriticalSection& m_cs;
//};

class EncryptorInfo
{

public:
	// For those who make use of internal crypto method name
	// e.g. mbed TLS
	//Stream ciphers
	EncryptorInfo(std::string innerLibName, int keySize, int ivSize, int type)
	{
		this->KeySize = keySize;
		this->IvSize = ivSize;
		this->Type = type;
		this->InnerLibName = innerLibName;
	}

	EncryptorInfo(int keySize, int ivSize, int type)
	{
		this->KeySize = keySize;
		this->IvSize = ivSize;
		this->Type = type;
		this->InnerLibName = "";
	}

	//AEAD ciphers
	EncryptorInfo(std::string innerLibName, int keySize, int saltSize, int nonceSize, int tagSize, int type)
	{
		this->KeySize = keySize;
		this->SaltSize = saltSize;
		this->NonceSize = nonceSize;
		this->TagSize = tagSize;
		this->Type = type;
		this->InnerLibName = innerLibName;
	}

	EncryptorInfo(int keySize, int saltSize, int nonceSize, int tagSize, int type)
	{
		this->KeySize = keySize;
		this->SaltSize = saltSize;
		this->NonceSize = nonceSize;
		this->TagSize = tagSize;
		this->Type = type;
		this->InnerLibName = "";
	}

	EncryptorInfo& operator =(const EncryptorInfo& str)//¸³ÖµÔËËã·û
	{
		this->KeySize = str.KeySize;
		this->SaltSize = str.SaltSize;
		this->NonceSize = str.NonceSize;
		this->TagSize = str.TagSize;
		this->Type = str.Type;
		this->InnerLibName = str.InnerLibName;
		this->IvSize = str.IvSize;

		return *this;
	}
public:
	int KeySize;
	int IvSize;
	int SaltSize;
	int TagSize;
	int NonceSize;
	int Type;
	std::string InnerLibName;
};

class EncryptorBase : public IEncryptor
{
public:
	EncryptorBase()
	{
		method_ = "";
		password_ = "";
		
	}
	EncryptorBase(char* method, char* password)
	{
		method_ = method;
		password_ = password;
	}
	virtual ~EncryptorBase(){}

	virtual void Encrypt(char* buf, int length, char* outbuf, int& outlength) = 0;
	virtual void Decrypt(char* buf, int length, char* outbuf, int& outlength) = 0;

	virtual void EncryptUDP(char* buf, int length, char* outbuf, int& outlength) = 0;
	virtual void DecryptUDP(char* buf, int length, char* outbuf, int& outlength) = 0;

public:
	std::string method_;
	std::string password_;
};

#endif
