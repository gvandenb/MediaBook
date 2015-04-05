//
//  RDPresentationAnimator.h
//  PictureBook
//
//  Created by greg vandenberg on 2/21/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface RDPresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL isPresenting;
@property (nonatomic) CGRect senderFrame;

@end