//
//  PhotoCollectionViewCell.h
//  PictureBook
//
//  Created by greg vandenberg on 3/16/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionThumbViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
