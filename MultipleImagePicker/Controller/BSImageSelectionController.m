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

#import "BSImageSelectionController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSSpeechBubbleView.h"
#import "BSAlbumCell.h"
#import "BSPhotoCell.h"
#import "BSImagePreviewController.h"
#import "BSImagePickerController.h"
#import "BSZoomOutAnimator.h"
#import "BSZoomInAnimator.h"

static NSString *kPhotoCellIdentifier = @"photoCellIdentifier";
static NSString *kAlbumCellIdentifier = @"albumCellIdentifier";

@interface BSImageSelectionController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@property (nonatomic, strong) NSMutableArray *photoAlbums; //Contains ALAssetsGroups
@property (nonatomic, strong) ALAssetsGroup *selectedAlbum;
@property (nonatomic, strong) NSMutableArray *selectedPhotos; //Contains ALAssets

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, strong) BSImagePreviewController *imagePreviewController;
@property (nonatomic, strong, readonly) BSImagePickerController *navigationController;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) BSZoomInAnimator *zoomInAnimator;
@property (nonatomic, strong) BSZoomOutAnimator *zoomOutAnimator;

- (void)finishButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;

- (void)cellLongPressed:(UIGestureRecognizer *)recognizer;

- (void)registerCollectionViewCellIdentifiers;
- (void)registerTableViewCellIdentifiers;
- (void)showAlbumView;
- (void)hideAlbumView;

@end

@implementation BSImageSelectionController

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Add subviews
        [self.view addSubview:self.collectionView];
        
        //TODO: Lazy load?
        //Setup album/photo arrays
        _photoAlbums = [[NSMutableArray alloc] init];
        _selectedPhotos = [[NSMutableArray alloc] init];
        
        //Find all albums
        [[BSImageSelectionController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group) {
                //Default to select saved photos album
                if([[group valueForProperty:ALAssetsGroupPropertyType] isEqual:[NSNumber numberWithInteger:ALAssetsGroupSavedPhotos]]) {
                    [self.photoAlbums insertObject:group atIndex:0];
                    [self setSelectedAlbum:group];
                    
                    //Set default item size if no size already given.
                    if(CGSizeEqualToSize(self.navigationController.itemSize, CGSizeZero)) {
                        //Get thumbnail size
                        CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(group.posterImage), CGImageGetHeight(group.posterImage));
                        
                        //We want 3 images in each row. So width should be viewWidth-(4*LEFT/RIGHT_INSET)/3
                        //4*2.0 is edgeinset
                        //Height should be adapted so we maintain the aspect ratio of thumbnail
                        //original height / original width * new width
                        CGSize itemSize = CGSizeMake((320.0 - (4*2.0))/3.0, 100);
                        [self.navigationController setItemSize:CGSizeMake(itemSize.width, thumbnailSize.height / thumbnailSize.width * itemSize.width)];
                    }
                } else {
                    [self.photoAlbums addObject:group];
                }
            }
        } failureBlock:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Set speechbubble color to match tab bar color
    [self.speechBubbleView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    
    //Navigation bar buttons
    [self.navigationItem setLeftBarButtonItem:self.cancelButton];
    [self.navigationItem setRightBarButtonItem:self.doneButton];
    [self.navigationItem setTitleView:self.albumButton];
    
    //Set navigation controller delegate (needed for the custom animation when going to preview)
    [self.navigationController setDelegate:self];
    
    //Enable/disable done button
    if([self.selectedPhotos count] > 0) {
        [self.doneButton setEnabled:YES];
    } else {
        [self.doneButton setEnabled:NO];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    __block NSInteger numberOfItems = 0;
    
    [self.selectedAlbum enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if([[result valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) {
            ++numberOfItems;
        }
    }];
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    
    if(![self.navigationController previewDisabled]) {
        [cell.longPressRecognizer addTarget:self action:@selector(cellLongPressed:)];
    }
    
    [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                          if(result) {
                                              [cell setAsset:result];
                                              [cell.imageView setImage:[UIImage imageWithCGImage:result.thumbnail]];
                                              
                                              if([self.selectedPhotos containsObject:result]) {
                                                  [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                                                  [cell setSelected:YES];
                                              }
                                          }
                                      }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL allow = NO;
    if([self.selectedPhotos count] < self.navigationController.maximumNumberOfImages) {
        [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                             options:0
                                          usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                              if(result) {
                                                  //Enable done button
                                                  if([self.selectedPhotos count] == 0) {
                                                      [self.doneButton setEnabled:YES];
                                                  }

                                                  [self.selectedPhotos addObject:result];
                                                  
                                                  if(self.navigationController.toggleBlock) {
                                                      self.navigationController.toggleBlock(result, YES);
                                                  }
                                              }
                                          }];
        
        allow = YES;
    }
    
    return allow;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                          if(result) {
                                              if(self.navigationController.toggleBlock) {
                                                  self.navigationController.toggleBlock(result, NO);
                                              }
                                              
                                              [self.selectedPhotos removeObject:result];
                                              
                                              //Disable done button
                                              if([self.selectedPhotos count] == 0) {
                                                  [self.doneButton setEnabled:NO];
                                              }
                                          }
                                      }];
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.navigationController.itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photoAlbums count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.navigationController.itemSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];
    
    if([group isEqual:self.selectedAlbum]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    //Set text color to match navigation bar color
    UIColor *textColor = [self.navigationController.navigationBar.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    if(textColor) {
        [cell.textLabel setTextColor:textColor];
    }
    
    [cell.imageView setImage:[UIImage imageWithCGImage:group.posterImage]];
    [cell.textLabel setText:[group valueForProperty:ALAssetsGroupPropertyName]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result) {
            if(index == 1) {
                [cell.secondImageView setImage:[UIImage imageWithCGImage:result.thumbnail]];
            } else if(index == 2) {
                [cell.thirdImageView setImage:[UIImage imageWithCGImage:result.thumbnail]];
                *stop = YES;
            }
        }
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];
    
    if(![group isEqual:self.selectedAlbum]) {
        if(self.navigationController.resetBlock) {
            self.navigationController.resetBlock([self.selectedPhotos copy], BSImageResetAlbum);
        }
        
        [self setSelectedAlbum:group];
    }
    
    [self hideAlbumView];
}

