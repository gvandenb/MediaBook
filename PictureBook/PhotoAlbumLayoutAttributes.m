//
//  PhotoAlbumLayoutAttributes.m
//  PictureBook
//
//  Created by greg vandenberg on 2/20/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoAlbumLayoutAttributes.h"

@implementation PhotoAlbumLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    PhotoAlbumLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.deleteButtonHidden = _deleteButtonHidden;
    return attributes;
}

- (BOOL)isEqual:(id)other {
    return NO;
}
@end