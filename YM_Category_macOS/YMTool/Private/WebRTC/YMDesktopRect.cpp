#include "YMDesktopRect.h"
#include <algorithm>
#include "stdhdrs.h"

YMDesktopRect::YMDesktopRect(const YMDesktopRect& other) :
	left_(other.left_),
	top_(other.top_),
	right_(other.right_),
	bottom_(other.bottom_)
{

}

void YMDesktopRect::setTopLeft(const YMDesktopPoint& top_left)
{
	left_ = top_left.x();
	top_ = top_left.y();
}

void YMDesktopRect::setSize(const YMDesktopSize& size)
{
	right_ = left_ + size.width();
	bottom_ = top_ + size.height();
}

bool YMDesktopRect::contains(int32_t x, int32_t y) const
{
	return (x >= left_ && x < right_ && y >= top_ && y < bottom_);
}

bool YMDesktopRect::containsRect(const YMDesktopRect& rect) const
{
	return (rect.left_ >= left_ && rect.right_ <= right_ &&
		rect.top_ >= top_  && rect.bottom_ <= bottom_);
}

void YMDesktopRect::translate(int32_t dx, int32_t dy)
{
	left_ += dx;
	right_ += dx;
	top_ += dy;
	bottom_ += dy;
}

YMDesktopRect YMDesktopRect::translated(int32_t dx, int32_t dy) const
{
	YMDesktopRect result(*this);
	result.translate(dx, dy);
	return result;
}

void YMDesktopRect::intersectWith(const YMDesktopRect& rect)
{
	left_ = (std::max)(left(), rect.left());
	top_ = (std::max)(top(), rect.top());
	right_ = (std::min)(right(), rect.right());
	bottom_ = (std::min)(bottom(), rect.bottom());

	if (isEmpty())
	{
		left_ = 0;
		top_ = 0;
		right_ = 0;
		bottom_ = 0;
	}
}

void YMDesktopRect::unionWith(const YMDesktopRect& rect)
{
	if (isEmpty())
	{
		*this = rect;
		return;
	}

	if (rect.isEmpty())
		return;

	left_ = (std::min)(left(), rect.left());
	top_ = (std::min)(top(), rect.top());
	right_ = (std::max)(right(), rect.right());
	bottom_ = (std::max)(bottom(), rect.bottom());
}

void YMDesktopRect::extend(int32_t left_offset, int32_t top_offset, int32_t right_offset, int32_t bottom_offset)
{
	left_ -= left_offset;
	top_ -= top_offset;
	right_ += right_offset;
	bottom_ += bottom_offset;
}

void YMDesktopRect::scale(double horizontal, double vertical)
{
	right_ += width() * (horizontal - 1);
	bottom_ += height() * (vertical - 1);
}

void YMDesktopRect::move(int32_t x, int32_t y)
{
	right_ += x - left_;
	bottom_ += y - top_;
	left_ = x;
	top_ = y;
}

YMDesktopRect YMDesktopRect::moved(int32_t x, int32_t y) const
{
	YMDesktopRect moved_rect(*this);
	moved_rect.move(x, y);
	return moved_rect;
}

YMDesktopRect& YMDesktopRect::operator=(const YMDesktopRect& other)
{
	left_ = other.left_;
	top_ = other.top_;
	right_ = other.right_;
	bottom_ = other.bottom_;
	return *this;
}

std::ostream& operator<<(std::ostream& stream, const YMDesktopRect& rect)
{
	return stream << "Rect("
		<< rect.left() << ' ' << rect.top() << ' '
		<< rect.right() << ' ' << rect.bottom()
		<< ')';
}

std::ostream& operator<<(std::ostream& stream, const YMDesktopPoint& point)
{
	return stream << "Point(" << point.x() << ' ' << point.y() << ')';
}

std::ostream& operator<<(std::ostream& stream, const YMDesktopSize& size)
{
	return stream << "Size(" << size.width() << ' ' << size.height() << ')';
}
