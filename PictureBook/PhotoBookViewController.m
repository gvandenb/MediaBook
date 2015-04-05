//
//  PhotoBookViewController.m
//  PictureBook
//
//  Created by greg vandenberg on 3/16/15.
//  Copyright (c) 2015 greg vandenberg. All rights reserved.
//

#import "PhotoBookViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoCollectionThumbViewCell.h"
#import "Photo.h"
#import "PhotoBookUtility.h"

@interface PhotoBookViewController ()

@end

//NSInteger imageIndex = 0;
//NSInteger numPhotos = 0;

@implementation PhotoBookViewController

@synthesize photoCollectionView;
@synthesize photoCollectionViewCell;
@synthesize photoThumbCollectionView;
@synthesize photoThumbCollectionViewCell;
@synthesize currentAlbum;
@synthesize photoPageLabel;
@synthesize homeButton;
@synthesize reloadAudioButton;
@synthesize lastContentOffset;
@synthesize mySynthesizer;
@synthesize audioController;
@synthesize imageIndex;
@synthesize numPhotos;
@synthesize selectedItemIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mySynthesizer = [[AVSpeechSynthesizer alloc] init];
    self.audioController = [[AudioController alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.selectedItemIndexPath = indexPath;
    
    UICollectionViewFlowLayout *verticalFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [verticalFlowLayout setItemSize:CGSizeMake(200, 170)];
    [verticalFlowLayout setHeaderReferenceSize:CGSizeMake(0, 15)];
    [verticalFlowLayout setFooterReferenceSize:CGSizeMake(0, 15)];
    [verticalFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [verticalFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionViewFlowLayout *horizontalFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [horizontalFlowLayout setItemSize:CGSizeMake(720, 540)];
    [horizontalFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    horizontalFlowLayout.minimumInteritemSpacing = 0;
    horizontalFlowLayout.minimumLineSpacing = 0;
    [horizontalFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spellTitle:)];
    
    [photoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"pcvCell"];
    photoCollectionView.tag = 1;
    photoCollectionView.pagingEnabled = YES;
    [photoCollectionView setCollectionViewLayout:horizontalFlowLayout];

    
    [photoThumbCollectionView registerClass:[PhotoCollectionThumbViewCell class] forCellWithReuseIdentifier:@"pctvCell"];
    photoThumbCollectionView.tag = 2;
    [photoThumbCollectionView setCollectionViewLayout:verticalFlowLayout];

    Photo *firstPhotoAlbum = self.currentAlbum.photos[0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:firstPhotoAlbum.title];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(4.0)
                             range:NSMakeRange(0, attributedString.length)];
    self.photoPageLabel.attributedText = attributedString;

    [self.photoPageLabel addGestureRecognizer:tapGestureRecognizer1];
    self.photoPageLabel.userInteractionEnabled = YES;

    [PhotoBookUtility formatLabel:self.photoPageLabel];
    
    numPhotos = self.currentAlbum.photos.count;
    lockSpellAction = NO;
    self.mySynthesizer.delegate = self;
    [self tryPlayUtterance];
    
    [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
    [self.audioController tryPlayRemoteMusic];

}

- (void)spellTitle: (UITapGestureRecognizer *)recognizer {
    Boolean spellCurrentLabel = [[NSUserDefaults standardUserDefaults] boolForKey:@"spellCurrentLabel"];
    if (spellCurrentLabel) {
        if (lockSpellAction == false) {
            [self spellTextLabel: -1 currentPageTitle:[self getCurrentPhotoTitle]];
        }
    }
}

- (void) spellTextLabel: (NSInteger)charCount currentPageTitle: (NSString *)currentPage {
    
    lockSpellAction = true;
    NSString *labelText = [self getCurrentPhotoTitle];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
    charCount++;
    
    int64_t delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * (NSEC_PER_SEC * .8));
    if (charCount < attributedString.length) {
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            if (currentPage == labelText) {
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor yellowColor]
                                         range:NSMakeRange(0, charCount + 1)];
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(4.0)
                                         range:NSMakeRange(0, attributedString.length)];
                photoPageLabel.attributedText = attributedString;
                
                NSString * singleChar = [labelText substringWithRange:NSMakeRange(charCount, 1)];
                AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:singleChar.lowercaseString];
                [mySynthesizer speakUtterance:utterance];
                [self spellTextLabel:charCount currentPageTitle:currentPage];
            }
            else {
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor whiteColor]
                                         range:NSMakeRange(0, attributedString.length)];
                [attributedString addAttribute:NSKernAttributeName
                                         value:@(4.0)
                                         range:NSMakeRange(0, attributedString.length)];
                
                static dispatch_queue_t q=nil;
                q=dispatch_get_global_queue(0,0);
                dispatch_suspend(q);
                q=nil;
                
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    photoPageLabel.attributedText = attributedString;
                    lockSpellAction = false;
                });
                
                return;
            }
        });
    }
    else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self getCurrentPhotoTitle]];
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, attributedString.length)];
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(4.0)
                                 range:NSMakeRange(0, attributedString.length)];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            photoPageLabel.attributedText = attributedString;
        });
        AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:[self getCurrentPhotoTitle]];
        [mySynthesizer speakUtterance:utterance];
        lockSpellAction = false;
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentAlbum.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];
    if (collectionView.tag == 1) {
        static NSString *cellIdentifier = @"pcvCell";
        PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.imageView.image = photoAlbum.image;
        return cell;
    }
    else {
        static NSString *cellIdentifier = @"pctvCell";
        PhotoCollectionThumbViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
            cell.layer.borderColor = [[UIColor redColor] CGColor];
            cell.layer.borderWidth = 4.0;
        } else {
            cell.layer.borderColor = [[UIColor whiteColor] CGColor];
            cell.layer.borderWidth = 3.0;
        }
        cell.imageView.image = photoAlbum.image;
        cell.titleLabel.text = photoAlbum.title;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // always reload the selected cell, so we will add the border to that cell
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (self.selectedItemIndexPath)
    {
        // if we had a previously selected cell
        if ([indexPath compare:self.selectedItemIndexPath] != NSOrderedSame)
        {
            // if it's different, then add that old one to our list of cells to reload, and
            // save the currently selected indexPath
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
        }
    }
    else
    {
        // else, we didn't have previously selected cell, so we only need to save this indexPath for future reference
        self.selectedItemIndexPath = indexPath;
    }
    Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];
    imageIndex = indexPath.item;
    [self.photoCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.photoThumbCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    
    // and now only reload only the cells that need updating
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:photoAlbum.title];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(4.0)
                             range:NSMakeRange(0, attributedString.length)];
    self.photoPageLabel.attributedText = attributedString;
    [self tryPlayUtterance];
    
    [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
    [self.audioController tryPlayRemoteMusic];
    
    // and now only reload only the cells that need updating
    [collectionView reloadItemsAtIndexPaths:indexPaths];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.x)
    {
        didScrollRight = YES;
    }
    else if (self.lastContentOffset < scrollView.contentOffset.x)
    {
        didScrollRight = NO;
    }
    self.lastContentOffset = scrollView.contentOffset.x;
}