#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    id <UIViewControllerAnimatedTransitioning> animator = nil;
    
    if(operation == UINavigationControllerOperationPop) {
        animator = self.zoomOutAnimator;
    } else if(operation == UINavigationControllerOperationPush) {
        animator = self.zoomInAnimator;
    }
    
    return animator;
}

#pragma mark - Lazy load views

- (UICollectionView *)collectionView
{
    if(!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setMinimumInteritemSpacing:2.0];
        [flowLayout setMinimumLineSpacing:2.0];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setAllowsMultipleSelection:YES];
        [_collectionView setScrollEnabled:YES];
        [_collectionView setAlwaysBounceVertical:YES];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [self registerCollectionViewCellIdentifiers];
    }
    
    return _collectionView;
}

- (UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(finishButtonPressed:)];
    }
    
    return _cancelButton;
}

- (UIBarButtonItem *)doneButton
{
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(finishButtonPressed:)];
    }
    
    return _doneButton;
}

- (UIButton *)albumButton
{
    if(!_albumButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setFrame:CGRectMake(0, 0, 200, 35)];
        [_albumButton setTitleColor:self.navigationController.view.tintColor forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _albumButton;
}

- (BSSpeechBubbleView *)speechBubbleView
{
    if(!_speechBubbleView) {
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
        [_speechBubbleView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_speechBubbleView.contentView addSubview:self.albumTableView];
    }
    
    return _speechBubbleView;
}

- (UITableView *)albumTableView
{
    if(!_albumTableView) {
        _albumTableView = [[UITableView alloc] init];
        [_albumTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_albumTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_albumTableView setBackgroundColor:[UIColor clearColor]];
        [_albumTableView setDelegate:self];
        [_albumTableView setDataSource:self];
        [self registerTableViewCellIdentifiers];
    }
    
    return _albumTableView;
}

- (UIView *)coverView
{
    if(!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
        [_coverView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAlbumView)];
        [recognizer setNumberOfTapsRequired:1];
        [_coverView addGestureRecognizer:recognizer];
    }
    
    return _coverView;
}

