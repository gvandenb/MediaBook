//
//  SearchRelatedTableViewCell.h
//  PictureBook
//
//  Created by greg vandenberg on 3/6/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchRelatedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *relatedVideoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *relatedVideoPublisherLabel;
@property (strong, nonatomic) IBOutlet UILabel *relatedVideoDurationLabel;
@property (strong, nonatomic) IBOutlet UILabel *relatedVideoUrlLabel;
@property (strong, nonatomic) IBOutlet UIImageView* relatedImageView;
@property (strong, nonatomic) IBOutlet UIButton* relatedAddButton;

@end
