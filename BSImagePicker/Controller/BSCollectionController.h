//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSCollectionViewCellFactory;
@protocol BSItemsModel;

@interface BSCollectionController : UIViewController

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) id<BSItemsModel> collectionModel;
@property (nonatomic, weak) id<BSCollectionViewCellFactory> collectionCellFactory;

@property (nonatomic, strong) NSMutableArray *selectedItems;

@end