#pragma once
#include <cstdint>

class YMPixelFormat
{
public:
	YMPixelFormat() = default;
	YMPixelFormat(const YMPixelFormat& other);
	YMPixelFormat(uint8_t bits_per_pixel,
		uint16_t red_max,
		uint16_t green_max,
		uint16_t blue_max,
		uint8_t red_shift,
		uint8_t green_shift,
		uint8_t blue_shift);
    ~YMPixelFormat() = default;

	// True color (32 bits per pixel)
	// 0:7   - blue
	// 8:14  - green
	// 15:21 - red
	// 22:31 - unused
	static YMPixelFormat ARGB();
	static YMPixelFormat RGB565();
	uint8_t bitsPerPixel() const { return bits_per_pixel_; }
	uint8_t bytesPerPixel() const { return bytes_per_pixel_; }

	uint16_t redMax() const { return red_max_; }
	uint16_t greenMax() const { return green_max_; }
	uint16_t blueMax() const { return blue_max_; }

	uint8_t redShift() const { return red_shift_; }
	uint8_t greenShift() const { return green_shift_; }
	uint8_t blueShift() const { return blue_shift_; }

	bool isValid() const;
	void clear();
	bool isEqual(const YMPixelFormat& other) const;
	void set(const YMPixelFormat& other);

	YMPixelFormat& operator=(const YMPixelFormat& other);
	bool operator==(const YMPixelFormat& other) const;
	bool operator!=(const YMPixelFormat& other) const;

private:
	uint16_t red_max_ = 0;
	uint16_t green_max_ = 0;
	uint16_t blue_max_ = 0;

	uint8_t red_shift_ = 0;
	uint8_t green_shift_ = 0;
	uint8_t blue_shift_ = 0;

	uint8_t bits_per_pixel_ = 0;
	uint8_t bytes_per_pixel_ = 0;
};

