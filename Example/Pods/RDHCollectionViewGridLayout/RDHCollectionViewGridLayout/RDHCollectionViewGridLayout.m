//
//  RDHCollectionViewGridLayout.m
//  RDHCollectionViewGridLayout
//
//  Created by Richard Hodgkins on 06/07/2013.
//  Copyright (c) 2013 Rich H. All rights reserved.
//

#import "RDHCollectionViewGridLayout.h"

typedef NS_ENUM(NSUInteger, RDHLineDimensionType) {
    RDHLineDimensionTypeSize,
    RDHLineDimensionTypeMultiplier,
    RDHLineDimensionTypeExtension
};

static RDHLineDimensionType const RDHLineDimensionTypeDefault = RDHLineDimensionTypeSize;

static CGFloat const RDHLineSizeDefault = 0;
static CGFloat const RDHLineMutliplierDefault = 1;
static CGFloat const RDHLineExtensionDefault = 0;

@interface RDHCollectionViewGridLayout ()

@property (nonatomic, copy) NSArray *firstLineFrames;
@property (nonatomic, copy, readonly) NSMutableDictionary *itemAttributes;

/// This property is used to store the lineDimension when it is set to 0 (depends on the average item size) and the base item size.
@property (nonatomic, assign) CGSize calculatedItemSize;

/// This property is re-calculated when invalidating the layout
@property (nonatomic, assign) NSUInteger numberOfLines;

@property (nonatomic, assign) RDHLineDimensionType lineDimensionType;

@end

@implementation RDHCollectionViewGridLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    [self setInitialDefaults];
    
    _firstLineFrames = nil;
    _itemAttributes = [NSMutableDictionary dictionary];
    _numberOfLines = 0;
}

-(void)setInitialDefaults
{
    // Default properties
    _scrollDirection = UICollectionViewScrollDirectionVertical;
    _lineDimensionType = RDHLineDimensionTypeDefault;
    _lineSize = RDHLineSizeDefault;
    _lineMultiplier = RDHLineMutliplierDefault;
    _lineExtension = RDHLineExtensionDefault;
    _lineItemCount = 4;
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionsStartOnNewLine = NO;
}

-(void)invalidateLayout
{
    [super invalidateLayout];
    
    self.firstLineFrames = nil;
    [self.itemAttributes removeAllObjects];
    self.numberOfLines = 0;
    self.calculatedItemSize = CGSizeZero;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    self.numberOfLines = [self calculateNumberOfLines];
    
    self.calculatedItemSize = [self calculateItemSize];
    
    NSInteger const sectionCount = [self.collectionView numberOfSections];
    for (NSInteger section=0; section<sectionCount; section++) {
        
        NSInteger const itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item=0; item<itemCount; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            self.itemAttributes[indexPath] = [self calculateLayoutAttributesForItemAtIndexPath:indexPath];
        }
    }
}

-(CGSize)collectionViewContentSize
{
    CGSize size;
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            size.width = self.numberOfLines * self.calculatedItemSize.width;
            // Add spacings
            size.width += (self.numberOfLines - 1) * self.lineSpacing;
            size.height = [self constrainedCollectionViewDimension];
            break;
            
        case UICollectionViewScrollDirectionVertical:
            size.width = [self constrainedCollectionViewDimension];
            size.height = self.numberOfLines * self.calculatedItemSize.height;
            // Add spacings
            size.height += (self.numberOfLines - 1) * self.lineSpacing;
            break;
    }
    
    return size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttrs = self.itemAttributes[indexPath];
    
    if (!layoutAttrs) {
        layoutAttrs = [self calculateLayoutAttributesForItemAtIndexPath:indexPath];
        self.itemAttributes[indexPath] = layoutAttrs;
    }
    
    return layoutAttrs;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithCapacity:[self.itemAttributes count]];
    
    [self.itemAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *const indexPath, UICollectionViewLayoutAttributes *attr, BOOL *stop) {
        
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [layoutAttributes addObject:attr];
        }
    }];
    
    return layoutAttributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size);
}

#pragma mark - Lazily loaded properties

