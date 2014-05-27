//
// Created by Joakim Gyllström on 2014-05-27.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "BSPhotosController+UITableViewDelegate.h"
#import "BSItemsModel.h"
#import "BSPhotosController+Actions.h"
#import "BSPhotosController+Properties.h"
#import "BSAssetModel.h"

@implementation BSPhotosController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ALAssetsGroup *assetsGroup = [self.tableModel itemAtIndexPath:indexPath];

    //Only set if we have choosen a new group
    if(![self.assetsModel.assetGroup isEqual:assetsGroup]) {
        [self.assetsModel setAssetGroup:assetsGroup];
    }

    [self hideAlbumView];
}

@end