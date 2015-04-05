//
//  BHPhotoAlbumLayout.m
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoAlbumLayout.h"
#import "AlbumPhotoCell.h"
#import "PhotoAlbumLayoutAttributes.h"

static NSUInteger const RotationCount = 48;
static NSUInteger const RotationStride = 6;
static NSUInteger const PhotoCellBaseZIndex = 100;

static NSString * const BHPhotoAlbumLayoutPhotoCellKind = @"PhotoCell";
NSString * const BHPhotoAlbumLayoutAlbumTitleKind = @"AlbumTitle";

@interface PhotoAlbumLayout () 

@property (nonatomic, strong) NSDictionary *layoutInfo;
@property (nonatomic, strong) NSArray *rotations;

- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath;
- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath;
- (CATransform3D)transformForAlbumPhotoAtIndex:(NSIndexPath *)indexPath;

@end

@implementation PhotoAlbumLayout

#pragma mark - Properties

- (void)setItemInsets:(UIEdgeInsets)itemInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(_itemInsets, itemInsets)) return;
    
    _itemInsets = itemInsets;
    
    [self invalidateLayout];
}


- (void)setInterItemSpacingY:(CGFloat)interItemSpacingY
{
    if (_interItemSpacingY == interItemSpacingY) return;
    
    _interItemSpacingY = interItemSpacingY;
    
    [self invalidateLayout];
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns
{
    if (_numberOfColumns == numberOfColumns) return;
    
    _numberOfColumns = numberOfColumns;
    
    [self invalidateLayout];
}

- (void)setTitleHeight:(CGFloat)titleHeight
{
    if (_titleHeight == titleHeight) return;
    
    _titleHeight = titleHeight;
    
    [self invalidateLayout];
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}



- (void)setup
{
    self.itemSize = CGSizeMake(180, 180);
    //self.minimumInteritemSpacing = 4;
    //self.minimumLineSpacing = 4;
    self.interItemSpacingY = 20;
    //self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemInsets = UIEdgeInsetsMake(64, 32, 32, 32);
    //[self adjustSpacingForBounds:[[UIScreen mainScreen] bounds]];
    self.titleHeight = 26.0f;
    
    // create rotations at load so that they are consistent during prepareLayout
    NSMutableArray *rotations = [NSMutableArray arrayWithCapacity:RotationCount];
    
    CGFloat percentage = 0.0f;
    for (NSInteger i = 0; i < RotationCount; i++) {
        // ensure that each angle is different enough to be seen
        CGFloat newPercentage = 0.0f;
        do {
            newPercentage = ((CGFloat)(arc4random() % 220) - 110) * 0.0001f;
        } while (fabsf(percentage - newPercentage) < 0.006);
        percentage = newPercentage;
        
        CGFloat angle = 2 * M_PI * (1.0f + percentage);
        CATransform3D transform = CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
        
        [rotations addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    self.rotations = rotations;
    
}

- (void)adjustSpacingForBounds:(CGRect)newBounds {
    //NSInteger count = newBounds.size.width / self.itemSize.width - 1;
    
    //CGFloat spacing = (newBounds.size.width - (self.itemSize.width * count)) / count;
    
    //self.minimumLineSpacing = spacing;
    
    //UIEdgeInsets insets = self.sectionInset;
    //insets.left = spacing/2.0f;
    //self.sectionInset = insets;
}

#pragma mark - Layout

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *titleLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < itemCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            PhotoAlbumLayoutAttributes *itemAttributes =
                [PhotoAlbumLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
            itemAttributes.transform3D = [self transformForAlbumPhotoAtIndex:indexPath];
            itemAttributes.zIndex = PhotoCellBaseZIndex + itemCount - item;
            if (indexPath.item == 0) {
                if ([self isDeletionModeOn])
                    itemAttributes.deleteButtonHidden = NO;
                else
                    itemAttributes.deleteButtonHidden = YES;
            }
            else {
                itemAttributes.deleteButtonHidden = YES;
            }

            cellLayoutInfo[indexPath] = itemAttributes;
            
            if (indexPath.item == 0) {
                PhotoAlbumLayoutAttributes *titleAttributes = [PhotoAlbumLayoutAttributes
                    layoutAttributesForSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind withIndexPath:indexPath];
                titleAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];
                
                titleLayoutInfo[indexPath] = titleAttributes;
            }
        }
    }
    newLayoutInfo[BHPhotoAlbumLayoutPhotoCellKind] = cellLayoutInfo;
    newLayoutInfo[BHPhotoAlbumLayoutAlbumTitleKind] = titleLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (PhotoAlbumLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[BHPhotoAlbumLayoutPhotoCellKind][indexPath];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          PhotoAlbumLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (indexPath.item == 0) {
         
                if ([self isDeletionModeOn])
                    attributes.deleteButtonHidden = NO;
                else
                    attributes.deleteButtonHidden = YES;
            }
            else {
                attributes.deleteButtonHidden = YES;
            }
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                
                [allAttributes addObject:attributes];
            }
            
        }];
    }];
    
    return allAttributes;
}



- (CGSize)collectionViewContentSize
{
    NSInteger columnCount = [self.collectionView numberOfSections] / 3;
    // make sure we count another row if one is only partially filled
    if ([self.collectionView numberOfSections] % 3) columnCount++;
    NSInteger page = columnCount / 4;
    if (columnCount % 4) page++;
    return CGSizeMake(page * self.collectionView.bounds.size.width, 768);
    
}


#pragma mark - Private
- (CGRect)frameForAlbumPhotoAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = floorf(indexPath.section / 4);
    NSInteger column = indexPath.section % 4;
    NSInteger verticalItemsCount = 3;
    NSInteger horizontalItemsCount = 4;
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
    NSInteger itemPage = floorf(indexPath.section/itemsPerPage);
    
    CGFloat spacingX = self.collectionView.bounds.size.width -
    self.itemInsets.left -
    self.itemInsets.right -
    (4 * self.itemSize.width);
    
    if (4 > 1) spacingX = spacingX / (4 - 1);
    
    CGFloat originX = (itemPage * self.collectionView.bounds.size.width) + floorf(self.itemInsets.left + (self.itemSize.width + spacingX) * column+1);
    
    CGFloat originY = floor(self.itemInsets.top +
                            (self.itemSize.height + self.titleHeight + self.interItemSpacingY) * row+1) - (itemPage * (self.collectionView.bounds.size.height - (self.itemSize.height / 2)));
    
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
    
}

- (CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self frameForAlbumPhotoAtIndexPath:indexPath];
    frame.origin.y += frame.size.height;
    frame.size.height = self.titleHeight;
    
    return frame;
}

- (PhotoAlbumLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[BHPhotoAlbumLayoutAlbumTitleKind][indexPath];
}

- (CATransform3D)transformForAlbumPhotoAtIndex:(NSIndexPath *)indexPath
{
    
    NSInteger offset = (indexPath.section * RotationStride + indexPath.item);
    return [self.rotations[offset % RotationCount] CATransform3DValue];
}

- (BOOL)isDeletionModeOn
{
    if ([[self.collectionView.delegate class] conformsToProtocol:@protocol(PhotoAlbumLayoutDelegate)])
    {
        return [(id)self.collectionView.delegate isDeletionModeActiveForCollectionView:self.collectionView layout:self];
        
    }
    return NO;
    
}


@end