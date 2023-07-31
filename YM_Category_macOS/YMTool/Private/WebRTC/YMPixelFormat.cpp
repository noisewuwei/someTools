#include "YMPixelFormat.h"

YMPixelFormat::YMPixelFormat(const YMPixelFormat& other)
{
	set(other);
}

YMPixelFormat::YMPixelFormat(uint8_t bits_per_pixel, uint16_t red_max, uint16_t green_max, uint16_t blue_max, uint8_t red_shift, uint8_t green_shift, uint8_t blue_shift): 
	bits_per_pixel_(bits_per_pixel),
	bytes_per_pixel_(bits_per_pixel / 8),
	red_max_(red_max),
	green_max_(green_max),
	blue_max_(blue_max),
	red_shift_(red_shift),
	green_shift_(green_shift),
	blue_shift_(blue_shift)
{

}

YMPixelFormat YMPixelFormat::ARGB()
{
	return YMPixelFormat(32,   // bits per pixel
		255,  // red max
		255,  // green max
		255,  // blue max
		16,   // red shift
		8,    // green shift
		0);   // blue shift
}

YMPixelFormat YMPixelFormat::RGB565()
{
	return YMPixelFormat(16,   // bits per pixel
		31,  // red max
		63,  // green max
		31,  // blue max
		11,   // red shift
		5,    // green shift
		0);   // blue shift
}

bool YMPixelFormat::isValid() const
{
	if (bits_per_pixel_ == 0 &&
		red_max_ == 0 &&
		green_max_ == 0 &&
		blue_max_ == 0 &&
		red_shift_ == 0 &&
		green_shift_ == 0 &&
		blue_shift_ == 0)
	{
		return false;
	}

	return true;
}

void YMPixelFormat::clear()
{
	bits_per_pixel_ = 0;
	bytes_per_pixel_ = 0;

	red_max_ = 0;
	green_max_ = 0;
	blue_max_ = 0;

	red_shift_ = 0;
	green_shift_ = 0;
	blue_shift_ = 0;
}

bool YMPixelFormat::isEqual(const YMPixelFormat& other) const
{
	//DCHECK_EQ(bytes_per_pixel_, (bits_per_pixel_ / 8));
	//DCHECK_EQ(other.bytes_per_pixel_, (other.bits_per_pixel_ / 8));

	if (bits_per_pixel_ == other.bits_per_pixel_ &&
		red_max_ == other.red_max_        &&
		green_max_ == other.green_max_      &&
		blue_max_ == other.blue_max_       &&
		red_shift_ == other.red_shift_      &&
		green_shift_ == other.green_shift_    &&
		blue_shift_ == other.blue_shift_)
	{
		return true;
	}

	return false;
}

void YMPixelFormat::set(const YMPixelFormat& other)
{
	bits_per_pixel_ = other.bits_per_pixel_;
	bytes_per_pixel_ = other.bytes_per_pixel_;

	red_max_ = other.red_max_;
	green_max_ = other.green_max_;
	blue_max_ = other.blue_max_;

	red_shift_ = other.red_shift_;
	green_shift_ = other.green_shift_;
	blue_shift_ = other.blue_shift_;
}

YMPixelFormat& YMPixelFormat::operator=(const YMPixelFormat& other)
{
	set(other);
	return *this;
}

bool YMPixelFormat::operator==(const YMPixelFormat& other) const
{
	return isEqual(other);
}

bool YMPixelFormat::operator!=(const YMPixelFormat& other) const
{
	return !isEqual(other);
}
