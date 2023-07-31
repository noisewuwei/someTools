#ifndef _AEADEncryptor_H_
#define _AEADEncryptor_H_

#include "EncryptorBase.h"
#include "ByteCircularBuffer.h"
#include "MbedTLS.h"
#include "sodium.h"
#include <random>
#include <algorithm>



class AEADEncryptor : public EncryptorBase
{
public:
    char* _udpTmpBuf;
    std::string _method;
    std::string _innerLibName;
    int _cipher;
    unsigned char* _Masterkey;
    unsigned char* _sessionKey;
    int _keyLen;
    int _saltLen;
    int _tagLen;
    int _nonceLen;

    char* _encryptSalt;
    char* _decryptSalt;

    unsigned char* _encNonce;
    unsigned char* _decNonce;

    bool _decryptSaltReceived;
    bool _encryptSaltSent;
    bool _tcpRequestSent;

    char* _info;

//    AutoDriticalSection    g_cs;
private:
    ByteCircularBuffer *_encCircularBuffer;
    ByteCircularBuffer *_decCircularBuffer;
    
public:
    AEADEncryptor(char* method, char* password):EncryptorBase(method,password)
    {
        _encNonce = NULL;
        _decNonce = NULL;
        _info = NULL;
        _Masterkey = NULL;
        _udpTmpBuf = NULL;
        _sessionKey = NULL;
        _encryptSalt = NULL;
        _decryptSalt = NULL;
        _encCircularBuffer = NULL;
        _decCircularBuffer = NULL;
        _encryptSaltSent = false;
        _tcpRequestSent = false;
        _decryptSaltReceived = false;
        SetBufferLen(ADDR_ATYP_LEN + 4 + ADDR_PORT_LEN);
    }

    virtual ~AEADEncryptor()
    {

        if(_encNonce)
        {
            delete _encNonce;
            _encNonce = NULL;
        }
        if(_decNonce)
        {
            delete _decNonce;
            _decNonce = NULL;
        }
        if(_info)
        {
            delete _info;
            _info = NULL;
        }
        if(_Masterkey)
        {
            delete _Masterkey;
            _Masterkey = NULL;
        }
        if(_udpTmpBuf)
        {
            delete _udpTmpBuf;
            _udpTmpBuf = NULL;
        }
        if(_sessionKey)
        {
            delete _sessionKey;
            _sessionKey = NULL;
        }
        if(_encryptSalt)
        {
            delete _encryptSalt;;
            _encryptSalt = NULL;
        }
        if(_decryptSalt)
        {
            delete _decryptSalt;;
            _decryptSalt = NULL;
        }
        if(_encCircularBuffer)
        {
            delete _encCircularBuffer;
            _encCircularBuffer = NULL;
        }
        if(_decCircularBuffer)
        {
            delete _decCircularBuffer;
            _decCircularBuffer = NULL;
        }
    }

    bool InitEncryptorInfo(char* method)
    {
        _method = method;
        transform(_method.begin(), _method.end(), _method.begin(), ::tolower);

        EncryptorInfo* CipherInfo = getCiphers(_method);
        if(CipherInfo == NULL)
            return false;

        _innerLibName = CipherInfo->InnerLibName;
        _cipher = CipherInfo->Type;
        if (_cipher == 0)
        {
//            OutputDebugStringA("method not found");
            return false;
        }
        _keyLen = CipherInfo->KeySize;
        _saltLen = CipherInfo->SaltSize;
        _tagLen = CipherInfo->TagSize;
        _nonceLen = CipherInfo->NonceSize;
        return true;
    }

    void setdata()
    {
        _Masterkey = NULL;
        _sessionKey = NULL;
        _encryptSalt = NULL;
        _decryptSalt = NULL;
        _encNonce = new unsigned char[_nonceLen];
        memset(_encNonce,0,_nonceLen);
        _decNonce = new unsigned char[_nonceLen];
        memset(_decNonce,0,_nonceLen);

//        _encCircularBuffer = new ByteCircularBuffer(BufferSize * 2);
//        _decCircularBuffer = new ByteCircularBuffer(BufferSize * 2);
        _udpTmpBuf = new char[65536];
        memset(_udpTmpBuf,0,65536);

        _info = new char[10];
        memset(_info,0,10);
        memcpy(_info,"ss-subkey",9);
    }
    virtual EncryptorInfo*  getCiphers(std::string method) = 0;

