//
//  VideoBookTableViewCell.h
//  PictureBook
//
//  Created by greg vandenberg on 3/20/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoBookTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView* resultsImageView;
@property (strong, nonatomic) IBOutlet UITextField *resultsVideoTitleTextField;
@property (strong, nonatomic) IBOutlet UILabel *resultsVideoUrlLabel;

@end
