//
//  AppDelegate.m
//  ExpandingCardPrototype
//
//  Created by Brian Sachetta on 3/25/16.
//  Copyright © 2016 IntrepidPursuits. All rights reserved.
//

#import "AppDelegate.h"
#import "CardViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    CardViewController *cardViewController = [[CardViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = cardViewController;
    return YES;
}

@end