    void InitKey(char* password)
    {
        if (_Masterkey == NULL)
        {
            _Masterkey = new unsigned char[_keyLen];
            memset(_Masterkey,0,_keyLen);
        }
        
        if (_sessionKey == NULL)
        {
            _sessionKey = new unsigned char[_keyLen];
            memset(_sessionKey,0,_keyLen);
        }

        DeriveKey(password, _Masterkey, _keyLen);
    }

    static void DeriveKey(char* password, unsigned char* key, int keylen)
    {
        int resultlen = strlen(password) + MD5_LEN;
        unsigned char* result = new unsigned char[resultlen];
        memset(result,0,resultlen);
        int i = 0;
        unsigned char* md5sum = NULL;
        int len =  MD5_LEN;

        while (i < keylen)
        {
            if (i == 0)
            {
                md5sum = MbedTLS::MD5((unsigned char*)password,strlen(password));
            }
            else
            {
                memcpy(result,md5sum,len);
                memcpy(result + len, password,strlen(password));
                delete md5sum; md5sum = NULL;
                md5sum = MbedTLS::MD5(result,resultlen);
            }
            memcpy(key+i,md5sum,fmin(len, keylen - i));
            i += MD5_LEN;
        }
        if(md5sum != NULL)
        {
            delete md5sum; md5sum = NULL;
        }

        delete result;result = NULL;
    }

    void DeriveSessionKey(unsigned char* salt,unsigned char* masterKey, unsigned char* sessionKey)
    {

        int ret = MbedTLS::hkdf(salt, _saltLen, masterKey, _keyLen, (unsigned char*)_info, 9, sessionKey,_keyLen);
        if (ret != 0)
        {
//            OutputDebugStringA("failed to generate session key");
        }
    }

    void IncrementNonce(bool isEncrypt)
    {
//        AutoDLock lock(g_cs);
        
        sodium_sodium_increment(isEncrypt ? _encNonce : _decNonce, _nonceLen);
    }
    
    virtual void initCipher(char* salt, bool isEncrypt, bool isUdp)
    {
        if (isEncrypt) {
            if (_encryptSalt == NULL) {
                _encryptSalt = new char[_saltLen];
            }
            memset(_encryptSalt,0,_saltLen);
            memcpy(_encryptSalt,salt,_saltLen);
        } else {
            if (_decryptSalt == NULL) {
                _decryptSalt = new char[_saltLen];
            }
            memset(_decryptSalt,0,_saltLen);
            memcpy(_decryptSalt,salt,_saltLen);
        }
    }

    static int randomNumberss(int max, int min)
    {
        std::random_device rd;
        std::default_random_engine engine(rd());
        std::uniform_int_distribution<int> dis(min, max - 1);
        return dis(engine);
    }
    static void randBytes(char* buf, int length)
    {
        for(int i = 0 ; i < length; i++)
        {
            int num = randomNumberss(255,0);
            buf[i] = num;
        }
    }

    virtual void cipherEncrypt(const unsigned char* plaintext, unsigned int plen, unsigned char* ciphertext, unsigned int& clen) = 0;

    virtual void cipherDecrypt(const unsigned char* ciphertext, unsigned int clen, unsigned char* plaintext, unsigned int& plen) = 0;

    //TCP