- (void)tryPlayUtterance {
    if (!lockSpellAction) {
        lockSpellAction = YES;
        AVSpeechUtterance* utterance = [PhotoBookUtility getAVSpeechUtterance:[self getCurrentPhotoTitle]];
        utterance.preUtteranceDelay = .5;
        [self.mySynthesizer speakUtterance:utterance];
    }
}

- (void)scrollViewDidEndDragging:(UICollectionView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && scrollView.tag == 1) {
        NSArray *indexPaths = [scrollView indexPathsForVisibleItems];
        NSInteger index = 0;
        if ([indexPaths count] > 1) {
            BOOL isIndexLessThan = ((NSIndexPath *)[indexPaths objectAtIndex:0]).item < ((NSIndexPath *)[indexPaths objectAtIndex:1]).item;
            BOOL isIndexGreaterThan = ((NSIndexPath *)[indexPaths objectAtIndex:0]).item > ((NSIndexPath *)[indexPaths objectAtIndex:1]).item;
            if (didScrollRight) {
                index = (isIndexLessThan) ? 0 : 1;
            }
            else {
                index = (isIndexGreaterThan) ? 0 : 1;
            }
        }
        NSIndexPath *indexPath = [indexPaths objectAtIndex:index];
        Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:photoAlbum.title];
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(4.0)
                                 range:NSMakeRange(0, attributedString.length)];
        self.photoPageLabel.attributedText = attributedString;
        
        imageIndex = indexPath.item;
        [self tryPlayUtterance];
        [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
        [self.audioController tryPlayRemoteMusic];
        [self.photoThumbCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        [self collectionView:photoThumbCollectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)scrollViewDidEndDecelerating:(UICollectionView *)scrollView
{

    if (scrollView.tag == 1 ) {
        NSArray *indexPaths = [scrollView indexPathsForVisibleItems];
        NSInteger index = 0;
        if ([indexPaths count] > 1) {
            BOOL isIndexLessThan = ((NSIndexPath *)[indexPaths objectAtIndex:0]).item < ((NSIndexPath *)[indexPaths objectAtIndex:1]).item;
            BOOL isIndexGreaterThan = ((NSIndexPath *)[indexPaths objectAtIndex:0]).item > ((NSIndexPath *)[indexPaths objectAtIndex:1]).item;
            if (didScrollRight) {
                index = (isIndexLessThan) ? 0 : 1;
            }
            else {
                index = (isIndexGreaterThan) ? 0 : 1;
            }
        }
        NSIndexPath *indexPath = [indexPaths objectAtIndex:index];
        Photo *photoAlbum = self.currentAlbum.photos[indexPath.item];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:photoAlbum.title];
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(4.0)
                                 range:NSMakeRange(0, attributedString.length)];
        self.photoPageLabel.attributedText = attributedString;
        imageIndex = indexPath.item;
        [self tryPlayUtterance];

        
        [self.audioController configureAudioPlayerRemote:[self getCurrentAudio]];
        [self.audioController tryPlayRemoteMusic];

        [self.photoThumbCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        [self collectionView:photoThumbCollectionView didSelectItemAtIndexPath:indexPath];

    }
}

- (NSInteger) getImageIndex {
    if (imageIndex > numPhotos-1) {
        imageIndex = 0;
    }
    if (imageIndex < 0) {
        imageIndex = numPhotos - 1;
    }
    return imageIndex;
}

- (UIImage *) getCurrentImage {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return photo.image;
}

- (NSURL *) getCurrentAudio {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return photo.audioURL;
}

- (NSString *) getCurrentPhotoTitle {
    Photo *photo = self.currentAlbum.photos[[self getImageIndex]];
    return [photo getTitle];
}

- (Photo *) getCurrentPhoto {
    return self.currentAlbum.photos[[self getImageIndex]];
}

#pragma mark -
#pragma mark === AVSpeechSynthesizerDelegate ===
#pragma mark -

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    lockSpellAction = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
