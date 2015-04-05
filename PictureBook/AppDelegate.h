//
//  AppDelegate.h
//  PictureBook
//
//  Created by greg vandenberg on 1/3/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"
#import "PhotoAlbumLayout.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CollectionViewController *viewController;
    PhotoAlbumLayout *photoAlbumLayout;
    UIImageView *splashView;
}

@property (strong, nonatomic) UIWindow *window;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end

