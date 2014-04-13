//
//  BSSpeechBubbleView.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-06.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSSpeechBubbleView : UIView

@property (nonatomic, strong) UIView *contentView;

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (UIColor *)backgroundColor;

@end