    virtual void Encrypt(char* buf, int length, char* outbuf, int& outlength)
    {
//         int cipherOffset = 0;
        if(_encCircularBuffer == NULL)
        {
//            OutputDebugStringA("_encCircularBuffer != null");
            return ;
        }
         _encCircularBuffer->Put(buf, 0, length);
        outlength = 0;
         if (!_encryptSaltSent)
        {
            _encryptSaltSent = true;
            char* saltBytes = new char[_saltLen];
            memset(saltBytes,0,_saltLen);
            randBytes(saltBytes, _saltLen);
            initCipher(saltBytes, true, false);

            memcpy(outbuf,saltBytes,_saltLen);
            delete saltBytes;saltBytes = NULL;
            outlength = _saltLen;
         }
        if (!_tcpRequestSent)
        {
            _tcpRequestSent = true;
            int encAddrBufLength = 0;
            char* encAddrBufBytes = new char[GetBufferLen() + _tagLen * 2 + CHUNK_LEN_BYTES];
            memset(encAddrBufBytes,0,GetBufferLen() + _tagLen * 2 + CHUNK_LEN_BYTES);
            char* addrBytes = _encCircularBuffer->Get(GetBufferLen());
            ChunkEncrypt(addrBytes, GetBufferLen(), encAddrBufBytes, encAddrBufLength);

            //Debug.Assert(encAddrBufLength == AddrBufLength + tagLen * 2 + CHUNK_LEN_BYTES);
            memcpy(outbuf + outlength,encAddrBufBytes,encAddrBufLength);
            outlength += encAddrBufLength;
            delete encAddrBufBytes; encAddrBufBytes = NULL;
            delete addrBytes;addrBytes =NULL;
        }
        while (true)
        {
            unsigned int bufSize = (unsigned int)_encCircularBuffer->_size;
            if (bufSize <= 0)
                return;
            int chunklength = (int)fmin(bufSize, CHUNK_LEN_MASK);
            char* chunkBytes = _encCircularBuffer->Get(chunklength);
            int encChunkLength;
            char* encChunkBytes = new char[chunklength + _tagLen * 2 + CHUNK_LEN_BYTES];
            memset(encChunkBytes,0,chunklength + _tagLen * 2 + CHUNK_LEN_BYTES);
            ChunkEncrypt(chunkBytes, chunklength, encChunkBytes, encChunkLength);
            //Debug.Assert(encChunkLength == chunklength + _tagLen * 2 + CHUNK_LEN_BYTES);

            memcpy(outbuf + outlength,encChunkBytes, encChunkLength);
            outlength += encChunkLength;

            if (outlength + ChunkOverheadSize > BufferSize) {
//                OutputDebugStringA("enc outbuf almost full, giving up");
                return;
            }
            bufSize = (unsigned int)_encCircularBuffer->_size;

            delete encChunkBytes; encChunkBytes = NULL;
            delete chunkBytes;chunkBytes = NULL;
            if (bufSize <= 0) {
//                OutputDebugStringA("No more data to encrypt, leaving");
                return;
            }
        }
    }
    unsigned short ToUInt16(char* buf)
    {
        if(buf == NULL )
            return 0;

        unsigned short dd = *(((short*) buf));
        return dd;
    }
    virtual void Decrypt(char* buf, int length, char* outbuf, int& outlength)
    {
        //Debug.Assert(_decCircularBuffer != null, "_decCircularBuffer != null");
        int bufSize;
        outlength = 0;

        if(_decCircularBuffer == NULL)
        {
//            OutputDebugStringA("_circularBuffer != null");
            return ;
        }
        _decCircularBuffer->Put(buf, 0, length);

        if (! _decryptSaltReceived)
        {
            bufSize = _decCircularBuffer->_size;
            if (bufSize <= _saltLen) {
                return;
            }
            _decryptSaltReceived = true;
            char* salt = _decCircularBuffer->Get(_saltLen);
            initCipher(salt, false, false);
            delete salt; salt = NULL;
        }

        while (true)
        {
            bufSize = _decCircularBuffer->_size;
            if (bufSize <= 0)
            {
                return;
            }

            if (bufSize <= CHUNK_LEN_BYTES + _tagLen)
            {
                return;
            }

            char* encLenBytes = _decCircularBuffer->Peek(CHUNK_LEN_BYTES + _tagLen);
            unsigned int decChunkLenLength = 0;
            char* decChunkLenBytes = new char[CHUNK_LEN_BYTES];
            memset(decChunkLenBytes,0,CHUNK_LEN_BYTES);
            // try to dec chunk len
            cipherDecrypt((const unsigned char*)encLenBytes, CHUNK_LEN_BYTES + (unsigned int)_tagLen, (unsigned char*)decChunkLenBytes, decChunkLenLength);
            
            delete encLenBytes;encLenBytes=NULL;

            // finally we get the real chunk len
            short df = ToUInt16(decChunkLenBytes);
            delete decChunkLenBytes;decChunkLenBytes = NULL;

            unsigned short chunkLen = (unsigned short)NetworkToHostOrder(df);
            if (chunkLen > CHUNK_LEN_MASK)
            {
//                OutputDebugStringA("Invalid chunk length: {chunkLen}");
                return;
            }
            bufSize = _decCircularBuffer->_size;
            if (bufSize < CHUNK_LEN_BYTES + _tagLen + chunkLen + _tagLen)
            {
//                OutputDebugStringA("No more data to decrypt one chunk");
                return;
            }
            IncrementNonce(false);

            // we have enough data to decrypt one chunk
            // drop chunk len and its tag from buffer
            _decCircularBuffer->Skip(CHUNK_LEN_BYTES + _tagLen);
            char* encChunkBytes = _decCircularBuffer->Get(chunkLen + _tagLen);
            char* decChunkBytes = new char[chunkLen];
            memset(decChunkBytes,0,chunkLen);
            unsigned int decChunkLen = 0;
            cipherDecrypt((const unsigned char*)encChunkBytes, chunkLen + (unsigned int)_tagLen, (unsigned char*)decChunkBytes, decChunkLen);
            IncrementNonce(false);

            memcpy(outbuf+ outlength,decChunkBytes,decChunkLen);
            outlength += (int)decChunkLen;

            delete encChunkBytes;encChunkBytes =NULL;
            delete decChunkBytes; decChunkBytes = NULL;
            if (outlength + 100 > BufferSize)
            {
                return;
            }
            bufSize = _decCircularBuffer->_size;
            // check if we already done all of them
            if (bufSize <= 0)
            {
//                OutputDebugStringA("No data in _decCircularBuffer, already all done");
                return;
            }
        }

    }

