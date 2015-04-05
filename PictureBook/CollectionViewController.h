//
//  BHViewController.h
//  PictureBook
//
//  Created by greg vandenberg on 1/11/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoAlbumLayout.h"

@interface CollectionViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, PhotoAlbumLayoutDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate> {
    IBOutlet UIButton *settingsButton;
    IBOutlet UIButton *muteButton;
    BOOL isMuted;
}
    
- (IBAction)unwindToHome:(UIStoryboardSegue *)segue;
- (void)setupAlbumData;
@end
