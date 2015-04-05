//
//  VideoCollectionViewCell.m
//  PictureBook
//
//  Created by greg vandenberg on 2/23/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "VideoCollectionViewCell.h"
#import "VideoCardLabel.h"

@implementation VideoCollectionViewCell

@synthesize titleLabel;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 3.0;
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    self.titleLabel = [[VideoCardLabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, 200, 20)];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"Marker Felt" size:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    return self;
    
}

@end
