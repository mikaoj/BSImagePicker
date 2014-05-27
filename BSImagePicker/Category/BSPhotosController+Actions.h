//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSPhotosController.h"

@interface BSPhotosController (Actions)

- (void)finishButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;
- (void)showAlbumView;
- (void)hideAlbumView;
- (void)itemLongPressed:(UIGestureRecognizer *)recognizer;

@end