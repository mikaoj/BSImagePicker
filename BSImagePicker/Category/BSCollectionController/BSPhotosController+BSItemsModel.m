//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+BSItemsModel.h"

@implementation BSPhotosController (BSItemsModel)

- (void)didUpdateModel:(id<BSItemsModel>)aModel {
    if(aModel == self.tableModel) {
        NSLog(@"Reload table view");
        [self.tableView reloadData];

        ALAssetsGroup *assetsGroup = [[self.tableModel selectedItems] firstObject];

        [self.albumButton setTitle:[assetsGroup valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];

        [self.collectionModel setupWithParentItem:assetsGroup];
    } else {
        [super didUpdateModel:aModel];
    }
}

@end