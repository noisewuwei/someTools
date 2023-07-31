#ifndef _ByteCircularBuffer_H_
#define _ByteCircularBuffer_H_

class ByteCircularBuffer
{
public:
	char* _buffer;

	int _capacity;

	int _head;

	int _size;

	int _tail;
public:
	/// <summary>
	/// Initializes a new instance of the <see cref="ByteCircularBuffer"/> class that is empty and has the specified initial capacity.
	/// </summary>
	/// <param name="capacity">The maximum capcity of the buffer.</param>
	/// <exception cref="System.ArgumentException">Thown if the <paramref name="capacity"/> is less than zero.</exception>
	ByteCircularBuffer(int capacity)
	{
		if (capacity < 0)
		{
//            OutputDebugStringA("The buffer capacity must be greater than or equal to zero.");
			_capacity = capacity;
			_size = 0;
			_head = 0;
			_tail = 0;
			_buffer = NULL;
		}
		else
		{
			_buffer = new char[capacity];
			memset(_buffer,0,capacity);
			_capacity = capacity;
			_size = 0;
			_head = 0;
			_tail = 0;
		}

		
	}
	~ByteCircularBuffer()
	{
		if(_buffer)
		{
			delete _buffer;
			_buffer = NULL;
		}
	}

	/// <summary>
	/// Gets or sets the total number of elements the internal data structure can hold.
	/// </summary>
	/// <value>The total number of elements that the <see cref="ByteCircularBuffer"/> can contain.</value>
	/// <exception cref="System.ArgumentOutOfRangeException">Thrown if the specified new capacity is smaller than the current contents of the buffer.</exception>
	
	void Capacity(int val)
	{
		if (val != _capacity)
		{
			if (val < _size)
			{
//                OutputDebugStringA("The new capacity must be greater than or equal to the buffer size.");
				return;
			}

			char* newBuffer = new char[val];
			memset(newBuffer,0,val);
			if (_size > 0)
			{
				CopyTo(newBuffer,val);
			}
			if(_buffer)
			{
				delete _buffer;
				_buffer = NULL;
			}
			_buffer = newBuffer;

			_capacity = val;
		}
	}


	/// <summary>
	/// Gets a value indicating whether the buffer is empty.
	/// </summary>
	/// <value><c>true</c> if buffer is empty; otherwise, <c>false</c>.</value>
	bool IsEmpty(){return _size == 0;}

	/// <summary>
	/// Gets a value indicating whether the buffer is full.
	/// </summary>
	/// <value><c>true</c> if the buffer is full; otherwise, <c>false</c>.</value>
	/// <remarks>The <see cref="IsFull"/> property always returns <c>false</c> if the <see cref="AllowOverwrite"/> property is set to <c>true</c>.</remarks>
	bool IsFull(){return _size == _capacity;}


	/// <summary>
	/// Removes all items from the <see cref="ByteCircularBuffer" />.
	/// </summary>
	void Clear()
	{
		_size = 0;
		_head = 0;
		_tail = 0;
		_buffer = new char[_capacity];
	}

	/// <summary>
	/// Determines whether the <see cref="ByteCircularBuffer" /> contains a specific value.
	/// </summary>
	/// <param name="item">The object to locate in the <see cref="ByteCircularBuffer" />.</param>
	/// <returns><c>true</c> if <paramref name="item" /> is found in the <see cref="ByteCircularBuffer" />; otherwise, <c>false</c>.</returns>
	bool Contains(char item)
	{
		int bufferIndex = _head;
		bool result = false;

		for (int i = 0; i < _size; i++, bufferIndex++)
		{
			if (bufferIndex == _capacity)
			{
				bufferIndex = 0;
			}

			if (_buffer[bufferIndex] == item)
			{
				result = true;
				break;
			}
		}

		return result;
	}

