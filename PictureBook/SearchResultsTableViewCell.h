//
//  SearchResultsTableViewCell.h
//  PictureBook
//
//  Created by greg vandenberg on 3/6/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) IBOutlet UILabel *resultsVideoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultsVideoDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultsVideoDurationLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultsVideoUrlLabel;
@property (strong, nonatomic) IBOutlet UIButton *resultsAddButton;

@end
