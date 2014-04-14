//
//  BSImagePickerController.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-13.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MultipleImagePicker.h"

@interface BSImagePickerController : UINavigationController

//Defaults to NSUIntegerMax (i.e shitloads of images)
@property (nonatomic, assign) NSUInteger maximumNumberOfImages;

@property (nonatomic, copy) BSImageToggleBlock toggleBlock;
@property (nonatomic, copy) BSImageSelectionFinishedBlock finishBlock;

@property (nonatomic, assign) BOOL previewDisabled;
@property (nonatomic, assign) BOOL disableEdit;

@end
