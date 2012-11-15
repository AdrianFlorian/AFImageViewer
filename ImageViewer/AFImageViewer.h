//
//  AFImageViewer.h
//  ImageViewer
//
//  Created by Adrian Florian on 5/11/12.
//  Copyright (c) 2012 Adrian Florian. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AFImageViewerDelegate<NSObject>
-(UIImageView *) imageViewForPage:(int) page;
-(int) numberOfImages;
@end

@interface AFImageViewer : UIView<UIScrollViewDelegate> 

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *imagesUrls;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic) BOOL disableSpinnerWhenLoadinImage;

@property (nonatomic) BOOL tempDownloadedImageSavingEnabled;

@property (nonatomic) UIViewContentMode contentMode;

@property (nonatomic, weak) id<AFImageViewerDelegate> delegate;

-(void) setCustomPageControl:(UIPageControl *) customPageControl;

-(void)setInitialPage:(NSInteger)page;
-(NSInteger)currentPage;

@end
