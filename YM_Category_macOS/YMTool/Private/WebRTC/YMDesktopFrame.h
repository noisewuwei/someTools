#pragma once
//#include "macros.h"
#include "YMDesktopRegion.h"
#include "YMPixelFormat.h"
#include <memory>

// 参考 sciter3\include\sciter-x-video-api.h 定义
typedef enum {
	COLOR_SPACE_UNKNOWN,
	COLOR_SPACE_YV12,
	COLOR_SPACE_IYUV, // a.k.a. I420  
	COLOR_SPACE_NV12,
	COLOR_SPACE_YUY2,
	COLOR_SPACE_RGB24,
	COLOR_SPACE_RGB555,
	COLOR_SPACE_RGB565,
	COLOR_SPACE_RGB32 // with alpha, sic!
} COLOR_SPACE_TYPE;

class YMDesktopFrame
{
public:
    virtual ~YMDesktopFrame() {
        printf("~YMDesktopFrame()\n");
    }

	uint8_t* frameDataAtPos(const YMDesktopPoint& pos) const;
	uint8_t* frameDataAtPos(int x, int y) const;
	uint8_t* frameData() const { return data_; }
	const YMDesktopSize& size() const { return size_; }
	const YMPixelFormat& format() const { return format_; }
	int stride() const { return stride_; }
	bool contains(int x, int y) const;

	void copyPixelsFrom(const uint8_t* src_buffer, int src_stride, const YMDesktopRect& dest_rect);
	void copyPixelsFrom(const YMDesktopFrame& src_frame, const YMDesktopPoint& src_pos, const YMDesktopRect& dest_rect);

	const YMDesktopRegion& constUpdatedRegion() const { return updated_region_; }
	YMDesktopRegion* updatedRegion() { return &updated_region_; }

	const YMDesktopPoint& topLeft() const { return top_left_; }
	void setTopLeft(const YMDesktopPoint& top_left) { top_left_ = top_left; }

	// Copies various information from |other|. Anything initialized in constructor are not copied.
	// This function is usually used when sharing a source Frame with several clients: the original
	// Frame should be kept unchanged. For example, BasiYMDesktopFrame::copyOf() and
	// SharedFrame::share().
	void copyFrameInfoFrom(const YMDesktopFrame& other);


	YMDesktopFrame(const YMDesktopSize& size, const YMPixelFormat& format, int stride, uint8_t* data);

	// Ownership of the buffers is defined by the classes that inherit from
	// this class. They must guarantee that the buffer is not deleted before
	// the frame is deleted.
	void setDpi(const YMDesktopPoint& dpi) { dpi_ = dpi; }
	const YMDesktopPoint& dpi() const { return dpi_; }

	int getColorSpace() {
		return COLOR_SPACE_RGB32;
	}
protected:
	uint8_t* const data_;

private:
	const YMDesktopSize size_;
	const YMPixelFormat format_;
	const int stride_;

	YMDesktopRegion updated_region_;
	YMDesktopPoint top_left_;
	YMDesktopPoint dpi_;
//?	DISALLOW_COPY_AND_ASSIGN(YMDesktopFrame);
};


class YMFrameAligned : public YMDesktopFrame
{
public:
	~YMFrameAligned();

	static std::unique_ptr<YMFrameAligned> create(
		const YMDesktopSize& size, const YMPixelFormat& format, size_t alignment);

private:
	YMFrameAligned(const YMDesktopSize& size, const YMPixelFormat& format, int stride, uint8_t* data);

//?	DISALLOW_COPY_AND_ASSIGN(YMFrameAligned);
};
