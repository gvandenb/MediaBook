//
//  BHAlbumPhotoCell.h
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface AlbumPhotoCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteButton;

@end
