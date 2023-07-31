#include "YMDesktopRegion.h"

YMDesktopRegion::YMDesktopRegion()
{
	miRegionInit(&m_reg, NullBox, 0);
}

YMDesktopRegion::YMDesktopRegion(const YMDesktopRect* rect)
{
	if (!rect->isEmpty()) {
		BoxRec box;
		box.x1 = rect->left();
		box.x2 = rect->right();
		box.y1 = rect->top();
		box.y2 = rect->bottom();
		miRegionInit(&m_reg, &box, 0);
	}
	else {
		miRegionInit(&m_reg, NullBox, 0);
	}
}

YMDesktopRegion::YMDesktopRegion(const YMDesktopRegion &src)
{
	miRegionInit(&m_reg, NullBox, 0);
	set(&src);
}

YMDesktopRegion::~YMDesktopRegion()
{
    printf("~YMDesktopRegion()\n");
	miRegionUninit(&m_reg);
}

void YMDesktopRegion::clear()
{
	miRegionEmpty(&m_reg);
}

void YMDesktopRegion::set(const YMDesktopRegion *src)
{
	miRegionCopy(&m_reg, (RegionPtr)&src->m_reg);
}

YMDesktopRegion & YMDesktopRegion::operator=(const YMDesktopRegion &src)
{
	set(&src);
	return *this;
}

void YMDesktopRegion::addRect(const YMDesktopRect *rect)
{
	if (!rect->isEmpty()) {
		YMDesktopRegion temp(rect);
		add(&temp);
	}
}

void YMDesktopRegion::translate(int dx, int dy)
{
	miTranslateRegion(&m_reg, dx, dy);
}

void YMDesktopRegion::add(const YMDesktopRegion *other)
{
	miUnion(&m_reg, &m_reg, (RegionPtr)&other->m_reg);
}

void YMDesktopRegion::subtract(const YMDesktopRegion *other)
{
	miSubtract(&m_reg, &m_reg, (RegionPtr)&other->m_reg);
}

void YMDesktopRegion::intersect(const YMDesktopRegion *other)
{
	miIntersect(&m_reg, &m_reg, (RegionPtr)&other->m_reg);
}

void YMDesktopRegion::intersect(const YMDesktopRect& rect)
{
	YMDesktopRegion region;
	region.addRect(&rect);
	intersect(&region);
}

void YMDesktopRegion::setRect(const YMDesktopRect& rect)
{
	clear();
	addRect(&rect);
}

void YMDesktopRegion::crop(const YMDesktopRect *rect)
{
	YMDesktopRegion temp(rect);
	intersect(&temp);
}

bool YMDesktopRegion::isEmpty() const
{
	return (miRegionNotEmpty((RegionPtr)&m_reg) == FALSE);
}

bool YMDesktopRegion::isPointInside(int x, int y) const
{
	BoxRec stubBox; // Ignore returning rect.
	return !!miPointInRegion((RegionPtr)&m_reg, x, y, &stubBox);
}

bool YMDesktopRegion::equals(const YMDesktopRegion *other) const
{
	if (this->isEmpty() && other->isEmpty()) {
		return true;
	}

	return (miRegionsEqual((RegionPtr)&m_reg,
		(RegionPtr)&other->m_reg) == TRUE);
}

void YMDesktopRegion::getRectVector(std::vector<YMDesktopRect> *dst) const
{
	dst->clear();

	const BoxRec *boxPtr = REGION_RECTS(&m_reg);
	long numRects = REGION_NUM_RECTS(&m_reg);
	dst->reserve((size_t)numRects);
	for (long i = 0; i < numRects; i++) {
		YMDesktopRect rect = YMDesktopRect::makeLTRB(boxPtr[i].x1, boxPtr[i].y1, boxPtr[i].x2, boxPtr[i].y2);
		dst->push_back(rect);
	}
}

void YMDesktopRegion::getRectList(std::list<YMDesktopRect> *dst) const
{
	dst->clear();

	const BoxRec *boxPtr = REGION_RECTS(&m_reg);
	long numRects = REGION_NUM_RECTS(&m_reg);
	for (long i = 0; i < numRects; i++) {
		YMDesktopRect rect = YMDesktopRect::makeLTRB(boxPtr[i].x1, boxPtr[i].y1, boxPtr[i].x2, boxPtr[i].y2);
		dst->push_back(rect);
	}
}

size_t YMDesktopRegion::getCount() const
{
	return REGION_NUM_RECTS(&m_reg);
}

YMDesktopRect YMDesktopRegion::getBounds() const
{
	const BoxRec *boxPtr = REGION_EXTENTS(&m_reg);
	return YMDesktopRect::makeLTRB(boxPtr->x1, boxPtr->y1, boxPtr->x2, boxPtr->y2);
}

void YMDesktopRegion::swap(YMDesktopRegion* region)
{
	YMDesktopRegion temp(*region);
	set(region);
	region->set(&temp);
}

