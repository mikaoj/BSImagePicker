//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController.h"
#import "BSCollectionViewCellFactory.h"
#import "BSItemsModel.h"
#import "BSCollectionController+UICollectionView.h"


@implementation BSCollectionController

- (void)setCollectionCellFactory:(id<BSCollectionViewCellFactory>)collectionCellFactory {
    _collectionCellFactory = collectionCellFactory;
    
    [[_collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
}

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
}

- (NSMutableArray *)selectedItems {
    if(!_selectedItems) {
        _selectedItems = [[NSMutableArray alloc] init];
    }
    
    return _selectedItems;
}

@end