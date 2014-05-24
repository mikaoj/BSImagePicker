//
//  BSAssetsGroupModel.m
//  BSImagePicker
//
//  Created by Joakim Gyllström on 2014-05-24.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAssetsGroupModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface BSAssetsGroupModel ()

@property (nonatomic, strong) NSArray *assetGroups;

@end

@implementation BSAssetsGroupModel

- (void)setAssetsLibrary:(ALAssetsLibrary *)assetsLibrary {
    _assetsLibrary = assetsLibrary;
    
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
                                          [self setAssetGroups:[mutableGroups copy]];
                                          
                                          if(self.delegate) {
                                              [self.delegate didUpdateModel:self];
                                          }
                                      }
                                  } failureBlock:^(NSError *error) {
                                      //TODO: HANDLE ERROR (NO ACCESS)
                                  }];
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

@end
