//
//  BSAppDelegate.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-05.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSAppDelegate.h"
#import "BSImagePickerController.h"

@implementation BSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    BSImagePickerController *imagePicker = [[BSImagePickerController alloc] init];
    [self.window setRootViewController:imagePicker];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
