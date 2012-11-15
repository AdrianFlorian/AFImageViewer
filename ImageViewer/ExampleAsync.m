//
//  ExampleAsync.m
//  ImageViewer
//
//  Created by Adrian Florian on 5/11/12.
//  Copyright (c) 2012 Adrian Florian. All rights reserved.
//

#import "ExampleAsync.h"
#import "AFImageViewer.h"

@interface ExampleAsync ()
-(NSArray *) imageUrls;
@end

@implementation ExampleAsync

@synthesize imageViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Async image loading example";
    self.imageViewer.imagesUrls = [self imageUrls];
    self.imageViewer.contentMode = UIViewContentModeScaleAspectFill;
    self.imageViewer.loadingImage = [UIImage imageNamed:@"dark_blue.jpg"];
    self.imageViewer.tempDownloadedImageSavingEnabled = YES;
    [self.imageViewer setInitialPage:2];
}

-(NSArray *)imageUrls
{
    return [NSArray arrayWithObjects:
            [NSURL URLWithString:@"http://imgs.mi9.com/uploads/landscape/4717/free-the-seaside-landscape-of-maldives-wallpaper_422_84903.jpg"],
            [NSURL URLWithString:@"http://pics4.city-data.com/cpicc/cfiles42848.jpg"],
            [NSURL URLWithString:@"http://www.beautifullife.info/wp-content/uploads/2011/03/16/20.jpg"],
             [NSURL URLWithString:@"http://images.coveralia.com/audio/a/Angels_And_Airwaves-We_Don_t_Need_To_Whisper-Interior_Trasera.jpg"],
        nil];
}

- (void)viewDidUnload
{
    [self setImageViewer:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
