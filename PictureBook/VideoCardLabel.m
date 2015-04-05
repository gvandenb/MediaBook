//
//  VideoCardLabel.m
//  PictureBook
//
//  Created by greg vandenberg on 2/24/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "VideoCardLabel.h"

@implementation VideoCardLabel


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 8, 0, 8};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}


@end
