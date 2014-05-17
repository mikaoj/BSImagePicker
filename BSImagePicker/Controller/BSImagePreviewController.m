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

#import "BSImagePreviewController.h"
#import "BSPreviewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *kPreviewCellIdentifier = @"PreviewCellIdentifier";

@interface BSImagePreviewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

- (void)registerCollectionViewCellIdentifiers;

@end

@implementation BSImagePreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:NSLocalizedString(@"Preview", @"Preview navigation title")];
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        
        [self.view addSubview:self.collectionView];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Scroll to the correct image
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentAssetIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPreviewCellIdentifier forIndexPath:indexPath];
    
    //Reset zoom
    [cell.scrollView setZoomScale:1.0];
    
    [self.photos enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if(result) {
                                       [cell.imageView setImage:[UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage]];
                                   }
                               }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

#pragma mark - Lazy load

- (UICollectionView *)collectionView
{
    if(!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setMinimumInteritemSpacing:0.0];
        [flowLayout setMinimumLineSpacing:0.0];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setAlwaysBounceHorizontal:YES];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        
        [self registerCollectionViewCellIdentifiers];
    }
    
    return _collectionView;
}

#pragma mark - Private

- (void)registerCollectionViewCellIdentifiers
{
    [self.collectionView registerClass:[BSPreviewCell class] forCellWithReuseIdentifier:kPreviewCellIdentifier];
}

@end