/// Precalculate the frames for the first line as they can be reused for every line
-(NSArray *)firstLineFrames
{
    if (!_firstLineFrames) {
        
        CGFloat collectionConstrainedDimension = [self constrainedCollectionViewDimension];
        // Subtract the spacing between items on a line
        collectionConstrainedDimension -= (self.itemSpacing * (self.lineItemCount - 1));

        CGFloat constrainedItemDimension;
        switch (self.scrollDirection) {
            case UICollectionViewScrollDirectionVertical:
                constrainedItemDimension = self.calculatedItemSize.width;
                break;
                
            case UICollectionViewScrollDirectionHorizontal:
                constrainedItemDimension = self.calculatedItemSize.height;
                break;
        }
        
        // This value will always be less than the lineItemCount - this is the number of dirty pixels
        CGFloat remainingDimension = collectionConstrainedDimension - (constrainedItemDimension * self.lineItemCount);
        
        CGRect frame = CGRectZero;
        frame.size = self.calculatedItemSize;
        
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:self.lineItemCount];
        
        for (NSUInteger i=0; i<self.lineItemCount; i++) {
            
            CGRect itemFrame = frame;
            
            // Add an extra pixel if we've got dirty pixels left
            if (remainingDimension-- > 0) {
                switch (self.scrollDirection) {
                    case UICollectionViewScrollDirectionVertical:
                        itemFrame.size.width++;
                        break;
                        
                    case UICollectionViewScrollDirectionHorizontal:
                        itemFrame.size.height++;
                        break;
                }
            }
            
            [frames addObject:[NSValue valueWithCGRect:itemFrame]];
            
            // Move to the next item
            switch (self.scrollDirection) {
                case UICollectionViewScrollDirectionVertical:
                    frame.origin.x = itemFrame.origin.x + itemFrame.size.width + self.itemSpacing;
                    break;
                    
                case UICollectionViewScrollDirectionHorizontal:
                    frame.origin.y = itemFrame.origin.y + itemFrame.size.height + self.itemSpacing;
                    break;
            }
        }
        
        _firstLineFrames = [frames copy];
    }
    
    return _firstLineFrames;
}

#pragma mark - Calculation methods

-(NSUInteger)calculateNumberOfLines
{
    NSInteger numberOfLines;
    if (self.sectionsStartOnNewLine) {
        
        numberOfLines = 0;
        
        NSInteger const sectionCount = [self.collectionView numberOfSections];
        for (NSInteger section=0; section<sectionCount; section++) {
            // If there are too many items to fill a line, allow it to over flow.
            numberOfLines += ceil(((CGFloat) [self.collectionView numberOfItemsInSection:section]) / self.lineItemCount);
        }
        
        // Best case: numberOfLines = number of sections with items
        // Worse case: numberOfLines = 2 * number of sections with items
        
    } else {
        
        NSUInteger n = 0;
        NSInteger const sectionCount = [self.collectionView numberOfSections];
        for (NSInteger section=0; section<sectionCount; section++) {
            n += [self.collectionView numberOfItemsInSection:section];
        }
        CGFloat numberOfItems = n;
        // We just need to work out the number of lines
        numberOfLines = ceil(numberOfItems / self.lineItemCount);
    }
    
    return numberOfLines;
}

-(CGSize)calculateItemSize
{
    CGFloat collectionConstrainedDimension = [self constrainedCollectionViewDimension];
    // Subtract the spacing between items on a line
    collectionConstrainedDimension -= (self.itemSpacing * (self.lineItemCount - 1));
    
    const CGFloat constrainedItemDimension = floor(collectionConstrainedDimension / self.lineItemCount);
    
    CGSize size = CGSizeZero;
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            size.width = constrainedItemDimension;
            
            if ((self.lineSize == RDHLineSizeDefault)
                && (self.lineMultiplier == RDHLineMutliplierDefault)
                && (self.lineExtension == RDHLineExtensionDefault)) {
                
                // All defaults which means that layout uses the same height/width
                size.height = round(collectionConstrainedDimension / self.lineItemCount);
                
            } else {
                
                switch (self.lineDimensionType) {
                    case RDHLineDimensionTypeSize:
                        size.height = self.lineSize;
                        break;
                        
                    case RDHLineDimensionTypeMultiplier:
                        size.height = round(size.width * self.lineMultiplier);
                        break;
                        
                    case RDHLineDimensionTypeExtension:
                        size.height = size.width + self.lineExtension;
                        break;
                }
            }
            break;
            
        case UICollectionViewScrollDirectionHorizontal:
            size.height = constrainedItemDimension;
            
            if ((self.lineSize == RDHLineSizeDefault)
                && (self.lineMultiplier == RDHLineMutliplierDefault)
                && (self.lineExtension == RDHLineExtensionDefault)) {
                
                // All defaults which means that layout uses the same height/width
                size.width = round(collectionConstrainedDimension / self.lineItemCount);
                
            } else {
            
                switch (self.lineDimensionType) {
                    case RDHLineDimensionTypeSize:
                        size.width = self.lineSize;
                        break;
                        
                    case RDHLineDimensionTypeMultiplier:
                        size.width = round(size.height * self.lineMultiplier);
                        break;
                        
                    case RDHLineDimensionTypeExtension:
                        size.width = size.height + self.lineExtension;
                        break;
                }
            }
            break;
    }
    
    return size;
}

