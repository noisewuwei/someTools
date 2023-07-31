#pragma once
#include <cstdint>

class YMDesktopPoint
{
public:
	YMDesktopPoint() = default;
	YMDesktopPoint(int32_t x, int32_t y)
		: x_(x),y_(y)
	{
		// Nothing
	}

	YMDesktopPoint(const YMDesktopPoint& point)
		: x_(point.x_),
		y_(point.y_)
	{
		// Nothing
	}

	~YMDesktopPoint() = default;


	int32_t x() const { return x_; }
	int32_t y() const { return y_; }

	void set(int32_t x, int32_t y)
	{
		x_ = x;
		y_ = y;
	}

	YMDesktopPoint add(const YMDesktopPoint& other) const
	{
		return YMDesktopPoint(x() + other.x(), y() + other.y());
	}

	YMDesktopPoint subtract(const YMDesktopPoint& other) const
	{
		return YMDesktopPoint(x() - other.x(), y() - other.y());
	}

	bool isEqual(const YMDesktopPoint& other) const
	{
		return (x_ == other.x_ && y_ == other.y_);
	}

	void translate(int32_t x_offset, int32_t y_offset)
	{
		x_ += x_offset;
		y_ += y_offset;
	}

	void translate(const YMDesktopPoint& offset) { translate(offset.x(), offset.y()); }

	YMDesktopPoint& operator=(const YMDesktopPoint& other)
	{
		set(other.x_, other.y_);
		return *this;
	}

	bool operator!=(const YMDesktopPoint& other) const { return !isEqual(other); }
	bool operator==(const YMDesktopPoint& other) const { return isEqual(other); }

private:
	int32_t x_ = 0;
	int32_t y_ = 0;
};

