//
// Created by Joakim Gyllström on 2014-05-29.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BSZoomOutAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CGRect animateToRect;

@end