-(UICollectionViewLayoutAttributes *)calculateLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame;
    NSUInteger line;
    
    if (self.sectionsStartOnNewLine) {
        // As we start a section on a new line, this value does not need to account for previous sections
        frame = [self.firstLineFrames[indexPath.item % self.lineItemCount] CGRectValue];
        
        line = 0;
        for (NSInteger section=0; section<indexPath.section; section++) {
            // If there are too many items to fill a line, allow it to over flow.
            line += ceil(((CGFloat) [self.collectionView numberOfItemsInSection:section]) / self.lineItemCount);
        }
        // Add the line that this item is on in this section
        line += indexPath.item / self.lineItemCount;
        
    } else {
        
        // Need to calculate the number of items that have come before in previous sections
        NSUInteger numberOfItems = 0;
        for (NSInteger section=0; section<indexPath.section; section++) {
            // If there are too many items to fill a line, allow it to over flow.
            numberOfItems += [self.collectionView numberOfItemsInSection:section];
        }
        // And now calculate this items place
        numberOfItems += indexPath.item;
        
        // Get frame of this item - it'll be offset by the possible previous items on this line
        frame = [self.firstLineFrames[numberOfItems % self.lineItemCount] CGRectValue];
        
        // Now work out the line
        line = numberOfItems / self.lineItemCount;
    }
    
    // Work out the x/y offset depending on the scroll direction
    CGFloat spacingOffset = (line * self.lineSpacing);
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            frame.origin.y += (line * self.calculatedItemSize.height) + spacingOffset;
            break;
            
        case UICollectionViewScrollDirectionHorizontal:
            frame.origin.x += (line * self.calculatedItemSize.width) + spacingOffset;
            break;
    }
    
    attrs.frame = frame;
    // Place below the scroll bar
    attrs.zIndex = -1;
    
    return attrs;
}

#pragma mark - Convenince sizing methods

-(CGFloat)constrainedCollectionViewDimension
{
    CGSize collectionViewInsetBoundsSize = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size;
    
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            return collectionViewInsetBoundsSize.height;
            
        case UICollectionViewScrollDirectionVertical:
            return collectionViewInsetBoundsSize.width;
    }
}

#pragma mark - Detail setters that invalidate the layout

-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    NSAssert(scrollDirection == UICollectionViewScrollDirectionHorizontal || scrollDirection == UICollectionViewScrollDirectionVertical, @"Invalid scrollDirection: %ld", (long) scrollDirection);
    
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        
        [self invalidateLayout];
    }
}

-(void)setLineDimensionType:(RDHLineDimensionType)lineDimensionType
{
    if (_lineDimensionType != lineDimensionType) {
        _lineDimensionType = lineDimensionType;
        
        [self invalidateLayout];
    }
}

-(void)setLineSize:(CGFloat)lineSize
{
    NSAssert(lineSize >= 0, @"Negative lineSize is meaningless");
    
    // Reset other line dimensions
    _lineMultiplier = RDHLineMutliplierDefault;
    _lineExtension = RDHLineExtensionDefault;
    self.lineDimensionType = RDHLineDimensionTypeSize;
    
    if (_lineSize != lineSize) {
        _lineSize = lineSize;
        
        [self invalidateLayout];
    }
}

