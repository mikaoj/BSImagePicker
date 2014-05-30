//
//  BSPhotosModel.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-23.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAssetModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BSAssetModel () {
    id<BSItemsModelDelegate> _delegate;
    ALAssetsGroup *_assetsGroup;
}

@property (nonatomic, strong) NSArray *assets;
@property (nonatomic, strong) NSMutableSet *selectedAssets;

@end

@implementation BSAssetModel

- (void)setupWithParentItem:(id)parentItem {
    if([parentItem isKindOfClass:[ALAssetsGroup class]]) {
        _assetsGroup = parentItem;

        NSMutableArray *mutableAssets = [[NSMutableArray alloc] initWithCapacity:_assetsGroup.numberOfAssets];

        [_assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse
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
}
- (id)parentItem {
    return _assetsGroup;
}

- (void)setDelegate:(id<BSItemsModelDelegate>)delegate {
    _delegate = delegate;
}

- (id<BSItemsModelDelegate>)delegate {
    return _delegate;
}

#pragma mark - BSItemsModel

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

#pragma mark - Selection

- (BOOL)isItemAtIndexPathSelected:(NSIndexPath *)anIndexPath {
    return [self.selectedAssets containsObject:[self itemAtIndexPath:anIndexPath]];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)anIndexPath {
    [self.selectedAssets addObject:[self itemAtIndexPath:anIndexPath]];
}
- (void)deselectItemAtIndexPath:(NSIndexPath *)anIndexPath {
    [self.selectedAssets removeObject:[self itemAtIndexPath:anIndexPath]];
}
- (void)clearSelection {
    [self.selectedAssets removeAllObjects];
}
- (NSArray *)selectedItems {
    return [self.selectedAssets allObjects];
}

#pragma mark - Lazy load

- (NSMutableSet *)selectedAssets {
    if(!_selectedAssets) {
        _selectedAssets = [[NSMutableSet alloc] init];
    }

    return _selectedAssets;
}

@end
