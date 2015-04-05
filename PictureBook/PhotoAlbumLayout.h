//
//  BHPhotoAlbumLayout.h
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const BHPhotoAlbumLayoutAlbumTitleKind;

@protocol PhotoAlbumLayoutDelegate

@required

- (BOOL)isDeletionModeActiveForCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout;

@end

@interface PhotoAlbumLayout : UICollectionViewLayout

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) CGFloat titleHeight;

@end
