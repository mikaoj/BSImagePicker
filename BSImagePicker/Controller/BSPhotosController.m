//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSPhotosController.h"
#import "BSItemsModel.h"
#import "BSPhotosController+Properties.h"
#import "BSSpeechBubbleView.h"
#import "BSAlbumTableViewCellFactory.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSAssetsGroupModel.h"
#import "BSAssetModel.h"
#import "BSCollectionViewCellFactory.h"
#import "BSPhotosController+Actions.h"
#import "BSTableViewCellFactory.h"

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(itemLongPressed:)];
        [recognizer setMinimumPressDuration:1.0];
        [self.collectionView addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    //Release these if they aren't visible
    if(![self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        _speechBubbleView = nil;
        _albumTableView = nil;
        _coverView = nil;
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
}

@end