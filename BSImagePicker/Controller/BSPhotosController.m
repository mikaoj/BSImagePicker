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

#import "BSPhotosController.h"
#import "BSAssetsGroupModel.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSPhotosController+PrivateMethods.h"
#import "BSPhotosController+BSItemsModel.h"
#import "BSCollectionController+UICollectionView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSImagePickerSettings.h"

@interface BSPhotosController () <UINavigationControllerDelegate>

@end

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //Set title to empty string, to get rid of "Back" in the back button
        [self setTitle:@" "];
        
        //Register identifiers
        [[self.collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
        
        //Add table view controller
        [self addChildViewController:self.tableController];

        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView setScrollEnabled:YES];
        [self.collectionView setAlwaysBounceVertical:YES];
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(itemLongPressed:)];
        [recognizer setMinimumPressDuration:0.5];
        [self.collectionView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    //Release these if they aren't visible
    if(![self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        [self setSpeechBubbleView:nil];
        [self setCoverView:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Navigation bar buttons
    [self.navigationItem setLeftBarButtonItem:self.cancelButton];
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    [self.navigationItem setTitleView:self.albumButton];

    //Enable/disable done button
    [self toggleDoneButton];

    [self.navigationController setDelegate:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if(operation == UINavigationControllerOperationPop) {
        [self syncSelectionInModel:self.collectionModel withCollectionView:self.collectionView];
        return self.zoomOutAnimator;
    } else {
        [self.previewController.collectionView reloadData];
        return self.zoomInAnimator;
    }
}

#pragma mark - Lazy load

- (BSTableController *)tableController {
    if(!_tableController) {
        _tableController = [[BSTableController alloc] init];
        [_tableController.tableModel setDelegate:self];
    }
    
    return _tableController;
}

- (UIBarButtonItem *)cancelButton {
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(finishButtonPressed:)];
    }

    return _cancelButton;
}

- (UIBarButtonItem *)doneButton {
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(finishButtonPressed:)];
    }

    return _doneButton;
}

- (UIButton *)albumButton {
    if(!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setFrame:CGRectMake(0, 0, 200, 35)];
        [_albumButton setTitleColor:self.navigationController.view.tintColor forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _albumButton;
}

- (BSSpeechBubbleView *)speechBubbleView {
    if(!_speechBubbleView) {
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
        [_speechBubbleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [[_speechBubbleView contentView] addSubview:self.tableController.tableView];
    }

    //Set speechbubble color to match tab bar color
    if(![[BSImagePickerSettings sharedSetting] albumTintColor]) {
        [_speechBubbleView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    }

    return _speechBubbleView;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        [_coverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlbumView)];
        [recognizer setNumberOfTapsRequired:1];
        [_coverView addGestureRecognizer:recognizer];
    }

    return _coverView;
}

- (BSPreviewController *)previewController {
    if(!_previewController) {
        _previewController = [[BSPreviewController alloc] initWithNibName:nil bundle:nil];
        [_previewController setCollectionModel:self.collectionModel];
    }

    return _previewController;
}

- (BSExpandAnimator *)zoomInAnimator {
    if(!_zoomInAnimator) {
        _zoomInAnimator = [[BSExpandAnimator alloc] init];
    }

    return _zoomInAnimator;
}

- (BSShrinkAnimator *)zoomOutAnimator {
    if(!_zoomOutAnimator) {
        _zoomOutAnimator = [[BSShrinkAnimator alloc] init];
    }

    return _zoomOutAnimator;
}

@end