//
//  NonRotatingUIImagePickerController.m
//  PictureBook
//
//  Created by greg vandenberg on 2/1/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NonRotatingUIImagePickerController.h"

@implementation NonRotatingUIImagePickerController : UIImagePickerController
// Disable Landscape mode.
- (BOOL)shouldAutorotate
{
    return NO;
}
@end