- (BSImagePreviewController *)imagePreviewController
{
    if(!_imagePreviewController) {
        _imagePreviewController = [[BSImagePreviewController alloc] init];
    }
    
    return _imagePreviewController;
}

- (BSZoomInAnimator *)zoomInAnimator
{
    if(!_zoomInAnimator) {
        _zoomInAnimator = [[BSZoomInAnimator alloc] init];
    }
    
    return _zoomInAnimator;
}

- (BSZoomOutAnimator *)zoomOutAnimator
{
    if(!_zoomOutAnimator) {
        _zoomOutAnimator = [[BSZoomOutAnimator alloc] init];
    }
    
    return _zoomOutAnimator;
}

- (BSImagePickerController *)navigationController
{
    return (BSImagePickerController *)[super navigationController];
}

#pragma mark - Button actions

- (void)finishButtonPressed:(id)sender
{
    if(self.navigationController.resetBlock) {
        // Call reset block with array and corresponding action (cancel or done since this method is shared with cancel and done buttons)
        self.navigationController.resetBlock([self.selectedPhotos copy], ( (sender == self.cancelButton) ? BSImageResetCancel:BSImageResetDone ));
    }
    
    //Should we keep the images or not?
    if(!self.navigationController.keepSelection) {
        [self.selectedPhotos removeAllObjects];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.collectionView reloadData];
    }];
}

- (void)albumButtonPressed:(id)sender
{
    if([self.speechBubbleView isDescendantOfView:self.navigationController.view]) {
        [self hideAlbumView];
    } else {
        [self showAlbumView];
    }
}

- (void)cellLongPressed:(UIGestureRecognizer *)recognizer
{
    BSPhotoCell *cell = (BSPhotoCell *)recognizer.view;
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        [recognizer setEnabled:NO];
        
        UIImage *image = [UIImage imageWithCGImage:[[cell.asset defaultRepresentation] fullScreenImage]];
        [self.imagePreviewController.imageView setImage:image];
        [self.navigationController pushViewController:self.imagePreviewController animated:YES];
        
        [recognizer setEnabled:YES];
    }
}

#pragma mark - Something

- (void)setSelectedAlbum:(ALAssetsGroup *)selectedAlbum
{
    _selectedAlbum = selectedAlbum;
    [self.albumButton setTitle:[_selectedAlbum valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];
    
    //Clear arrays
    [self.selectedPhotos removeAllObjects];
    
    //Disable done button
    [self.doneButton setEnabled:NO];
    
    [self.collectionView reloadData];
}

- (void)registerCollectionViewCellIdentifiers
{
    [self.collectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
}

- (void)registerTableViewCellIdentifiers
{
    [self.albumTableView registerClass:[BSAlbumCell class] forCellReuseIdentifier:kAlbumCellIdentifier];
}

- (void)showAlbumView
{
    [self.navigationController.view addSubview:self.coverView];
    
    [self.navigationController.view addSubview:self.speechBubbleView];
    [self.albumTableView reloadData];
    
    CGFloat tableViewHeight = MIN(self.albumTableView.contentSize.height, 240);
    CGRect frame = CGRectMake(0, 0, self.speechBubbleView.frame.size.width, tableViewHeight+7);
    
    //Remember old values
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width;
    
    //Set new frame
    frame.size.height = 0.0;
    frame.size.width = 0.0;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
    [self.speechBubbleView setFrame:frame];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         CGRect frame = self.speechBubbleView.frame;
                         frame.size.height = height;
                         frame.size.width = width;
                         frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
                         [self.speechBubbleView setFrame:frame];
                         
                         [self.coverView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
                     } completion:nil];
}

- (void)hideAlbumView
{
    __block CGRect origRect = self.speechBubbleView.frame;
    
    [self.albumTableView reloadData];
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGRect frame = self.speechBubbleView.frame;
                         frame.size.height = 7.0;
                         frame.size.width = 14.0;
                         frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
                         [self.speechBubbleView setFrame:frame];
                         
                         [self.coverView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
                     } completion:^(BOOL finished) {
                         [self.speechBubbleView removeFromSuperview];
                         [self.speechBubbleView setFrame:origRect];
                         [self.coverView removeFromSuperview];
                     }];
}

@end
