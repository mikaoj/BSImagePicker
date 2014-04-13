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

static NSString *kPhotoCellIdentifier = @"photoCellIdentifier";
static NSString *kAlbumCellIdentifier = @"albumCellIdentifier";

@interface BSImageSelectionController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIToolbarDelegate, UITableViewDataSource, UITableViewDelegate>

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@property (nonatomic, strong) NSMutableArray *photoAlbums; //Contains ALAssetsGroup
@property (nonatomic, strong) ALAssetsGroup *selectedAlbum;
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *albumTableView;
@property (nonatomic, strong) BSSpeechBubbleView *speechBubbleView;
@property (nonatomic, strong) BSImagePreviewController *imagePreviewController;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

- (void)cancelButtonPressed:(id)sender;
- (void)doneButtonPressed:(id)sender;
- (void)albumButtonPressed:(id)sender;

- (void)registerCellIdentifiers;

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
        //Default to shitloads of images
        _maximumNumberOfImages = NSUIntegerMax;
        
        //Add subviews
        [self.view addSubview:self.collectionView];
        
        //Setup album/photo arrays
        _photoAlbums = [[NSMutableArray alloc] init];
        _photos = [[NSMutableArray alloc] init];
        
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
        } failureBlock:^(NSError *error) {
        }];
        
        //Navigation bar buttons
        [self.navigationItem setLeftBarButtonItem:self.cancelButton];
        [self.navigationItem setRightBarButtonItem:self.doneButton];
        [self.navigationItem setTitleView:self.albumButton];
        
        [self registerCellIdentifiers];
    }
    return self;
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
    return [self.selectedAlbum numberOfAssets];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
    
    [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                          if(result) {
                                              [cell.imageView setImage:[UIImage imageWithCGImage:result.aspectRatioThumbnail]];
                                          }
                                      }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                          if(result) {
                                              [self.photos addObject:result];
                                              
                                              if(self.selectionBlock) {
                                                  self.selectionBlock();
                                              }
                                          }
                                      }];
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedAlbum enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                          if(result) {
                                              [self.photos removeObject:result];
                                              
                                              if(self.unselectionBlock) {
                                                  self.unselectionBlock();
                                              }
                                          }
                                      }];
    
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
                                                  CGSize thumbnailSize = CGSizeMake(CGImageGetWidth(result.aspectRatioThumbnail), CGImageGetHeight(result.aspectRatioThumbnail));
                                                  
                                                  //We want 3 images in each row. So width should be viewWidth-(4*LEFT/RIGHT_INSET)/3
                                                  //4*10 is edgeinset
                                                  //Height should be adapted so we maintain the aspect ratio of thumbnail
                                                  //original height / original width x new width
                                                  CGSize itemSize = CGSizeMake((collectionView.bounds.size.width - (4*5.0))/3.0, 100);
                                                  size = CGSizeMake(itemSize.width, thumbnailSize.height / thumbnailSize.width * itemSize.width);
                                              }
                                          }];
    });
    
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSAlbumCell *cell = [[BSAlbumCell alloc] init];
    
    ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];

    if([group isEqual:self.selectedAlbum]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [cell.imageView setImage:[UIImage imageWithCGImage:group.posterImage scale:1.0 orientation:UIImageOrientationUp]];
    [cell.textLabel setText:[group valueForProperty:ALAssetsGroupPropertyName]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [self.photoAlbums objectAtIndex:indexPath.row];
    [self setSelectedAlbum:group];
    
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
                     }];
}

#pragma mark - Lazy load views

- (UICollectionView *)collectionView
{
    if(!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setMinimumInteritemSpacing:5.0];
        [flowLayout setMinimumLineSpacing:5.0];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
        [_collectionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView setAllowsMultipleSelection:YES];
        [_collectionView setScrollEnabled:YES];
        [_collectionView setAlwaysBounceVertical:YES];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
    
    return _collectionView;
}

- (UIBarButtonItem *)cancelButton
{
    if(!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(cancelButtonPressed:)];
    }
    
    return _cancelButton;
}

- (UIBarButtonItem *)doneButton
{
    if(!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(doneButtonPressed:)];
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
        _speechBubbleView = [[BSSpeechBubbleView alloc] initWithFrame:CGRectMake(0, 0, 240, 320)];
        [_speechBubbleView.contentView addSubview:self.albumTableView];
    }
    
    return _speechBubbleView;
}

- (UITableView *)albumTableView
{
    if(!_albumTableView) {
        _albumTableView = [[UITableView alloc] init];
        [_albumTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_albumTableView setBackgroundColor:[UIColor clearColor]];
        [_albumTableView setDelegate:self];
        [_albumTableView setDataSource:self];
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

#pragma mark - Button actions

- (void)cancelButtonPressed:(id)sender
{
    if(self.cancelBlock) {
        self.cancelBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonPressed:(id)sender
{
    if(self.doneBlock) {
        self.doneBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)albumButtonPressed:(id)sender
{
    [self.view addSubview:self.speechBubbleView];
    [self.albumTableView reloadData];
    
    CGFloat tableViewHeight = MIN(self.albumTableView.contentSize.height, 160);
    CGRect frame = CGRectMake(0, 0, 240, tableViewHeight+7);
    
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
                     } completion:^(BOOL finished) {
//                         [self.speechBubbleView removeFromSuperview];
                     }];
}

#pragma mark - Something

- (void)setSelectedAlbum:(ALAssetsGroup *)selectedAlbum
{
    _selectedAlbum = selectedAlbum;
    [self.albumButton setTitle:[_selectedAlbum valueForProperty:ALAssetsGroupPropertyName] forState:UIControlStateNormal];
    [self.collectionView reloadData];
}

- (void)registerCellIdentifiers
{
    [self.collectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    [self.albumTableView registerClass:[BSAlbumCell class] forCellReuseIdentifier:kAlbumCellIdentifier];
}

@end
