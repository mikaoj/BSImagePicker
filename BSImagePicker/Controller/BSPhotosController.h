//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"
#import "BSTableViewCellFactory.h"
#import "BSPreviewController.h"
#import "BSZoomInAnimator.h"
#import "BSZoomOutAnimator.h"

@class BSAlbumTableViewCellFactory;
@class BSSpeechBubbleView;

@interface BSPhotosController : BSCollectionController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id<BSItemsModel> tableModel;
@property (nonatomic, strong) id<BSTableViewCellFactory> tableCellFactory;

@property (nonatomic, strong) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) BSPreviewController *previewController;

@property (nonatomic, strong) BSZoomInAnimator *zoomInAnimator;
@property (nonatomic, strong) BSZoomOutAnimator *zoomOutAnimator;

- (void)finishButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;
- (void)showAlbumView;
- (void)hideAlbumView;
- (void)itemLongPressed:(UIGestureRecognizer *)recognizer;

@end