	/// <summary>
	/// Copies the entire <see cref="ByteCircularBuffer"/> to a compatible one-dimensional array, starting at the beginning of the target array.
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the destination of the elements copied from <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	void CopyTo(char* arrays,int len)
	{
		CopyTo(arrays, 0,len);
	}

	/// <summary>
	/// Copies the entire <see cref="ByteCircularBuffer"/> to a compatible one-dimensional array, starting at the specified index of the target array.
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the destination of the elements copied from <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <param name="arrayIndex">The zero-based index in <paramref name="array"/> at which copying begins.</param>
	void CopyTo(char* arrays, int arrayIndex,int len)
	{
        CopyTo(_head, arrays, arrayIndex, std::min(_size, len - arrayIndex));
	}

	/// <summary>
	/// Copies a range of elements from the <see cref="ByteCircularBuffer"/> to a compatible one-dimensional array, starting at the specified index of the target array.
	/// </summary>
	/// <param name="index">The zero-based index in the source <see cref="ByteCircularBuffer"/> at which copying begins.</param>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the destination of the elements copied from <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <param name="arrayIndex">The zero-based index in <paramref name="array"/> at which copying begins.</param>
	/// <param name="count">The number of elements to copy.</param>
	void CopyTo(int index, char* arrays, int arrayIndex, int count)
	{
		if (count > _size)
		{
//            OutputDebugStringA("The read count cannot be greater than the buffer size.");
			return;
		}

		int startAnchor = index;
		int dstIndex = arrayIndex;

		while (count > 0)
		{
            int chunk = std::min(_capacity - startAnchor, count);
			memcpy(arrays+dstIndex,_buffer+startAnchor,chunk);
			//Buffer.BlockCopy(_buffer, startAnchor, array, dstIndex, chunk);
			startAnchor = (startAnchor + chunk == _capacity) ? 0 : startAnchor + chunk;
			dstIndex += chunk;
			count -= chunk;
		}
	}

	/// <summary>
	/// Removes and returns the specified number of objects from the beginning of the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="count">The number of elements to remove and return from the <see cref="ByteCircularBuffer"/>.</param>
	/// <returns>The objects that are removed from the beginning of the <see cref="ByteCircularBuffer"/>.</returns>
	char* Get(int count)
	{
		if (count <= 0) 
		{
//            OutputDebugStringA("should greater than 0");
			return NULL;
		}
		char* result = new char[count];
		memset(result,0,count);
		Get(result,0,count);

		return result;
	}

	/// <summary>
	/// Copies and removes the specified number elements from the <see cref="ByteCircularBuffer"/> to a compatible one-dimensional array, starting at the beginning of the target array. 
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the destination of the elements copied from <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <returns>The actual number of elements copied into <paramref name="array"/>.</returns>
	int Get(char* arrays)
	{
		if (arrays == NULL) 
		{
//            OutputDebugStringA("should greater than 0");
			return 0;
		}
		return Get(arrays, 0, strlen(arrays));
	}

	/// <summary>
	/// Copies and removes the specified number elements from the <see cref="ByteCircularBuffer"/> to a compatible one-dimensional array, starting at the specified index of the target array. 
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the destination of the elements copied from <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <param name="arrayIndex">The zero-based index in <paramref name="array"/> at which copying begins.</param>
	/// <param name="count">The number of elements to copy.</param>
	/// <returns>The actual number of elements copied into <paramref name="array"/>.</returns>
	int Get(char* arrays, int arrayIndex, int count)
	{
		if (arrayIndex < 0)
		{
//            OutputDebugStringA("Negative offset specified. Offsets must be positive.");
			return -1;
		}
		if (count < 0)
		{
//            OutputDebugStringA("Negative count specified. Count must be positive.");
			return -1;
		}
		if (count > _size)
		{
//            OutputDebugStringA("Ringbuffer contents insufficient for take/read operation.");
			return -1;
		}
		if (count < arrayIndex + count)
		{
//            OutputDebugStringA("Destination array too small for requested output.");
			return -1;
		}
		int bytesCopied = 0;
		int dstIndex = arrayIndex;
		while (count > 0)
		{
            int chunk = std::min(_capacity - _head, count);
			memcpy(arrays + dstIndex,_buffer + _head,chunk);
			//Buffer.BlockCopy(_buffer, this.Head, array, dstIndex, chunk);
			_head = (_head + chunk == _capacity) ? 0 : _head + chunk;
			_size = _size - chunk;
			dstIndex += chunk;
			bytesCopied += chunk;
			count -= chunk;
		}
		return bytesCopied;
	}

