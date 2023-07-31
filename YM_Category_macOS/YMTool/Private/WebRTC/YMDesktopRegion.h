#pragma once
#include "YMDesktopRect.h"
#include <list>
#include <vector>
extern "C" {
#include "YMx11region.h"
}
class YMDesktopRegion
{
public:
	YMDesktopRegion();
	YMDesktopRegion(const YMDesktopRect* rect);
	YMDesktopRegion(const YMDesktopRegion &src);
	virtual ~YMDesktopRegion();
	void clear();
	void set(const YMDesktopRegion *src);
	YMDesktopRegion & operator=(const YMDesktopRegion &src);
	void addRect(const YMDesktopRect *rect);
	void translate(int dx, int dy);
	void add(const YMDesktopRegion *other);
	void subtract(const YMDesktopRegion *other);
	void intersect(const YMDesktopRegion *other);

	// Clips the region by the |rect|.
	void intersect(const YMDesktopRect& rect);
	void setRect(const YMDesktopRect& rect);

	void crop(const YMDesktopRect *rect);
	bool isEmpty() const;
	bool isPointInside(int x, int y) const;
	bool equals(const YMDesktopRegion *other) const;
	void getRectVector(std::vector<YMDesktopRect> *dst) const;
	void getRectList(std::list<YMDesktopRect> *dst) const;
	size_t getCount() const;
	YMDesktopRect getBounds() const;
	void swap(YMDesktopRegion* region);
private:
	RegionRec m_reg;
	
};

