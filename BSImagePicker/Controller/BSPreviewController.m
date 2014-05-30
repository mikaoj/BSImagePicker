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

#import "BSPreviewController.h"
#import "BSPreviewCollectionViewCellFactory.h"
#import "BSCheckmarkView.h"

@interface BSPreviewController ()

- (void)toggleCheckMarkForIndexPath:(NSIndexPath *)anIndexPath;

@end

@implementation BSPreviewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setAutomaticallyAdjustsScrollViewInsets:YES];

        //Setup layout
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        //Setup collection view
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.collectionView setShowsVerticalScrollIndicator:NO];
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView setPagingEnabled:YES];
        [self.collectionView setAlwaysBounceHorizontal:YES];

        //TODO: REMOVE ME
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];

        //Setup factory
        [self setCollectionCellFactory:[[BSPreviewCollectionViewCellFactory alloc] init]];

        //Register identifiers
        [[self.collectionCellFactory class] registerCellIdentifiersForCollectionView:self.collectionView];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.collectionView scrollToItemAtIndexPath:self.onViewWillAppearScrollToPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];

    } completion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self toggleCheckMarkForIndexPath:[NSIndexPath indexPathForItem:round(scrollView.contentOffset.x / scrollView.frame.size.width) inSection:0]];
}

#pragma mark - Lazy load

- (UIBarButtonItem *)checkMarkButton {
    if(!_checkMarkButton) {
        BSCheckmarkView *checkmarkView = [[BSCheckmarkView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [checkmarkView setBackgroundColor:[UIColor clearColor]];
        _checkMarkButton = [[UIBarButtonItem alloc] initWithCustomView:checkmarkView];
    }

    return _checkMarkButton;
}

- (void)toggleCheckMarkForIndexPath:(NSIndexPath *)anIndexPath {
    BOOL isSelected = [self.collectionModel isItemAtIndexPathSelected:anIndexPath];
    BOOL isCheckmarkVisible = self.navigationItem.rightBarButtonItem != nil;

    if(isSelected != isCheckmarkVisible) {
        if(isSelected) {
            [self.navigationItem setRightBarButtonItem:self.checkMarkButton animated:YES];
        } else {
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }
}

@end