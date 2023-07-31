#include "YMDesktopFrame.h"


YMDesktopFrame::YMDesktopFrame(const YMDesktopSize& size, const YMPixelFormat& format, int stride, uint8_t* data):
	size_(size),
	format_(format),
	stride_(stride),
	data_(data)
{
	// Nothing
}

uint8_t* YMDesktopFrame::frameDataAtPos(const YMDesktopPoint& pos) const
{
	return frameDataAtPos(pos.x(), pos.y());
}

uint8_t* YMDesktopFrame::frameDataAtPos(int x, int y) const
{
	return frameData() + stride() * y + format_.bytesPerPixel() * x;
}

bool YMDesktopFrame::contains(int x, int y) const
{
	return (x >= 0 && x <= size_.width() && y >= 0 && y <= size_.height());
}

void YMDesktopFrame::copyPixelsFrom(const uint8_t* src_buffer, int src_stride, const YMDesktopRect& dest_rect)
{
	uint8_t* dest = frameDataAtPos(dest_rect.topLeft());
	size_t bytes_per_row = format_.bytesPerPixel() * dest_rect.width();

	for (int y = 0; y < dest_rect.height(); ++y)
	{
		memcpy(dest, src_buffer, bytes_per_row);
		src_buffer += src_stride;
		dest += stride();
	}
}

void YMDesktopFrame::copyPixelsFrom(const YMDesktopFrame& src_frame, const YMDesktopPoint& src_pos, const YMDesktopRect& dest_rect)
{
	copyPixelsFrom(src_frame.frameDataAtPos(src_pos), src_frame.stride(), dest_rect);
}

void YMDesktopFrame::copyFrameInfoFrom(const YMDesktopFrame& other)
{
	top_left_ = other.top_left_;
	updated_region_ = other.updated_region_;
	dpi_ = other.dpi_;
}

YMFrameAligned::YMFrameAligned(const YMDesktopSize& size, const YMPixelFormat& format, int stride, uint8_t* data)
	: YMDesktopFrame(size, format, stride, data)
{

}

YMFrameAligned::~YMFrameAligned()
{
#if DEBUG && __APPLE__
    printf("YMFrameAligned 析构\n");
#endif
}

std::unique_ptr<YMFrameAligned> YMFrameAligned::create(const YMDesktopSize& size, const YMPixelFormat& format, size_t alignment)
{
	int bytes_per_row = size.width() * format.bytesPerPixel();

	uint8_t* data =
		reinterpret_cast<uint8_t*>(malloc(bytes_per_row * size.height()));
	if (!data)
		return nullptr;

	return std::unique_ptr<YMFrameAligned>(new YMFrameAligned(size, format, bytes_per_row, data));
}