	/// <summary>
	/// Removes and returns the object at the beginning of the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <returns>The object that is removed from the beginning of the <see cref="ByteCircularBuffer"/>.</returns>
	/// <exception cref="System.InvalidOperationException">Thrown if the buffer is empty.</exception>
	/// <remarks>This method is similar to the <see cref="Peek()"/> method, but <c>Peek</c> does not modify the <see cref="ByteCircularBuffer"/>.</remarks>
	char Get()
	{
		if (IsEmpty())
		{
//            OutputDebugStringA("The buffer is empty.");
			return 0;
		}

		char item = _buffer[_head];
		if (++_head == _capacity)
		{
			_head = 0;
		}
		_size--;

		return item;
	}

	/// <summary>
	/// Returns the object at the beginning of the <see cref="ByteCircularBuffer"/> without removing it.
	/// </summary>
	/// <returns>The object at the beginning of the <see cref="ByteCircularBuffer"/>.</returns>
	/// <exception cref="System.InvalidOperationException">Thrown if the buffer is empty.</exception>
	char Peek()
	{
		if (IsEmpty())
		{
//            OutputDebugStringA("The buffer is empty.");
			return 0;
		}

		char item = _buffer[_head];

		return item;
	}

	/// <summary>
	/// Returns the specified number of objects from the beginning of the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="count">The number of elements to return from the <see cref="ByteCircularBuffer"/>.</param>
	/// <returns>The objects that from the beginning of the <see cref="ByteCircularBuffer"/>.</returns>
	/// <exception cref="System.InvalidOperationException">Thrown if the buffer is empty.</exception>
	char* Peek(int count)
	{
		if (IsEmpty())
		{
//            OutputDebugStringA("The buffer is empty.");
			return NULL;
		}

		char* items = new char[count];
		CopyTo(items,count);

		return items;
	}

	/// <summary>
	/// Returns the object at the end of the <see cref="ByteCircularBuffer"/> without removing it.
	/// </summary>
	/// <returns>The object at the end of the <see cref="ByteCircularBuffer"/>.</returns>
	/// <exception cref="System.InvalidOperationException">Thrown if the buffer is empty.</exception>
	char PeekLast()
	{
		int bufferIndex;

		if (IsEmpty())
		{
//            OutputDebugStringA("The buffer is empty.");
			return 0;
		}

		if (_tail == 0)
		{
			bufferIndex = _size - 1;
		}
		else
		{
			bufferIndex = _tail - 1;
		}

		char item = _buffer[bufferIndex];

		return item;
	}

	/// <summary>
	/// Copies an entire compatible one-dimensional array to the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the source of the elements copied to <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <exception cref="System.InvalidOperationException">Thrown if buffer does not have sufficient capacity to put in new items.</exception>
	/// <remarks>If <see cref="Size"/> plus the size of <paramref name="array"/> exceeds the capacity of the <see cref="ByteCircularBuffer"/> and the <see cref="AllowOverwrite"/> property is <c>true</c>, the oldest items in the <see cref="ByteCircularBuffer"/> are overwritten with <paramref name="array"/>.</remarks>
	int Put(char* arrays)
	{
		return Put(arrays, 0, strlen(arrays));
	}

