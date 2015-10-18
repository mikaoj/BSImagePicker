//
//  RDHCollectionViewGridLayout.h
//  RDHCollectionViewGridLayout
//
//  Created by Richard Hodgkins on 06/07/2013.
//  Copyright (c) 2013 Rich H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

/// Project version number for RDHCollectionViewGridLayout.
FOUNDATION_EXPORT double RDHCollectionViewGridLayoutVersionNumber;

/// Project version string for RDHCollectionViewGridLayout.
FOUNDATION_EXPORT const unsigned char RDHCollectionViewGridLayoutVersionString[];

@interface RDHCollectionViewGridLayout : UICollectionViewLayout

/**
 * A vertical direction will constrain the layout by rows (lineItemCount per row), a horizontal direction by columns (lineItemCount per column).
 *
 * The default value of this property is UICollectionViewScrollDirectionVertical.
 *
 * @warning A non-enum value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable UICollectionViewScrollDirection scrollDirection;

/**
 * Defines the size of the unconstrained dimension of the items. Simply, for vertical layouts this is the height of the items, and for horizontal layouts this is the width of the items.
 * Setting this value to 0 will make layout set the dimension to the average of the other dimenion on the same line. This is due to the layout taking account of dirty pixels, adding these extra pixels in the first X items on the line.
 * For example, if using a vertical scrollDirection and a lineItemCount of 5 when the collectionView has a width of 104, the first 4 items on every line will have a width of 21, and the last 20 (21 + 21 + 21 + 21 + 20 = 104), so the height of the lines would be 21 (20.8 rounded).
 *
 * A value of 0 is the same as setting the `lineExtension` property to 0 `lineMultiplier` property to 1. Setting this value will ignore the `lineExtension` and `lineMultiplier` properties and set them to their default values. When used and set in Interface Builder, leave the other properties to Default and only set this property.
 *
 * The default value of this property is 0.
 *
 * @see lineMultiplier
 * @see lineExtension
 *
 * @warning A negative value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable CGFloat lineSize;

/**
 * Defines a multipler of the unconstrained dimension of the items in relation to the strained dimension. Simply, for vertical layouts this value is multiplied by the width and used as the height of the items, and for horizontal layouts this value is multiplied by the height and used as the width of the items. The final dimension is rounded to a whole integer.
 *
 * A value of 1 is the same as setting the `lineSize` or `lineExtension` properties to 0.Setting this value will ignore the `lineSize` and `lineExtension` properties and set them to their default values. When used and set in Interface Builder, leave the other properties to Default and only set this property.
 *
 * The default value of this property is 1.
 *
 * @see lineSize
 * @see lineExtension
 *
 * @warning A none positive value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable CGFloat lineMultiplier;

/**
 * Defines a multipler of the unconstrained dimension of the items in relation to the strained dimension. Simply, for vertical layouts this value is added to the width and used as the height of the items, and for horizontal layouts this value is added to the height and used as the width of the items.
 *
 * A value of 0 is the same as setting the `lineSize` property to 0 `lineMultiplier` property to 1. Setting this value will ignore the `lineSize` and `lineMultiplier` properties and set them to their default values. When used and set in Interface Builder, leave the other properties to Default and only set this property.
 *
 * The default value of this property is 0.
 *
 * @see lineSize
 * @see lineMultiplier
 *
 * @warning A negative value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable CGFloat lineExtension;

/**
 * Defines the maximum number of items allowed per line. Simply, for vertical layouts this is the number of columns, and for horizontal layouts this is the number of rows. The layout accounts for adding the extra pixels to the first X items on the line. Best case is that the useable width is exactly divisible by lineItemCount, worse case is that `(useable width) mod lineItemCount = (lineItemCount - 1)` and that the first `(lineItemCount - 1)` items are 1 pixel bigger.
 *
 * The default value of this property is 4.
 *
 * @warning A 0 value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable NSUInteger lineItemCount;

/**
 * Defines the spacing of items on the same line of the layout. Simply, for vertical layouts this is the column spacing, and for horizontal layouts this is the row spacing.
 *
 * The default value of this property is 0.
 */
@property (nonatomic, assign) IBInspectable CGFloat itemSpacing;

/**
 * Defines the line spacing of the layout. Simply, for vertical layouts this is the row spacing, and for horizontal layouts this is the column spacing.
 *
 * The default value of this property is 0.
 */
@property (nonatomic, assign) IBInspectable CGFloat lineSpacing;

/**
 * To force sections to start on a new line set this property to YES. Otherwise the section will follow on on from the previous one.
 *
 * The default value of this property is NO.
 */
@property (nonatomic, assign) IBInspectable BOOL sectionsStartOnNewLine;

@end

@interface RDHCollectionViewGridLayout (RDHCollectionViewGridLayout_Deprecated)

/**
 * **Deprecated and replaced with `lineSize` as other line dimensions have been added. (`lineSize` has exactly the same functionality as this property) **
 *
 * Defines the size of the unconstrained dimension of the items. Simply, for vertical layouts this is the height of the items, and for horizontal layouts this is the width of the items.
 * Setting this value to 0 will make layout set the dimension to the average of the other dimenion on the same line. This is due to the layout taking account of dirty pixels, adding these extra pixels in the first X items on the line.
 * For example, if using a vertical scrollDirection and a lineItemCount of 5 when the collectionView has a width of 104, the first 4 items on every line will have a width of 21, and the last 20 (21 + 21 + 21 + 21 + 20 = 104), so the height of the lines would be 21 (20.8 rounded).
 *
 * A value of 0 is the same as setting the `lineExtension` property to 0 `lineMultiplier` property to 1. Setting this value will ignore the `lineExtension` and `lineMultiplier` properties and set them to their default values. When used and set in Interface Builder, leave the other properties to Default and only set this property.
 *
 * The default value of this property is 0.
 *
 * @see lineSize
 * @see lineMultiplier
 * @see lineExtension
 *
 * @warning A negative value will throw an exception.
 */
@property (nonatomic, assign) IBInspectable CGFloat lineDimension DEPRECATED_MSG_ATTRIBUTE("use lineSize instead.");

@end