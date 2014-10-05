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

#import "BSPreviewCollectionViewCellFactory.h"
#import "BSPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kPhotoCellIdentifier =             @"previewCellIdentifier";

@implementation BSPreviewCollectionViewCellFactory

+ (void)registerCellIdentifiersForCollectionView:(UICollectionView *)aCollectionView {
    [aCollectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
}

+ (CGSize)sizeAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    UIEdgeInsets insets = aCollectionView.contentInset;
    CGSize collectionSize = aCollectionView.bounds.size;
    
    return CGSizeMake(collectionSize.width - (insets.left + insets.right), collectionSize.height - (insets.top + insets.bottom));
}

+ (UIEdgeInsets)edgeInsetAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return UIEdgeInsetsZero;
}

+ (CGFloat)minimumLineSpacingAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return 0.0;
}

+ (CGFloat)minimumItemSpacingAtSection:(NSUInteger)aSection forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    return 0.0;
}

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)anIndexPath forCollectionView:(UICollectionView *)aCollectionView withModel:(id<BSItemsModel>)aModel {
    BSPhotoCell *cell = (BSPhotoCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:anIndexPath];
    ALAsset *asset = [aModel itemAtIndexPath:anIndexPath];
    
    if([asset isKindOfClass:[ALAsset class]]) {
        [cell.fadedCoverView removeFromSuperview];
        [cell.checkmarkView removeFromSuperview];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [cell.imageView setImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation) asset.defaultRepresentation.orientation]];
    }
    
    return cell;
}

@end
