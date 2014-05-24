//
//  BSPhotosModel.h
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-23.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSItemsModel.h"
#import "BSItemsModelDelegate.h"

@class ALAssetsGroup;

@interface BSAssetModel : NSObject <BSItemsModel>

@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, weak) id<BSItemsModelDelegate> delegate;

@end

