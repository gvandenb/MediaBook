//
//  AppDelegate.m
//  PictureBook
//
//  Created by greg vandenberg on 1/3/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "AppDelegate.h"
#import "TIMERUIApplication.h"

#ifndef NSFoundationVersionNumber_iOS_7_1
# define NSFoundationVersionNumber_iOS_7_1 1047.25
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)isNotRotatedBySystem{
    BOOL OSIsBelowIOS8 = [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0;
    BOOL SDKIsBelowIOS8 = floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1;
    return OSIsBelowIOS8 || SDKIsBelowIOS8;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([self isNotRotatedBySystem]) {
        
    }
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    [_window makeKeyAndVisible];
    [_window addSubview:viewController.view];
    //self.window.rootViewController = viewController;
    application.statusBarOrientation = UIInterfaceOrientationLandscapeRight;

    // Make this interesting.
    splashView = [[UIImageView alloc] initWithFrame:self.window.frame];
    
    UIImage *originalImage = [UIImage imageNamed:@"splash.png"];
    
    NSInteger imageOrientation = UIImageOrientationLeft;
    NSInteger appOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"orientation: %ld", appOrientation);
    if (appOrientation == UIInterfaceOrientationLandscapeRight) {
        imageOrientation = UIImageOrientationRight;
    }
    UIImage *imageToDisplay = [UIImage imageWithCGImage:[originalImage CGImage]
                        scale:1.0
                        orientation: imageOrientation];
    splashView.image = imageToDisplay;
    [_window addSubview:splashView];
    [_window bringSubviewToFront:splashView];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:5.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    splashView.alpha = 0.0;
    splashView.frame = self.window.frame;
    [UIView commitAnimations];
    
    return YES;
}

-(void)applicationDidTimeout:(NSNotification *) notif
{
    NSLog (@"time exceeded!!");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [splashView removeFromSuperview];
    //[splashView release];
}

@end
