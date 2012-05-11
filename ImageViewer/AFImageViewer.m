//
//  AFImageViewer.m
//  ImageViewer
//
//  Created by Adrian Florian on 5/11/12.
//  Copyright (c) 2012 Adrian Florian. All rights reserved.
//

#import "AFImageViewer.h"

@interface AFImageViewer()

@property (strong, nonatomic) UIScrollView *imageScrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *downloadedImages;

-(CGRect) imageViewFrame;
-(CGRect) pageControlFrame;

-(int) nb;
-(void) initializeImagesViewer;
-(void) initializeViewControllers;
-(void) loadScrollViewWithPage:(int)page;
-(void) loadImageWithPage:(int)page;
-(void) addImageView:(UIImageView *)imgView 
   toImageScrollView:(UIScrollView *)imgScrollView 
            withPage:(int) page 
     removingSubview:(UIView *) subview;
-(void) reset;
-(void) setContentModeForImageView:(UIImageView *)imgView;
-(UIImageView *)asyncImageViewForPage:(int)page;
-(void)loadNeighborPagesForPage:(int)page;

@end

@implementation AFImageViewer {
    BOOL pageControlUsed;
}

@synthesize imageScrollView = _imageScrollView, viewControllers = _viewControllers, pageControl = _pageControl;

@synthesize images = _images, imagesUrls = _imagesUrls;
@synthesize contentMode = _contentMode;
@synthesize delegate = _delegate;
@synthesize loadingImage = _loadingImage, disableSpinnerWhenLoadinImage = _disableSpinnerWhenLoadinImage, downloadedImages = _downloadedImages, tempDownloadedImageSavingEnabled = _tempDownloadedImageSavingEnabled;

-(void)setCustomPageControl:(UIPageControl *)customPageControl
{
    int currentPage = self.pageControl.currentPage;
    self.pageControl = customPageControl;
    self.pageControl.numberOfPages = self.nb;
    self.pageControl.currentPage = currentPage;
}

-(UIViewContentMode) contentMode
{
    if (!_contentMode) _contentMode = UIViewContentModeScaleAspectFit;
    return _contentMode;
}

-(void)setImages:(NSArray *)images
{
    if (images != _images) {
        _images = images;
        self.pageControl.numberOfPages = images.count;
    }
}

-(NSMutableArray *)downloadedImages
{
    if (!_downloadedImages) _downloadedImages = [NSMutableArray array];
    return _downloadedImages;
}

-(void)setImagesUrls:(NSArray *)imagesUrls
{
    if (!_imagesUrls) {
        _imagesUrls = imagesUrls;
        self.pageControl.numberOfPages = imagesUrls.count;
    }
}

-(void)setDelegate:(id<AFImageViewerDelegate>)delegate
{
    if (!_delegate) {
        _delegate = delegate;
        if ([delegate respondsToSelector:@selector(numberOfImages)]) self.pageControl.numberOfPages = [delegate numberOfImages];
    }
}

-(CGRect)imageViewFrame
{
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20);
}

-(CGRect)pageControlFrame
{
    return CGRectMake(0, [self imageViewFrame].size.height, self.frame.size.width, self.frame.size.height - [self imageViewFrame].size.height);
}

#pragma -mark initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)layoutSubviews
{
    self.imageScrollView.frame = [self imageViewFrame];
    self.pageControl.frame = [self pageControlFrame];
    
    self.imageScrollView.contentSize = CGSizeMake(self.imageScrollView.frame.size.width * self.nb, self.imageScrollView.frame.size.height);
    [self reset];
}

-(void) reset
{
    for (UIImageView *imgView in self.viewControllers) {
        if ((NSNull *) imgView != [NSNull null]) 
            [imgView removeFromSuperview];
    }  
    int imageScrollViewWidth = self.imageScrollView.frame.size.width;
    int imageScrollViewHeight = self.imageScrollView.frame.size.height;
    
    [self initializeViewControllers];
    
    int currentPage = self.pageControl.currentPage;

    [self loadNeighborPagesForPage:self.pageControl.currentPage];
    [self.imageScrollView scrollRectToVisible:CGRectMake(currentPage * imageScrollViewWidth, 0, imageScrollViewWidth, imageScrollViewHeight) animated:NO];
}

