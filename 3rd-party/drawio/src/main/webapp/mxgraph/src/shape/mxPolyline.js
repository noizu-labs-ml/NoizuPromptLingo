/**
 * Copyright (c) 2006-2026, JGraph Holdings Ltd
 * Copyright (c) 2006-2026, draw.io AG
 */
/**
 * Class: mxPolyline
 *
 * Extends <mxShape> to implement a polyline (a line with multiple points).
 * This shape is registered under <mxConstants.SHAPE_POLYLINE> in
 * <mxCellRenderer>.
 * 
 * Constructor: mxPolyline
 *
 * Constructs a new polyline shape.
 * 
 * Parameters:
 * 
 * points - Array of <mxPoints> that define the points. This is stored in
 * <mxShape.points>.
 * stroke - String that defines the stroke color. Default is 'black'. This is
 * stored in <stroke>.
 * strokewidth - Optional integer that defines the stroke width. Default is
 * 1. This is stored in <strokewidth>.
 */
function mxPolyline(points, stroke, strokewidth)
{
	mxShape.call(this);
	this.points = points;
	this.stroke = stroke;
	this.strokewidth = (strokewidth != null) ? strokewidth : 1;
};

/**
 * Extends mxShape.
 */
mxUtils.extend(mxPolyline, mxShape);

/**
 * Function: getRotation
 * 
 * Returns 0.
 */
mxPolyline.prototype.getRotation = function()
{
	return 0;
};

/**
 * Function: getShapeRotation
 * 
 * Returns 0.
 */
mxPolyline.prototype.getShapeRotation = function()
{
	return 0;
};

/**
 * Function: isPaintBoundsInverted
 * 
 * Returns false.
 */
mxPolyline.prototype.isPaintBoundsInverted = function()
{
	return false;
};

/**
 * Function: paintEdgeShape
 * 
 * Paints the line shape.
 */
mxPolyline.prototype.paintEdgeShape = function(c, pts)
{
	var prev = c.pointerEventsValue;
	c.pointerEventsValue = 'stroke';
	
	if (this.style != null && this.style[mxConstants.STYLE_BEZIER] == 1)
	{
		this.paintBezierLine(c, pts);
	}
	else if (this.style != null && this.style[mxConstants.STYLE_CURVED] == 1)
	{
		this.paintCurvedLine(c, pts);
	}
	else
	{
		this.paintLine(c, pts, this.isRounded);
	}
	
	c.pointerEventsValue = prev;
};

/**
 * Function: paintLine
 * 
 * Paints the line shape.
 */
mxPolyline.prototype.paintLine = function(c, pts, rounded)
{
	var arcSize = mxUtils.getValue(this.style, mxConstants.STYLE_ARCSIZE, mxConstants.LINE_ARCSIZE) / 2;
	c.begin();
	this.addPoints(c, pts, rounded, arcSize, false);
	c.stroke();
};

/**
 * Function: paintCurvedLine
 * 
 * Paints a curved line.
 */
mxPolyline.prototype.paintCurvedLine = function(c, pts)
{
	c.begin();
	
	var pt = pts[0];
	var n = pts.length;
	
	c.moveTo(pt.x, pt.y);
	
	for (var i = 1; i < n - 2; i++)
	{
		var p0 = pts[i];
		var p1 = pts[i + 1];
		var ix = (p0.x + p1.x) / 2;
		var iy = (p0.y + p1.y) / 2;
		
		c.quadTo(p0.x, p0.y, ix, iy);
	}
	
	var p0 = pts[n - 2];
	var p1 = pts[n - 1];
	
	c.quadTo(p0.x, p0.y, p1.x, p1.y);
	c.stroke();
};

/**
 * Function: paintBezierLine
 * 
 * Paints a cubic bezier curve using the points directly as control points.
 * 
 * Points are interpreted as: [anchor0, cp1, cp2, anchor1, cp3, cp4, anchor2, ...]
 * - Point 0: Start anchor (moveTo)
 * - Points 1,2,3: First bezier segment (cp1, cp2, end anchor)
 * - Points 4,5,6: Second bezier segment (cp1, cp2, end anchor)
 * - etc.
 * 
 * Total points should be 3n+1 where n is the number of bezier segments.
 * For 2 points, draws a straight line.
 * For other counts that don't fit the pattern, falls back to straight lines
 * between remaining points.
 */
mxPolyline.prototype.paintBezierLine = function(c, pts)
{
	var n = pts.length;
	
	if (n < 2)
	{
		return;
	}
	
	c.begin();
	c.moveTo(pts[0].x, pts[0].y);
	
	// Handle simple 2-point case (straight line)
	if (n == 2)
	{
		c.lineTo(pts[1].x, pts[1].y);
		c.stroke();
		return;
	}
	
	// Process cubic bezier segments (3 points each: cp1, cp2, anchor)
	var i = 1;
	
	while (i + 2 < n)
	{
		var cp1 = pts[i];
		var cp2 = pts[i + 1];
		var end = pts[i + 2];
		
		c.curveTo(cp1.x, cp1.y, cp2.x, cp2.y, end.x, end.y);
		i += 3;
	}
	
	// Handle any remaining points (fallback to lineTo)
	while (i < n)
	{
		c.lineTo(pts[i].x, pts[i].y);
		i++;
	}
	
	c.stroke();
};