	/// <summary>
	/// Copies a range of elements from a compatible one-dimensional array to the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="array">The one-dimensional <see cref="Array"/> that is the source of the elements copied to <see cref="ByteCircularBuffer"/>. The <see cref="Array"/> must have zero-based indexing.</param>
	/// <param name="arrayIndex">The zero-based index in <paramref name="array"/> at which copying begins.</param>
	/// <param name="count">The number of elements to copy.</param>
	/// <exception cref="System.InvalidOperationException">Thrown if buffer does not have sufficient capacity to put in new items.</exception>
	/// <remarks>If <see cref="Size"/> plus <paramref name="count"/> exceeds the capacity of the <see cref="ByteCircularBuffer"/> and the <see cref="AllowOverwrite"/> property is <c>true</c>, the oldest items in the <see cref="ByteCircularBuffer"/> are overwritten with <paramref name="array"/>.</remarks>
	int Put(char* arrays, int arrayIndex, int count)
	{
		if (count <= 0) 
		{
//            OutputDebugStringA("Count must be positive.");
			return -1;
		}
		if (_size + count > _capacity)
		{
//            OutputDebugStringA("The buffer does not have sufficient capacity to put new items.");
			return -1;
		}
		//int arraryslen = strlen(arrays);
// 		if ( count < arrayIndex + count)
// 		{
// 			OutputDebugStringA("Source array too small for requested input.");
// 			return -1;
// 		}
		int srcIndex = arrayIndex;
		int bytesToProcess = count;
		while (bytesToProcess > 0)
		{
            int chunk = std::min(_capacity - _tail, bytesToProcess);
			//Buffer.BlockCopy(array, srcIndex, _buffer, Tail, chunk);
			memcpy(_buffer + _tail, arrays+srcIndex,chunk);
			_tail = (_tail + chunk == _capacity) ? 0 : _tail + chunk;
			_size += chunk;
			srcIndex += chunk;
			bytesToProcess -= chunk;
		}

		return count;
	}

	/// <summary>
	/// Adds a byte to the end of the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="item">The byte to add to the <see cref="ByteCircularBuffer"/>. </param>
	/// <exception cref="System.InvalidOperationException">Thrown if buffer does not have sufficient capacity to put in new items.</exception>
	void Put(char item)
	{
		if (IsFull())
		{
//            OutputDebugStringA("The buffer does not have sufficient capacity to put new items.");
			return ;
		}

		_buffer[_tail] = item;

		_tail++;
		if (_size == _capacity)
		{
			_head++;
			if (_head >= _capacity)
			{
				_head -= _capacity;
			}
		}

		if (_tail == _capacity)
		{
			_tail = 0;
		}

		if (_size != _capacity)
		{
			_size++;
		}
	}

	/// <summary>
	/// Increments the starting index of the data buffer in the <see cref="ByteCircularBuffer"/>.
	/// </summary>
	/// <param name="count">The number of elements to increment the data buffer start index by.</param>
	void Skip(int count)
	{
		if (count < 0)
		{
//            OutputDebugStringA("Negative count specified. Count must be positive.");
			return;
		}
		if (count > _size)
		{
//            OutputDebugStringA("Ringbuffer contents insufficient for operation.");
		}

		// Modular division gives new offset position
		_head = (_head + count) % _capacity;
		_size -= count;
	}

	/// <summary>
	/// Copies the <see cref="ByteCircularBuffer"/> elements to a new array.
	/// </summary>
	/// <returns>A new array containing elements copied from the <see cref="ByteCircularBuffer"/>.</returns>
	/// <remarks>The <see cref="ByteCircularBuffer"/> is not modified. The order of the elements in the new array is the same as the order of the elements from the beginning of the <see cref="ByteCircularBuffer"/> to its end.</remarks>
	char* ToArray(int& len)
	{
		char* result = new char[_size];
		memset(result,0,_size);
		len = _size;

		CopyTo(result,len);
		return result;
	}

};
#endif
