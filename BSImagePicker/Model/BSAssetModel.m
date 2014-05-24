//
//  BSPhotosModel.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-23.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BSAssetModel ()

@property (nonatomic, strong) NSArray *assets;

@end

@implementation BSAssetModel

- (void)setAssetGroup:(ALAssetsGroup *)assetGroup {
    _assetGroup = assetGroup;
    
    NSMutableArray *mutableAssets = [[NSMutableArray alloc] initWithCapacity:_assetGroup.numberOfAssets];
    
    [_assetGroup enumerateAssetsWithOptions:NSEnumerationReverse
                                 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                     if([[result valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) {
                                         [mutableAssets addObject:result];
                                     } else if(result == nil) {
                                         [self setAssets:[mutableAssets copy]];
                                         
                                         //Enumeration done
                                         if(self.delegate) {
                                             [self.delegate didUpdateModel:self];
                                         }
                                     }
                                 }];
}

#pragma mark BSItemsModel

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)aSection {
    NSUInteger items = 0;
    
    if(aSection == 0) {
        items = [self.assets count];
    }
    
    return items;
}

- (id)itemAtIndexPath:(NSIndexPath *)anIndexPath {
    id anObject = nil;
    
    if(anIndexPath.section == 0 && [self.assets count] > anIndexPath.row) {
        anObject = [self.assets objectAtIndex:anIndexPath.row];
    }
    
    return anObject;
}

@end
