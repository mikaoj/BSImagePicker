//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController.h"
#import "BSSpeechBubbleView.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSAssetsGroupModel.h"
#import "BSPhotosController+UITableView.h"
#import "BSImagePickerSettings.h"
#import "BSCollectionViewCellFactory.h"

@interface BSPhotosController () <UINavigationControllerDelegate>

@end

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    if([self.selectedItems count] > 0) {
        [self.doneButton setEnabled:YES];
    } else {
        [self.doneButton setEnabled:NO];
    }

    [self.navigationController setDelegate:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView.collectionViewLayout invalidateLayout];
}

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

    CGFloat tableViewHeight = MIN(self.tableView.contentSize.height, 240);
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
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];

        [self.zoomInAnimator setAnimateToRect:cell.frame];
        [self.previewController setOnViewWillAppearScrollToPath:indexPath];
        [self.navigationController pushViewController:self.previewController animated:YES];

        [recognizer setEnabled:YES];
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if(operation == UINavigationControllerOperationPop) {
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