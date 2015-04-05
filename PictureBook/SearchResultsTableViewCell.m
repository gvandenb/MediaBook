//
//  SearchResultsTableViewCell.m
//  PictureBook
//
//  Created by greg vandenberg on 3/6/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "SearchResultsTableViewCell.h"

@implementation SearchResultsTableViewCell

@synthesize imageView;
@synthesize resultsVideoTitleLabel;
@synthesize resultsVideoDescriptionLabel;
@synthesize resultsVideoUrlLabel;
@synthesize resultsVideoDurationLabel;
@synthesize resultsAddButton;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
