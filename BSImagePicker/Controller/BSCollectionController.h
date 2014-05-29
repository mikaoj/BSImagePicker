//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSItemsModel.h"

@protocol BSCollectionViewCellFactory;

@interface BSCollectionController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong) id<BSItemsModel> collectionModel;
@property (nonatomic, strong) id<BSCollectionViewCellFactory> collectionCellFactory;

@property (nonatomic, strong) NSMutableArray *selectedItems;

@end