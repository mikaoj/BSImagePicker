//
//  BSCollectionController.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSItemsModel.h"
#import "BSCollectionViewCellFactory.h"

@interface BSCollectionController : UICollectionViewController

@property (nonatomic, strong) id<BSItemsModel> model;
@property (nonatomic, strong) id<BSCollectionViewCellFactory> cellFactory;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

@end
