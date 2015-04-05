//
//  TIMERUIApplication.h
//  PictureBook
//
//  Created by greg vandenberg on 1/10/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//the length of time before your application "times out". This number actually represents seconds, so we'll have to multiple it by 60 in the .m file
#define kApplicationTimeoutInSeconds 20

//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface TIMERUIApplication : UIApplication
{
    NSTimer     *myidleTimer;
}

-(void)resetIdleTimer;

@end
