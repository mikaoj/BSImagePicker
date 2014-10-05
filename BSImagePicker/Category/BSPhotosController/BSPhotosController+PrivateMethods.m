// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "BSPhotosController+PrivateMethods.h"
#import "BSImagePickerSettings.h"
#import "BSItemsModel.h"

@interface BSPhotosController (SuperPrivate)

- (void)updateDoneButtonWithSelectedAssets:(NSUInteger)selectedAssets;
- (void)setTitleWithoutAnimation:(NSString *)aTitle forButton:(UIButton *)aButton;
- (BOOL)isRightBarButton:(UIButton *)aButton;

@end

@implementation BSPhotosController (PrivateMethods)

#pragma mark - Button actions

- (void)finishButtonPressed:(id)sender {
    //Cancel or finish? Call correct block!
    if(sender == self.cancelButton) {
        if([[BSImagePickerSettings sharedSetting] cancelBlock]) {
            [BSImagePickerSettings sharedSetting].cancelBlock([self.collectionModel.selectedItems copy]);
        }
    } else {
        if([[BSImagePickerSettings sharedSetting] finishBlock]) {
            [BSImagePickerSettings sharedSetting].finishBlock([self.collectionModel.selectedItems copy]);
        }
    }
    
    //Remove selections if user doesn't want to keep them
    if(![[BSImagePickerSettings sharedSetting] keepSelection]) {
        [self.collectionModel clearSelection];
    }
}

- (void)albumButtonPressed:(UIButton *)sender {
    [UIView animateWithDuration:0.1
                     animations:^{
                         [sender setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                          animations:^{
                                              [sender setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                          }
                                          completion:nil];
                     }];
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
    
    CGFloat tableViewHeight = MIN(self.tableController.tableView.contentSize.height, 240);
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
                     }
                     completion:nil];
}

- (void)hideAlbumView {
    __block CGAffineTransform origTransForm = self.speechBubbleView.transform;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.speechBubbleView setTransform:CGAffineTransformConcat(CGAffineTransformMakeScale(0.1, 0.1), CGAffineTransformMakeTranslation(0, -(self.speechBubbleView.frame.size.height/2.0)))];
                         [self.coverView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
                     }
                     completion:^(BOOL finished) {
                         [self.speechBubbleView removeFromSuperview];
                         [self.speechBubbleView setTransform:origTransForm];
                         [self.coverView removeFromSuperview];
                     }];
}

- (void)syncSelectionInModel:(id<BSItemsModel>)aModel withCollectionView:(UICollectionView *)aCollectionView {
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)updateAlbumTitle:(NSString *)aTitle {
    [UIView transitionWithView:self.albumButton
                      duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [self.albumButton setTitle:aTitle
                                          forState:UIControlStateNormal];
                    }
                    completion:nil];
}

- (void)toggleDoneButton {
    if([self.collectionModel.selectedItems count] > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    [self updateDoneButtonWithSelectedAssets:self.collectionModel.selectedItems.count];
}

#pragma mark - GestureRecognizer

- (void)itemLongPressed:(UIGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan && ![[BSImagePickerSettings sharedSetting] previewDisabled]) {
        [recognizer setEnabled:NO];
        
        CGPoint location = [recognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        [self.previewController setCollectionModel:self.collectionModel];
        [self.previewController setCurrentIndexPath:indexPath];
        [self.previewController.collectionView setContentInset:self.collectionView.contentInset];
        [self.navigationController pushViewController:self.previewController animated:YES];
        
        [recognizer setEnabled:YES];
    }
}

@end

@implementation BSPhotosController (SuperPrivate)

#pragma mark - Private private

- (void)updateDoneButtonWithSelectedAssets:(NSUInteger)selectedAssets {
    //This is not very future proof.
    UIView *view = self.navigationController.navigationBar;
    static NSString *origText;
    
    for(UIView *subview in view.subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UINavigationButton") class]]) {
            //Second button is what we are looking for...
            if([self isRightBarButton:(UIButton *)subview]) {
                UIButton *hopeToBeDoneButton = (UIButton *)subview;
                
                if(!origText) {
                    origText = [hopeToBeDoneButton titleForState:UIControlStateNormal];
                }
                
                if(selectedAssets > 0) {
                    [self setTitleWithoutAnimation:[NSString stringWithFormat:@"%@ (%d)", origText, selectedAssets] forButton:hopeToBeDoneButton];
                } else {
                    [self setTitleWithoutAnimation:origText forButton:hopeToBeDoneButton];
                }
                
                break;
            }
        }
    }
}

- (void)setTitleWithoutAnimation:(NSString *)aTitle forButton:(UIButton *)aButton {
    BOOL wasEnabled = aButton.enabled;
    
    [UIView setAnimationsEnabled:NO];
    [aButton setEnabled:YES];
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setEnabled:wasEnabled];
    [aButton layoutIfNeeded];
    [UIView setAnimationsEnabled:YES];
}

- (BOOL)isRightBarButton:(UIButton *)aButton {
    BOOL isRightBarButton = NO;
    
    //Store previous values
    BOOL wasRightEnabled = self.navigationItem.rightBarButtonItem.enabled;
    BOOL wasButtonEnabled = aButton.enabled;
    
    //Set a known state for both buttons
    [aButton setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    //Change one and see if other also changes
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    isRightBarButton = aButton.enabled == YES;
    
    //Reset
    [self.navigationItem.rightBarButtonItem setEnabled:wasRightEnabled];
    [aButton setEnabled:wasButtonEnabled];
    
    return isRightBarButton;
}

@end