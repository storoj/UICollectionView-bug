//
//  AppDelegate.m
//  UICollectionView-bug
//
//  Created by Alexey Storozhev on 22/01/16.
//  Copyright © 2016 Aleksey Storozhev. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Runtime-Samples.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];

    [window makeKeyAndVisible];
    self.window = window;
    
#define RUNTIME_TEST 0
    
#if (RUNTIME_TEST)
    [TestClass test];
    NSLog(@"=== HOOK ===");
    [TestClass hook];
    [TestClass test];
#endif
    return YES;
}

@end
