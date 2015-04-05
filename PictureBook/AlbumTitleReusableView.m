//
//  BHAlbumTitleReusableView.m
//  PictureBook
//
//  Created by greg vandenberg on 1/12/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "AlbumTitleReusableView.h"

@interface AlbumTitleReusableView ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;

@end

@implementation AlbumTitleReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        //self.titleLabel.font = [UIFont boldSystemFontOfSize:48.0f];
        self.titleLabel.font = [UIFont fontWithName:@"Marker Felt" size:18.0f];
        //self.titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.titleLabel.textColor = [UIColor colorWithRed:86.0/255 green:86.0/255 blue:86.0/255 alpha:1.0];
        //self.titleLabel.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"label_bknd.png"]];
        self.titleLabel.layer.cornerRadius = 5;
        self.titleLabel.clipsToBounds = YES;
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.titleLabel.text = nil;
}

@end

