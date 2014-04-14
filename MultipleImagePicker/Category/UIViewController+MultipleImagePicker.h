//
//  UIViewController+MultipleImagePicker.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-15.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BSImageToggleBlock)(NSDictionary *info, BOOL selected);
typedef void (^BSImageSelectionFinishedBlock)(NSArray *infoArray, BOOL canceled);

@class BSImagePickerController;
@interface UIViewController (MultipleImagePicker)

- (void)presentImagePickerController:(BSImagePickerController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion toggle:(BSImageToggleBlock)toggle finish:(BSImageSelectionFinishedBlock)finish;

@end
