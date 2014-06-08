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
#import "BSPhotosController+UITableView.h"
#import "BSCollectionController+UICollectionView.h"

@interface BSPhotosController () <UINavigationControllerDelegate>

@end

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //Set title to empty string, to get rid of "Back" in the back button
        [self setTitle:@" "];
        
        //Register identifiers
        [[self.collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
        [[self.tableCellFactory class] registerCellIdentifiersForTableView:self.tableView];

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
        [self setTableView:nil];
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
    if([self.collectionModel.selectedItems count] > 0) {
        [self.doneButton setEnabled:YES];
    } else {
        [self.doneButton setEnabled:NO];
    }

    [self.navigationController setDelegate:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if(operation == UINavigationControllerOperationPop) {
        //Sync selection
        for(int i = 0; i < [self.collectionModel numberOfItemsInSection:0]; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            
            if([self.collectionModel isItemAtIndexPathSelected:indexPath]) {
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            } else {
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }
        
        return self.zoomOutAnimator;
    } else {
        return self.zoomInAnimator;
    }
}

#pragma mark - Lazy load

- (id<BSItemsModel>)tableModel {
    if(!_tableModel) {
        _tableModel = [[BSAssetsGroupModel alloc] init];
        [_tableModel setDelegate:self];
        [_tableModel setupWithParentItem:[[ALAssetsLibrary alloc] init]];
    }

    return _tableModel;
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
        [[_speechBubbleView contentView] addSubview:self.tableView];
    }

    //Set speechbubble color to match tab bar color
    if(![[BSImagePickerSettings sharedSetting] albumTintColor]) {
        [_speechBubbleView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    }

    return _speechBubbleView;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setBackgroundColor:[UIColor clearColor]];;
        [_tableView setAllowsSelection:YES];
        [_tableView setAllowsMultipleSelection:NO];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];

        [_tableView reloadData];
    }

    return _tableView;
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

- (id<BSTableViewCellFactory>)tableCellFactory {
    if(!_tableCellFactory) {
        _tableCellFactory = [[BSAlbumTableViewCellFactory alloc] init];
    }

    return _tableCellFactory;
}

- (BSPreviewController *)previewController {
    if(!_previewController) {
        _previewController = [[BSPreviewController alloc] initWithNibName:nil bundle:nil];
        [_previewController setCollectionModel:self.collectionModel];
    }

    return _previewController;
}

- (BSZoomInAnimator *)zoomInAnimator {
    if(!_zoomInAnimator) {
        _zoomInAnimator = [[BSZoomInAnimator alloc] init];
    }

    return _zoomInAnimator;
}

- (BSZoomOutAnimator *)zoomOutAnimator {
    if(!_zoomOutAnimator) {
        _zoomOutAnimator = [[BSZoomOutAnimator alloc] init];
    }

    return _zoomOutAnimator;
}

@end