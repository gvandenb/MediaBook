//
//  SearchRelatedTableViewCell.m
//  PictureBook
//
//  Created by greg vandenberg on 3/6/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "SearchRelatedTableViewCell.h"

@implementation SearchRelatedTableViewCell

@synthesize relatedImageView;
@synthesize relatedVideoDurationLabel;
@synthesize relatedVideoPublisherLabel;
@synthesize relatedVideoTitleLabel;
@synthesize relatedVideoUrlLabel;
@synthesize relatedAddButton;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
