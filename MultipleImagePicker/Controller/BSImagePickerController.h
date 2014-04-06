//
//  BSImagePickerController.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-05.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSImagePickerController : UIViewController

//Defaults to NSUIntegerMax (i.e shitloads of images)
@property (nonatomic, assign) NSUInteger maximumNumberOfImages;

@property (nonatomic, copy) void (^selectionBlock)(void);
@property (nonatomic, copy) void (^unselectionBlock)(void);
@property (nonatomic, copy) void (^doneBlock)(void);
@property (nonatomic, copy) void (^cancelBlock)(void);

@end
