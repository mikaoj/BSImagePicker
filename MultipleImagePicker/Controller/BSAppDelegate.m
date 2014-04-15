//
//  BSAppDelegate.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-05.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAppDelegate.h"
#import "BSImageSelectionController.h"
#import "BSImagePickerController.h"

@interface BSAppDelegate () <UIImagePickerControllerDelegate>

@property (nonatomic, strong) BSImagePickerController *imagePicker;
@property (nonatomic, strong) UIImagePickerController *oldImagePicker;

@end

@implementation BSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    
    UIButton *pressMe2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 200, 200, 35)];
    [pressMe2 setTitle:@"UIImagePicker" forState:UIControlStateNormal];
    [pressMe2 setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe2 addTarget:self action:@selector(doTheUgly:) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:pressMe2];
    
    UIButton *pressMe = [[UIButton alloc] initWithFrame:CGRectMake(50, 300, 200, 35)];
    [pressMe setTitle:@"BSImagePicker" forState:UIControlStateNormal];
    [pressMe setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe addTarget:self action:@selector(doTheMagic:) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:pressMe];
    
    
    [self setImagePicker:[[BSImagePickerController alloc] init]];
    [self setOldImagePicker:[[UIImagePickerController alloc] init]];
    [self.window setRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}





- (void)doTheUgly:(id)sender
{
    [self.oldImagePicker setDelegate:self];
    
    [self.window.rootViewController presentViewController:self.oldImagePicker animated:YES completion:nil];
}





























- (void)doTheMagic:(id)sender
{
    [self.window.rootViewController presentImagePickerController:self.imagePicker
                                                        animated:YES
                                                      completion:nil
                                                          toggle:^(NSDictionary *info, BOOL selected) {
                                                              if(selected) {
                                                                  NSLog(@"Do logic here for selecting image");
                                                              } else {
                                                                  NSLog(@"Do logic here for deselecting image");
                                                              }
                                                          }
                                                          finish:^(NSArray *infoArray, BOOL canceled) {
                                                              if(canceled) {
                                                                  NSLog(@"Do logic here for picker cancel");
                                                              } else {
                                                                  NSLog(@"Do logic here for picker done");
                                                              }
                                                          }];
}



























@end
