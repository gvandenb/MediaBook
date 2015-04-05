//
//  PhotoCollectionViewCell.m
//  PictureBook
//
//  Created by greg vandenberg on 3/16/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectMake(0, 0, 720, 540)];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 720, 540)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.imageView];
    
    return self;
    
}

@end
