// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [parentItem setAssetsFilter:onlyPhotosFilter];

        [_assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result) {
                [mutableAssets addObject:result];
            } else {
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
    return ( [self.assets count] > 0 ? 1:0 );
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
