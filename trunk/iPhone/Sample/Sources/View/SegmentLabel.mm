

#import "SegmentLabel.h"


@implementation SegmentItem

//
+ (id)segLabelWithSpace:(CGFloat)width
{
	SegmentItem *label = [[[SegmentItem alloc] init] autorelease];
	label.width = width;
	return label;
}

//
+ (id)segLabelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
	SegmentItem *label = [[[SegmentItem alloc] init] autorelease];
	label.text = text;
	label.font = font;
	label.color = color;
	return label;
}

//
+ (id)segLabelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width
{
	SegmentItem *label = [self segLabelWithText:text font:font color:color];
	label.width = width;
	return label;
}

//
+ (id)segLabelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment
{
	SegmentItem *label = [self segLabelWithText:text font:font color:color width:width];
	label.alignment = alignment;
	return label;
}

//
- (void)dealloc
{
	[_text release];
	[_font release];
	[_color release];
	[_shadowColor release];
	[_highlightedColor release];
	
	[super dealloc];
}

@end


@implementation SegmentLabel

//
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.userInteractionEnabled = NO;
	//self.backgroundColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:0.2];
	self.opaque = NO;
	return self;
}

//
- (void)dealloc
{
	[_labels release];
	
	[super dealloc];
}

//
- (void)setHighlighted:(BOOL)highlighted
{
	_highlighted = highlighted;
	[self setNeedsDisplay];
}

//
- (void)setLabels:(NSArray *)labels
{
	if (_labels != labels)
	{
		[_labels release];
		_labels = labels.retain;
	}
	
	_lineWidth = 0;
	_lineHeight = 0;
	for (SegmentItem *label in _labels)
	{
		CGSize size = {0};
		if (label.text.length)
		{
			size = [label.text sizeWithFont:label.font];
		}
		_lineWidth += label.width ? label.width : size.width;
		if (_lineHeight < size.height)
		{
			_lineHeight = size.height;
		}
	}

	[self setNeedsDisplay];
}

//
- (BOOL)drawText:(NSString *)text atPoint:(CGPoint)point withFont:(UIFont *)font right:(CGFloat)right width:(CGFloat)width alignment:(SegmentItemTextAlignment)alignment
{
	CGSize size = [text sizeWithFont:font];
	if (point.x + size.width <= right)
	{
		if (width > size.width)
		{
			if (alignment == NSTextAlignmentRight)
			{
				point.x += width - size.width;
			}
			else if (alignment == NSTextAlignmentCenter)
			{
				point.x += (width - size.width) / 2;
			}
		}
		
		if (_baseAlignment == SegmentLabelBaseAlignmentBottom)
		{
			if (_lineHeight >= size.height + 2)
			{
				point.y += _lineHeight - size.height - 2;	// MAGIC: 2 is minor fix
			}
		}
		else if (_baseAlignment != SegmentLabelBaseAlignmentTop)
		{
			point.y += (_lineHeight - size.height) / 2;
		}
		else
		{
			if (_lineHeight >= size.height + 2)
			{
				point.y += 2;	// MAGIC: 2 is minor fix
			}
		}
		
		return [text drawAtPoint:point withFont:font].width;
	}
	return NO;
}

//
- (void)drawRect:(CGRect)rect
{
	// Adjust content rect based on content mode
	UIViewContentMode contentMode = self.contentMode;
	if (contentMode != UIViewContentModeTopLeft)
	{
		NSUInteger lines = ((NSUInteger)_lineWidth + (NSUInteger)rect.size.width - 1) / (NSUInteger)rect.size.width;
		CGSize size = {MIN(rect.size.width, _lineWidth), _lineHeight * lines};
		
		if (rect.size.width >= size.width)
		{
			if ((contentMode == UIViewContentModeRight) || (contentMode == UIViewContentModeTopRight) || (contentMode == UIViewContentModeBottomRight))
			{
				rect.origin.x += rect.size.width - size.width;
			}
			else if ((contentMode != UIViewContentModeLeft) && (contentMode != UIViewContentModeTopLeft) && (contentMode != UIViewContentModeBottomLeft))
			{
				rect.origin.x += (rect.size.width - size.width) / 2;
			}
		}
		if (rect.size.height >= size.height)
		{
			if ((contentMode == UIViewContentModeBottom) || (contentMode == UIViewContentModeBottomLeft) || (contentMode == UIViewContentModeBottomRight))
			{
				rect.origin.y += rect.size.height - size.height;
			}
			else if ((contentMode != UIViewContentModeTop) && (contentMode != UIViewContentModeTopLeft) && (contentMode != UIViewContentModeTopRight))
			{
				rect.origin.y += (rect.size.height - size.height) / 2;
			}
		}
		//rect.size = size;
	}

	//
	CGPoint point = rect.origin;
	CGFloat right = rect.origin.x + rect.size.width;
	CGContextRef context = UIGraphicsGetCurrentContext();
	for (SegmentItem *label in _labels)
	{
		if (UIColor *color = (_highlighted && label.highlightedColor) ? label.highlightedColor : label.color)
		{
			CGContextSetFillColorWithColor(context, color.CGColor);
		}
		CGContextSetShadowWithColor(context, label.shadowOffset, label.shadowBlur, label.shadowColor.CGColor);

		CGFloat width = 0;
		NSString *text = label.text;
		if (text.length)
		{
			UIFont *font = label.font;

			while (!(width = [self drawText:text atPoint:point withFont:font right:right width:label.width alignment:label.alignment]))
			{
				NSUInteger i = 1;
				NSUInteger length = text.length;
				while ((i < length) && (point.x + [[text substringToIndex:i] sizeWithFont:font].width < right)) i++;
				
				if (i > 1)
				{
					[self drawText:[text substringToIndex:i - 1] atPoint:point withFont:font right:right width:0 alignment:label.alignment];
				}
				point.x = rect.origin.x;
				point.y += _lineHeight;
				
				if (i < text.length)
				{
					text = [text substringFromIndex:i - 1];
				}
				else
				{
					break;
				}
			}
		}
		point.x += label.width ? label.width : width;
	}
}

@end
