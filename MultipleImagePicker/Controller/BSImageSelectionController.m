//
//  BSImageSelectionController.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-05.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImageSelectionController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSSpeechBubbleView.h"
#import "BSAlbumCell.h"
#import "BSPhotoCell.h"
#import "BSImagePreviewController.h"
#import "BSImagePickerController.h"
#import "BSZoomOutAnimator.h"
#import "BSZoomInAnimator.h"
#import "NSDictionary+ALAsset.h"

static NSString *kPhotoCellIdentifier = @"photoCellIdentifier";
static NSString *kAlbumCellIdentifier = @"albumCellIdentifier";

@interface BSImageSelectionController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@property (nonatomic, strong) NSMutableArray *photoAlbums; //Contains ALAssetsGroup
@property (nonatomic, strong) ALAssetsGroup *selectedAlbum;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, strong) BSImagePreviewController *imagePreviewController;
@property (nonatomic, strong, readonly) BSImagePickerController *navigationController;

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
                } else {
                    [self.photoAlbums addObject:group];
                }
            }
        } failureBlock:nil];
        
        //Navigation bar buttons
        [self.navigationItem setLeftBarButtonItem:self.cancelButton];
        [self.navigationItem setRightBarButtonItem:self.doneButton];
        [self.navigationItem setTitleView:self.albumButton];
        
        //Set navigation controller delegate
        [self.navigationController setDelegate:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
                                          }
                                      }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                             options:0
                                          usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                              if(result) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self.selectedPhotos addObject:result];
                                                  });
                                                  
                                                  if(self.navigationController.toggleBlock) {
                                                      NSDictionary *info = [NSDictionary dictionaryWithAsset:result];
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.navigationController.toggleBlock(info, YES);
                                                      });
                                                  }
                                              }
                                          }];
    });
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                             options:0
                                          usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                              if(result) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [self.selectedPhotos removeObject:result];
                                                  });
                                                  
                                                  if(self.navigationController.toggleBlock) {
                                                      NSDictionary *info = [NSDictionary dictionaryWithAsset:result];
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          self.navigationController.toggleBlock(info, NO);
                                                      });
                                                  }
                                              }
                                          }];
    });
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static CGSize size;
    
    static dispatch_once_t predicate = 0;
    dispatch_once(&predicate, ^{
        [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                             options:0
                                          usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                              //
                                              if(result) {
                                                  //Get thumbnail size
                                                  CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(result.thumbnail), CGImageGetHeight(result.thumbnail));
                                                  
                                                  //We want 3 images in each row. So width should be viewWidth-(4*LEFT/RIGHT_INSET)/3
                                                  //4*10 is edgeinset
                                                  //Height should be adapted so we maintain the aspect ratio of thumbnail
                                                  //original height / original width x new width
                                                  CGSize itemSize = CGSizeMake((collectionView.bounds.size.width - (4*2.0))/3.0, 100);
                                                  size = CGSizeMake(itemSize.width, thumbnailSize.height / thumbnailSize.width * itemSize.width);
                                              }
                                          }];
    });
    
    
    return size;
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
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];

    if([group isEqual:self.selectedAlbum]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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
    [self setSelectedAlbum:group];
    
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
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
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
        [_albumButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _albumButton;
}

- (BSSpeechBubbleView *)speechBubbleView
{
    if(!_speechBubbleView) {
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 300, 320)];
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
    if(self.navigationController.finishBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *infos = [[NSMutableArray alloc] init];
            for(ALAsset *asset in self.selectedPhotos) {
                [infos addObject:[NSDictionary dictionaryWithAsset:asset]];
            }
            [self.selectedPhotos removeAllObjects];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationController.finishBlock([infos copy], sender == self.cancelButton);
            });
        });
    } else {
        [self.selectedPhotos removeAllObjects];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.collectionView reloadData];
    }];
}

- (void)albumButtonPressed:(id)sender
{
    if([self.speechBubbleView isDescendantOfView:self.view]) {
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
        
        //TODO: DON'T DO THAT HERE
        [self.navigationController setDelegate:self];
        
        UIImage *image = [UIImage imageWithCGImage:[[cell.asset defaultRepresentation] fullScreenImage]];
        [self.navigationController pushViewController:self.imagePreviewController animated:YES];
        [self.imagePreviewController.imageView setImage:image];
        [recognizer setEnabled:YES];
    }
    
}

#pragma mark - Something

- (void)setSelectedAlbum:(ALAssetsGroup *)selectedAlbum
{
    _selectedAlbum = selectedAlbum;
    [self.albumButton setTitle:[_selectedAlbum valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];
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
    [self.view addSubview:self.speechBubbleView];
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
                         frame.origin.y = [[UIApplication sharedApplication] statusBarFrame].size.height + 10;
                         frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0;
                         [self.speechBubbleView setFrame:frame];
                     } completion:^(BOOL finished) {
                         [self.speechBubbleView removeFromSuperview];
                         [self.speechBubbleView setFrame:origRect];
                     }];
}

@end
