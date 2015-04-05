//
//  PhotoBookFeed.m
//  PictureBook
//
//  Created by greg vandenberg on 1/15/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoBookFeed.h"

@implementation PhotoBookFeed

- (id)init
{
    self = [super init];
    if (self) {
        self.account = [Account alloc];
    }
    return self;
}

@end
