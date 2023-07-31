#pragma once
#include "YMDesktopPoint.h"
#include "YMDesktopSize.h"
#include <ostream>

class YMDesktopRect
{
public:
	YMDesktopRect() = default;
	YMDesktopRect(const YMDesktopRect& other);
    ~YMDesktopRect()
    {
        printf("~YMDesktopRect()\n");
    }

	static YMDesktopRect makeXYWH(int32_t x, int32_t y, int32_t width, int32_t height)
	{
		return YMDesktopRect(x, y, x + width, y + height);
	}

	static YMDesktopRect makeXYWH(const YMDesktopPoint& left_top, const YMDesktopSize& size)
	{
		return YMDesktopRect::makeXYWH(left_top.x(), left_top.y(), size.width(), size.height());
	}

	static YMDesktopRect makeWH(int32_t width, int32_t height)
	{
		return YMDesktopRect(0, 0, width, height);
	}

	static YMDesktopRect makeLTRB(int32_t left, int32_t top, int32_t right, int32_t bottom)
	{
		return YMDesktopRect(left, top, right, bottom);
	}

	static YMDesktopRect makeSize(const YMDesktopSize& size)
	{
		return YMDesktopRect(0, 0, size.width(), size.height());
	}

	int32_t left() const { return left_; }
	int32_t top() const { return top_; }
	int32_t right() const { return right_; }
	int32_t bottom() const { return bottom_; }

	int32_t x() const { return left_; }
	int32_t y() const { return top_; }
	int32_t width() const { return right_ - left_; }
	int32_t height() const { return bottom_ - top_; }

	YMDesktopPoint topLeft() const { return YMDesktopPoint(left(), top()); }
	void setTopLeft(const YMDesktopPoint& top_left);

	YMDesktopSize size() const { return YMDesktopSize(width(), height()); }
	void setSize(const YMDesktopSize& size);

	bool isEmpty() const { return left_ >= right_ || top_ >= bottom_; }

	bool isEqual(const YMDesktopRect& other) const
	{
		return left_ == other.left_  && top_ == other.top_   &&
			right_ == other.right_ && bottom_ == other.bottom_;
	}

	// Returns true if point lies within the rectangle boundaries.
	bool contains(int32_t x, int32_t y) const;

	// Returns true if |rect| lies within the boundaries of this rectangle.
	bool containsRect(const YMDesktopRect& rect) const;

	void translate(int32_t dx, int32_t dy);
	void translate(const YMDesktopPoint& pt) { translate(pt.x(), pt.y()); };

	YMDesktopRect translated(int32_t dx, int32_t dy) const;
	YMDesktopRect translated(const YMDesktopPoint& pt) const { return translated(pt.x(), pt.y()); }

	// Finds intersection with |rect|.
	void intersectWith(const YMDesktopRect& rect);

	// Extends the rectangle to cover |rect|. If |this| is empty, replaces |this|
	// with |rect|; if |rect| is empty, this function takes no effect.
	void unionWith(const YMDesktopRect& rect);

	// Enlarges current Rect by subtracting |left_offset| and |top_offset|
	// from |left_| and |top_|, and adding |right_offset| and |bottom_offset| to
	// |right_| and |bottom_|. This function does not normalize the result, so
	// |left_| and |top_| may be less than zero or larger than |right_| and
	// |bottom_|.
	void extend(int32_t left_offset, int32_t top_offset,
		int32_t right_offset, int32_t bottom_offset);

	// Scales current Rect. This function does not impact the |top_| and |left_|.
	void scale(double horizontal, double vertical);

	void move(const YMDesktopPoint& pt) { move(pt.x(), pt.y()); }
	void move(int32_t x, int32_t y);

	YMDesktopRect moved(const YMDesktopPoint& pt) const { return moved(pt.x(), pt.y()); };
	YMDesktopRect moved(int32_t x, int32_t y) const;

	YMDesktopRect& operator=(const YMDesktopRect& other);

	bool operator!=(const YMDesktopRect& other) const { return !isEqual(other); }
	bool operator==(const YMDesktopRect& other) const { return isEqual(other); }

private:
	YMDesktopRect(int32_t left, int32_t top, int32_t right, int32_t bottom)
		: left_(left),
		top_(top),
		right_(right),
		bottom_(bottom)
	{
		// Nothing
	}

	int32_t left_ = 0;
	int32_t top_ = 0;
	int32_t right_ = 0;
	int32_t bottom_ = 0;
};

std::ostream& operator<<(std::ostream& stream, const YMDesktopRect& rect);
std::ostream& operator<<(std::ostream& stream, const YMDesktopPoint& point);
std::ostream& operator<<(std::ostream& stream, const YMDesktopSize& size);