-(void)setLineMultiplier:(CGFloat)lineMultiplier
{
    NSAssert(lineMultiplier > 0, @"None positive lineMultiplier is meaningless");
    
    // Reset other line dimensions
    _lineSize = RDHLineSizeDefault;
    _lineExtension = RDHLineExtensionDefault;
    self.lineDimensionType = RDHLineDimensionTypeMultiplier;
    
    if (_lineMultiplier != lineMultiplier) {
        _lineMultiplier = lineMultiplier;
        
        [self invalidateLayout];
    }
}

-(void)setLineExtension:(CGFloat)lineExtension
{
    NSAssert(lineExtension >= 0, @"Negative lineExtension is meaningless");
    
    // Reset other line dimensions
    _lineSize = RDHLineSizeDefault;
    _lineMultiplier = RDHLineMutliplierDefault;
    self.lineDimensionType = RDHLineDimensionTypeExtension;
    
    if (_lineExtension != lineExtension) {
        _lineExtension = lineExtension;
        
        [self invalidateLayout];
    }
}

-(void)setLineItemCount:(NSUInteger)lineItemCount
{
    NSAssert(lineItemCount > 0, @"Zero line item count is meaningless");
    if (_lineItemCount != lineItemCount) {
        _lineItemCount = lineItemCount;
        
        [self invalidateLayout];
    }
}

-(void)setItemSpacing:(CGFloat)itemSpacing
{
    if (_itemSpacing != itemSpacing) {
        _itemSpacing = itemSpacing;
        
        [self invalidateLayout];
    }
}

-(void)setLineSpacing:(CGFloat)lineSpacing
{
    if (_lineSpacing != lineSpacing) {
        _lineSpacing = lineSpacing;
        
        [self invalidateLayout];
    }
}

-(void)setSectionsStartOnNewLine:(BOOL)sectionsStartOnNewLine
{
    if (_sectionsStartOnNewLine != sectionsStartOnNewLine) {
        _sectionsStartOnNewLine = sectionsStartOnNewLine;
        
        [self invalidateLayout];
    }
}

-(NSString *)description
{
    NSString *lineDimension;
    
    if ((self.lineSize == RDHLineSizeDefault)
        && (self.lineMultiplier == RDHLineMutliplierDefault)
        && (self.lineExtension == RDHLineExtensionDefault)) {
        
        lineDimension = @"(Auto)";
        
    } else {
        
        switch (self.lineDimensionType) {
            case RDHLineDimensionTypeSize:
                lineDimension = [NSString stringWithFormat:@"(Size, %.3lf)", self.lineSize];
                break;
            case RDHLineDimensionTypeMultiplier:
                lineDimension = [NSString stringWithFormat:@"(Multiplier, %.3lf)", self.lineMultiplier];
                break;
            case RDHLineDimensionTypeExtension:
                lineDimension = [NSString stringWithFormat:@"(Extension, %.3lf)", self.lineExtension];
                break;
        }
    }
    
    return [NSString stringWithFormat:@"<%@: %p; scrollDirection = %@; lineDimension = %@; lineItemCount = %llu; itemSpacing = %.3lf; lineSpacing = %.3lf; sectionsStartOnNewLine = %@>", NSStringFromClass([self class]), self, (self.scrollDirection == UICollectionViewScrollDirectionVertical ? @"Vertical" : @"Horizontal"), lineDimension, (unsigned long long) self.lineItemCount, self.itemSpacing, self.lineSpacing, (self.sectionsStartOnNewLine ? @"YES" : @"NO")];
}

@end

@interface RDHCollectionViewGridLayout (InspectableScrolling)

@property (nonatomic, assign) IBInspectable BOOL verticalScrolling;

@end

@implementation RDHCollectionViewGridLayout (InspectableScrolling)

-(BOOL)verticalScrolling
{
    return self.scrollDirection == UICollectionViewScrollDirectionVertical;
}

-(void)setVerticalScrolling:(BOOL)verticalScrolling
{
    self.scrollDirection = verticalScrolling ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
}

@end

@implementation RDHCollectionViewGridLayout (RDHCollectionViewGridLayout_Deprecated)

-(CGFloat)lineDimension
{
    return self.lineSize;
}

-(void)setLineDimension:(CGFloat)lineDimension
{
    self.lineSize = lineDimension;
}

@end