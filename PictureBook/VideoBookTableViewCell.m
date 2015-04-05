//
//  VideoBookTableViewCell.m
//  PictureBook
//
//  Created by greg vandenberg on 3/20/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "VideoBookTableViewCell.h"

@implementation VideoBookTableViewCell

@synthesize resultsImageView;
@synthesize resultsVideoTitleTextField;
@synthesize resultsVideoUrlLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
