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
#import "BSPhotosController+UICollectionView.h"
#import "BSPhotosController+UITableView.h"

@implementation BSPhotosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];

        //Setup models
        [self setCollectionModel:self.assetsModel];
        [self setTableModel:self.assetsGroupModel];
        
        //Setup collection view
        [self setCollectionView:self.photosCollectionView];
        [self.view addSubview:self.collectionView];
        
        //Setup table view
        [self setTableView:self.albumTableView];
        
        //Set factories
        [self setTableCellFactory:self.albumCellFactory];
        [self setCollectionCellFactory:self.photoCellFactory];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

[self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Setters

- (void)setTableCellFactory:(id<BSTableViewCellFactory>)tableCellFactory {
    _tableCellFactory = tableCellFactory;
    
    [[_tableCellFactory class] registerCellIdentifiersForTableView:self.tableView];
}

- (void)setCollectionCellFactory:(id<BSCollectionViewCellFactory>)collectionCellFactory {
    _collectionCellFactory = collectionCellFactory;
    
    [[_collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
}

@end