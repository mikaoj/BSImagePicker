//
//  UIViewController+MultipleImagePicker.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-15.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "UIViewController+MultipleImagePicker.h"
#import "BSImagePickerController.h"

@implementation UIViewController (MultipleImagePicker)

- (void)presentImagePickerController:(BSImagePickerController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion toggle:(BSImageToggleBlock)toggle finish:(BSImageSelectionFinishedBlock)finish
{
    if([viewControllerToPresent isKindOfClass:[BSImagePickerController class]]) {
        [viewControllerToPresent setToggleBlock:toggle];
        [viewControllerToPresent setFinishBlock:finish];
    }
    
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
