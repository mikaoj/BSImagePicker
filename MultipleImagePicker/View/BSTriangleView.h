//
//  BSTriangleView.h
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-07.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSTriangleView : UIView

- (id)initWithFrame:(CGRect)frame andPointerSize:(CGSize)pointerSize;

@property (nonatomic, assign) CGSize pointerSize;

@end
