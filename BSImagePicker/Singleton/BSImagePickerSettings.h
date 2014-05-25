//
//  BSImagePickerSettings.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-25.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "UIViewController+MultipleImagePicker.h"

@interface BSImagePickerSettings : NSObject

+ (instancetype)sharedSetting;

/**
 *  Defaults to NSUIntegerMax (i.e shitloads of images)
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfImages;

/**
 *  Block that gets called on select/deselect
 */
@property (nonatomic, copy) BSImageToggleBlock toggleBlock;

/**
 *  Block that gets called on cancel
 */
@property (nonatomic, copy) BSImageGroupBlock cancelBlock;

/**
 *  Block that gets called on finish
 */
@property (nonatomic, copy) BSImageGroupBlock finishBlock;

/**
 *  Set to YES to disable preview on long press
 */
@property (nonatomic, assign) BOOL previewDisabled;

/**
 *  Set to YES to disable edit mode in preview.
 *  This isn't supported yet. Placeholder for future feature :)
 */
@property (nonatomic, assign) BOOL disableEdit;

/**
 *  Set this to customize the size of items (photos and albums)
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 * Set this to yes to keep selection after close
 */
@property (nonatomic, assign) BOOL keepSelection;

/**
 * Background tint color for the album view. If nil it will match the navigationbar color.
 */
@property (nonatomic, strong) UIColor *albumTintColor;

@end
