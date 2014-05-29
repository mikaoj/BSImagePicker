//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"
#import "BSCollectionViewCellFactory.h"
#import "BSCollectionController+UICollectionView.h"
#import "BSPhotoCollectionViewCellFactory.h"
#import "BSAssetModel.h"

@implementation BSCollectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        //Setup collection view
        [self.view addSubview:self.collectionView];
    }

    return self;
}

#pragma mark - Lazy load

- (NSMutableArray *)selectedItems {
    if(!_selectedItems) {
        _selectedItems = [[NSMutableArray alloc] init];
    }
    
    return _selectedItems;
}

- (id<BSItemsModel>)collectionModel {
    if(!_collectionModel) {
        _collectionModel = [[BSAssetModel alloc] init];
        [_collectionModel setDelegate:self];
    }

    return _collectionModel;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout {
    if(!_collectionViewFlowLayout) {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    }

    return _collectionViewFlowLayout;
}

- (UICollectionView *)collectionView {
    if(!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.collectionViewFlowLayout];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }

    return _collectionView;
}

- (id<BSCollectionViewCellFactory>)collectionCellFactory {
    if(!_collectionCellFactory) {
        _collectionCellFactory = [[BSPhotoCollectionViewCellFactory alloc] init];
    }

    return _collectionCellFactory;
}

@end