//
//  OSLabel.m
//  PictureBook
//
//  Created by greg vandenberg on 1/9/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "OSLabel.h"

@implementation OSLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(4, 20, 4, 20);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    self.edgeInsets = UIEdgeInsetsMake(4, 20, 4, 20);
    size.width  += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}


@end