-(void)loadNeighborPagesForPage:(int)page
{
    [self loadScrollViewWithPage:page];
    if (page == 0) {
        [self loadScrollViewWithPage:1];
    } else if (page == self.nb) {
        [self loadScrollViewWithPage:self.nb - 1];
    } else {
        [self loadScrollViewWithPage: page - 1];
        [self loadNeighborPagesForPage: page + 1];
    }
}

-(void)initialize
{    
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:[self imageViewFrame]];
    self.pageControl = [[UIPageControl alloc] initWithFrame:[self pageControlFrame]];
    [self addSubview:self.imageScrollView];
    [self addSubview:self.pageControl];
    
    [self initializeImagesViewer];
}

-(void)initializeViewControllers
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < self.nb; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
}

-(void)initializeImagesViewer
{
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    self.pageControl.numberOfPages = self.nb;
    self.pageControl.currentPage = 0;
}

#pragma -mark image view handlers

-(void)loadScrollViewWithPage:(int)page
{
    if ((page < 0) || (page >= self.nb)) return;    
    
    if ((NSNull *)[self.viewControllers objectAtIndex:page] == [NSNull null]) [self loadImageWithPage:page];
}

-(void)setContentModeForImageView:(UIImageView *)imgView
{
    CGSize imageScrollViewSize = self.imageScrollView.frame.size;
    if ((self.contentMode == UIViewContentModeScaleAspectFill) && (imageScrollViewSize.width < imageScrollViewSize.height)) {
        [imgView sizeToFit];
    } else {
        imgView.contentMode = self.contentMode;
    }
}

-(int)nb
{
    if (self.imagesUrls) {
        return [self.imagesUrls count];
    } else {
        if ([self.delegate respondsToSelector:@selector(numberOfImages)]) {
            return [self.delegate numberOfImages];
        } else {
            return [self.images count];
        }
    }
}

-(void) loadImageWithPage:(int)page
{   
    UIImageView *imgView;
    if (self.imagesUrls) {
        imgView = [self asyncImageViewForPage:page];
    } else {
        if ([self.delegate respondsToSelector:@selector(imageViewForPage:)]) {
            imgView = [self.delegate imageViewForPage:page];
        } else {
            if (self.images) imgView = [[UIImageView alloc] initWithImage: [self.images objectAtIndex:page]];
        }
    }
    if (imgView) {        
        [self setContentModeForImageView:imgView];
        
        [self.viewControllers replaceObjectAtIndex:page withObject:imgView];
        
        if (imgView.superview == nil)
        {
            [self addImageView:imgView 
             toImageScrollView:self.imageScrollView 
                      withPage:page
               removingSubview:nil];
        }
    }
}

-(void) addImageView:(UIImageView *)imgView toImageScrollView:(UIScrollView *)imgScrollView withPage:(int) page removingSubview:(UIView *) subview
{
    if(subview) [subview removeFromSuperview];
    
    CGRect frame = imgScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    imgView.frame = frame;
    [imgScrollView addSubview:imgView]; 
}

#pragma -mark scroll view delegate methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (pageControlUsed) return;
    
    CGFloat pageWidth = self.imageScrollView.frame.size.width;
    int page = floor((self.imageScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self loadNeighborPagesForPage:page];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

#pragma -mark async image downloader

-(UIImageView *)asyncImageViewForPage:(int)page
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:self.loadingImage];
    if (self.downloadedImages.count > page) {
        imgView.image = [self.downloadedImages objectAtIndex:page];
    } else {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if (!self.disableSpinnerWhenLoadinImage) {
            CGPoint center = self.imageScrollView.center;
            center.x = self.imageScrollView.bounds.size.width / 2;
            
            spinner.center = center;
            [spinner startAnimating];
            
            [imgView addSubview:spinner];
        }
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("iamge downloader", NULL);
        
        dispatch_async(downloadQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[self.imagesUrls objectAtIndex:page]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.disableSpinnerWhenLoadinImage) [spinner removeFromSuperview];
                UIImage *image = [UIImage imageWithData:imgData];
                if (self.tempDownloadedImageSavingEnabled) [self.downloadedImages addObject:image];
                imgView.image = image;
            });
        });
    }
    return imgView;
}

#pragma -mark other

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
