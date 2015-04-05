//
//  BHAlbumPhotoCell.m
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//
#define MARGIN 2

#import "AlbumPhotoCell.h"
#import "ColorBookViewController.h"
#import "PhotoAlbumLayoutAttributes.h"

@interface AlbumPhotoCell ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end

static UIImage *deleteButtonImg;

@implementation AlbumPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        
        //self.layer.borderColor = [UIColor whiteColor].CGColor;
        //self.layer.borderWidth = 3.0f;
        //self.layer.cornerRadius = 20;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;

        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        //self.clipsToBounds = YES;
        // make sure we rasterize nicely for retina
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.borderWidth = 1;
        self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageView.layer.cornerRadius = 20;
        self.imageView.layer.backgroundColor = [UIColor clearColor].CGColor;
        [self.contentView addSubview:self.imageView];
        
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(-12, -12, frame.size.width/4, frame.size.width/4)];
        
        
        if (!deleteButtonImg)
        {
//            CGRect buttonFrame = self.deleteButton.frame;
//            UIGraphicsBeginImageContext(buttonFrame.size);
//            CGFloat sz = MIN(buttonFrame.size.width, buttonFrame.size.height);
//            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonFrame.size.width/2, buttonFrame.size.height/2) radius:sz/2-MARGIN startAngle:0 endAngle:M_PI * 2 clockwise:YES];
//            [path moveToPoint:CGPointMake(MARGIN, MARGIN)];
//            [path addLineToPoint:CGPointMake(sz-MARGIN, sz-MARGIN)];
//            [path moveToPoint:CGPointMake(MARGIN, sz-MARGIN)];
//            [path addLineToPoint:CGPointMake(sz-MARGIN, MARGIN)];
//            [[UIColor redColor] setFill];
//            [[UIColor whiteColor] setStroke];
//            [path setLineWidth:3.0];
//            [path fill];
//            [path stroke];
//            deleteButtonImg = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
        }
        deleteButtonImg = [UIImage imageNamed:@"delete_button.png"];
        [self.deleteButton setImage:deleteButtonImg forState:UIControlStateNormal];
        [self.contentView addSubview:self.deleteButton];
        
    }
    return self;
}

+ (Class)layoutAttributesClass
{
    return [PhotoAlbumLayoutAttributes class];
}

- (void)applyLayoutAttributes:(PhotoAlbumLayoutAttributes *)layoutAttributes
{    
    if (layoutAttributes.deleteButtonHidden)
    {
        self.deleteButton.layer.opacity = 0.0;
        [self stopQuivering];
    }
    else
    {
        self.deleteButton.layer.opacity = 1.0;
        [self startQuivering];
        
    }
}

- (void)startQuivering
{
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-2) * M_PI/180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.2;
    quiverAnim.repeatCount = HUGE_VALF;
    float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    CALayer *layer = self.layer;
    [layer addAnimation:quiverAnim forKey:@"quivering"];
}

- (void)stopQuivering
{
    CALayer *layer = self.layer;
    [layer removeAnimationForKey:@"quivering"];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.imageView.frame = bounds;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        _imageView.alpha = .7f;
    }else {
        _imageView.alpha = 1.f;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    
}



@end