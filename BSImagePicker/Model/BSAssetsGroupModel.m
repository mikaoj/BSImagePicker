//
//  BSAssetsGroupModel.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAssetsGroupModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BSAssetsGroupModel () {
    ALAssetsLibrary *_assetsLibrary;
    id<BSItemsModelDelegate> _delegate;
}

@property (nonatomic, strong) NSArray *assetGroups;
@property (nonatomic, strong) ALAssetsGroup *selectedGroup;

@end

@implementation BSAssetsGroupModel

- (void)setupWithParentItem:(id)parentItem {
    if([parentItem isKindOfClass:[ALAssetsLibrary class]]) {
        _assetsLibrary = parentItem;

        NSMutableArray *mutableGroups = [[NSMutableArray alloc] init];

        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                //Set saved photos album to be first in the list
                if([[group valueForProperty:ALAssetsGroupPropertyType] isEqual:[NSNumber numberWithInteger:ALAssetsGroupSavedPhotos]]) {
                    [mutableGroups insertObject:group atIndex:0];
                } else {
                    [mutableGroups addObject:group];
                }
            } else {
                //Nil group == the enumeration is done

                //Set selected group to the first album if no previous selection had been made
                if(!self.selectedGroup) {
                    [self setSelectedGroup:[mutableGroups firstObject]];
                }

                [self setAssetGroups:[mutableGroups copy]];

                if(self.delegate) {
                    [self.delegate didUpdateModel:self];
                }
            }
        } failureBlock:^(NSError *error) {
            //TODO: HANDLE ERROR (NO ACCESS)
        }];
    }
}

- (id)parentItem {
    return _assetsLibrary;
}

- (void)setDelegate:(id<BSItemsModelDelegate>)delegate {
    _delegate = delegate;
}

- (id<BSItemsModelDelegate>)delegate {
    return _delegate;
}

#pragma mark BSItemsModel

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)aSection {
    NSUInteger items = 0;
    
    if(aSection == 0) {
        items = [self.assetGroups count];
    }
    
    return items;
}

- (id)itemAtIndexPath:(NSIndexPath *)anIndexPath {
    id anObject = nil;
    
    if(anIndexPath.section == 0 && [self.assetGroups count] > anIndexPath.row) {
        anObject = [self.assetGroups objectAtIndex:anIndexPath.row];
    }
    
    return anObject;
}

#pragma mark - Selection

- (BOOL)isItemAtIndexPathSelected:(NSIndexPath *)anIndexPath {
    return [self.selectedGroup isEqual:[self itemAtIndexPath:anIndexPath]];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)anIndexPath {
    [self setSelectedGroup:[self itemAtIndexPath:anIndexPath]];

    if(self.delegate) {
        [self.delegate didUpdateModel:self];
    }
}
- (void)deselectItemAtIndexPath:(NSIndexPath *)anIndexPath { }

- (void)clearSelection { }

- (NSArray *)selectedItems {
    return [NSArray arrayWithObject:self.selectedGroup];
}

@end
