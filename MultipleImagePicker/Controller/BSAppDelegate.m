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

@interface BSAppDelegate ()

@property (nonatomic, strong) BSImagePickerController *imagePicker;

@end

@implementation BSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    UIButton *pressMe = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 35)];
    [pressMe setTitle:@"Press me" forState:UIControlStateNormal];
    [pressMe setTitleColor:viewController.view.tintColor forState:UIControlStateNormal];
    [pressMe addTarget:self action:@selector(doTheMagic:) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:pressMe];
    
    
    [self setImagePicker:[[BSImagePickerController alloc] init]];
    [self.window setRootViewController:viewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
                                                      } finish:^(NSArray *infoArray, BOOL canceled) {
                                                          if(canceled) {
                                                              NSLog(@"Do logic here for picker cancel");
                                                          } else {
                                                              NSLog(@"Do logic here for picker done");
                                                          }
                                                      }];
}

@end
