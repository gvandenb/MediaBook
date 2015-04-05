//
//  PhotoBookViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 3/16/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Album.h"
#import "AudioController.h"

@interface PhotoBookViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, AVSpeechSynthesizerDelegate>
{
    BOOL didScrollRight;
    BOOL lockSpellAction;
}

@property (nonatomic, retain) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, retain) IBOutlet UICollectionViewCell *photoCollectionViewCell;
@property (nonatomic, retain) IBOutlet UICollectionView *photoThumbCollectionView;
@property (nonatomic, retain) IBOutlet UICollectionViewCell *photoThumbCollectionViewCell;
@property (strong, nonatomic) Album *currentAlbum;
@property (nonatomic, retain) IBOutlet UILabel *photoPageLabel;
@property (nonatomic, retain) IBOutlet UIButton *homeButton;
@property (nonatomic, retain) IBOutlet UIButton *reloadAudioButton;
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) NSInteger numPhotos;
@property (nonatomic) NSInteger imageIndex;
@property (strong, nonatomic) AudioController *audioController;
@property (strong, nonatomic) AVSpeechSynthesizer* mySynthesizer;
@property (nonatomic, retain) NSIndexPath *selectedItemIndexPath;




@end