    //UDP
    virtual void EncryptUDP(char* buf, int length, char* outbuf, int& outlength)
    {
        randBytes(outbuf, _saltLen);
        initCipher(outbuf, true, true);
        unsigned int olen = 0;
        //lock (_udpTmpBuf)
        {
            cipherEncrypt((const unsigned char*)buf, (unsigned int) length, (unsigned char*)outbuf + _saltLen, olen);
            //memcpy(outbuf + _saltLen,_udpTmpBuf, olen);
            outlength = (int) (_saltLen + olen);
        }
    }

    virtual void DecryptUDP(char* buf, int length, char* outbuf,int& outlength)
    {
        initCipher(buf, false, true);
        unsigned int olen = 0;
        //lock (_udpTmpBuf)
        {
            memcpy(buf + 0,buf + _saltLen, length - _saltLen);
            //Buffer.BlockCopy(buf, saltLen, buf, 0, length - saltLen);
            cipherDecrypt((const unsigned char*)buf, (unsigned int) (length - _saltLen), (unsigned char*)outbuf, olen);
            //Buffer.BlockCopy(_udpTmpBuf, 0, outbuf, 0, (int) olen);
            //memcpy(outbuf,_udpTmpBuf, olen);
            outlength = (int) olen;
        }
    }
private:
    short HostToNetworkOrder(short host)
    {
        return (short) (((host & 0xff) << 8) | ((host >> 8) & 0xff));
    }
    short NetworkToHostOrder(short host)
    {
        return (short)(((host & 0xff) << 8) | ((host >> 8) & 0xff));
    }
    static short ToInt16(char* values, int startIndex)
    {
        return 0;  //edit by youqu
    }
    void ChunkEncrypt(char* plaintext, int plainLen, char* ciphertext, int& cipherLen)
    {
        if (plainLen > CHUNK_LEN_MASK)
        {
//            OutputDebugStringA("enc chunk too big");
        }

        // encrypt len
        char* encLenBytes = new char[CHUNK_LEN_BYTES + _tagLen];
        memset(encLenBytes,0,CHUNK_LEN_BYTES + _tagLen);

        unsigned int encChunkLenLength = 0;
        unsigned short htno = (unsigned short)HostToNetworkOrder((short)plainLen);
        char* lenbuf = (char*)&htno;
        cipherEncrypt((const unsigned char*)lenbuf, CHUNK_LEN_BYTES, (unsigned char*)encLenBytes, encChunkLenLength);
        //Debug.Assert(encChunkLenLength == CHUNK_LEN_BYTES + tagLen);
        IncrementNonce(true);

        // encrypt corresponding data
        char* encBytes = new char[plainLen + _tagLen];
        memset(encBytes,0,plainLen + _tagLen);
        unsigned int encBufLength = 0;
        cipherEncrypt((const unsigned char*)plaintext, (unsigned int) plainLen, (unsigned char*)encBytes,encBufLength);
        //Debug.Assert(encBufLength == plainLen + tagLen);
        IncrementNonce(true);

        // construct outbuf
        memcpy(ciphertext,encLenBytes,encChunkLenLength);
        //Array.Copy(encLenBytes, 0, ciphertext, 0, (int) encChunkLenLength);
        memcpy(ciphertext+encChunkLenLength,encBytes,encBufLength);
        //Buffer.BlockCopy(encBytes, 0, ciphertext, (int) encChunkLenLength, (int) encBufLength);
        cipherLen = (int) (encChunkLenLength + encBufLength);

        delete encLenBytes; encLenBytes = NULL;
        delete encBytes; encBytes = NULL;
    }
};
#endif
