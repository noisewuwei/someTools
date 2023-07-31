#pragma once
#include <cstdint>

class YMDesktopSize
{
public:
	YMDesktopSize() = default;

	YMDesktopSize(int32_t width, int32_t height)
		: width_(width),
		height_(height)
	{
		// Nothing
	}

	YMDesktopSize(const YMDesktopSize& other)
		: width_(other.width_),
		height_(other.height_)
	{
		// Nothing
	}

	~YMDesktopSize() = default;

	int32_t width() const { return width_; }
	int32_t height() const { return height_; }

	void set(int32_t width, int32_t height)
	{
		width_ = width;
		height_ = height;
	}

	bool isEmpty() const
	{
		return width_ <= 0 || height_ <= 0;
	}

	bool isEqual(const YMDesktopSize& other) const
	{
		return width_ == other.width_ && height_ == other.height_;
	}

	void clear()
	{
		width_ = 0;
		height_ = 0;
	}

	YMDesktopSize& operator=(const YMDesktopSize& other)
	{
		set(other.width_, other.height_);
		return *this;
	}

	bool operator!=(const YMDesktopSize& other) const { return !isEqual(other); }
	bool operator==(const YMDesktopSize& other) const { return isEqual(other); }

private:
	int32_t width_ = 0;
	int32_t height_ = 0;
};

