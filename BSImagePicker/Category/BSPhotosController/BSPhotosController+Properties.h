//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSPhotosController.h"

@class BSAssetModel;
@class BSAssetsGroupModel;
@class BSPhotoCollectionViewCellFactory;
@class BSPreviewCollectionViewCellFactory;
@class BSAlbumTableViewCellFactory;
@class BSSpeechBubbleView;

@interface BSPhotosController (Properties)

@property (nonatomic, readonly) BSAssetModel *assetsModel;
@property (nonatomic, readonly) BSAssetsGroupModel *assetsGroupModel;

@property (nonatomic, readonly) BSPhotoCollectionViewCellFactory *photoCellFactory;
@property (nonatomic, readonly) BSPreviewCollectionViewCellFactory *previewCellFactory;
@property (nonatomic, readonly) BSAlbumTableViewCellFactory *albumCellFactory;

@property (nonatomic, readonly) UITableView *albumTableView;
@property (nonatomic, readonly) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, readonly) UIView *coverView;

@property (nonatomic, readonly) UICollectionView *photosCollectionView;
@property (nonatomic, readonly) UICollectionView *previewCollectionView;
@property (nonatomic, readonly) UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, readonly) UIButton *albumButton;
@property (nonatomic, readonly) UIBarButtonItem *doneButton;

@end