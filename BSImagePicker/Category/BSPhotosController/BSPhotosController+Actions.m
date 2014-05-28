//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController+Actions.h"
#import "BSPhotosController+Properties.h"
#import "BSImagePickerSettings.h"
#import "BSSpeechBubbleView.h"
#import "BSPhotoCollectionViewCellFactory.h"


@implementation BSPhotosController (Actions)

#pragma mark - Button actions

- (void)finishButtonPressed:(id)sender {
    //Cancel or finish? Call correct block!
    if(sender == self.cancelButton) {
        if([[BSImagePickerSettings sharedSetting] cancelBlock]) {
            [BSImagePickerSettings sharedSetting].cancelBlock([self.selectedItems copy]);
        }
    } else {
        if([[BSImagePickerSettings sharedSetting] finishBlock]) {
            [BSImagePickerSettings sharedSetting].finishBlock([self.selectedItems copy]);
        }
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumButtonPressed:(id)sender {
    if([self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        [self hideAlbumView];
    } else {
        [self showAlbumView];
    }
}

#pragma mark - Show and hide album view

- (void)showAlbumView {
    [self.navigationController.view addSubview:self.coverView];
    [self.navigationController.view addSubview:self.speechBubbleView];

    CGFloat tableViewHeight = MIN(self.albumTableView.contentSize.height, 240);
    CGRect frame = CGRectMake(0, 0, self.speechBubbleView.frame.size.width, tableViewHeight+7);

    //Remember old values
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;

    //Set new frame
    frame.size.height = 0.0;
    frame.size.width = 0.0;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height/2.0;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    [self.speechBubbleView setFrame:frame];

    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:0
                     animations:^{
        CGRect frame = self.speechBubbleView.frame;
        frame.size.height = height;
        frame.size.width = width;
        frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
        [self.speechBubbleView setFrame:frame];

        [self.coverView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
    } completion:nil];
}

- (void)hideAlbumView {
    __block CGAffineTransform origTransForm = self.speechBubbleView.transform;

    [UIView animateWithDuration:0.2
                     animations:^{
        [self.speechBubbleView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.1, 0.1), CGAffineTransformMakeTranslation(0, -(self.speechBubbleView.frame.size.height/2.0)))];
        [self.coverView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    } completion:^(BOOL finished) {
        [self.speechBubbleView removeFromSuperview];
        [self.speechBubbleView setTransform:origTransForm];
        [self.coverView removeFromSuperview];
    }];
}

#pragma mark - GestureRecognizer

- (void)itemLongPressed:(UIGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan && ![[BSImagePickerSettings sharedSetting] previewDisabled]) {
        [recognizer setEnabled:NO];

        CGPoint location = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];

        [recognizer setEnabled:YES];
    }
}

@end