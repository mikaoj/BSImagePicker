//
// Created by Joakim Gyllström on 2014-05-28.
// Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSCollectionController+BSItemsModel.h"


@implementation BSCollectionController (BSItemsModel)

- (void)didUpdateModel:(id<BSItemsModel>)aModel {
    NSLog(@"Reload collection view");
    [self.collectionView  reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

@end