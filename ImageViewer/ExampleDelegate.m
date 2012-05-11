//
//  ExampleDelegate.m
//  ImageViewer
//
//  Created by Adrian Florian on 5/11/12.
//  Copyright (c) 2012 Adrian Florian. All rights reserved.
//

#import "ExampleDelegate.h"

@interface ExampleDelegate ()
-(NSArray *) imageUrls;
@end

@implementation ExampleDelegate
@synthesize imageViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Delegate Example";
    [self.imageViewer setContentMode:UIViewContentModeScaleAspectFill];
    self.imageViewer.delegate = self;
}

#pragma -mark delegate methods

-(int)numberOfImages
{
    return [self.imageUrls count];
}

//do whatever in here and return an UIImageView object
//this example shows the capability of downloading data asyncronously from the network (see the async example for easier implementation)
-(UIImageView *)imageViewForPage:(int)page
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_blue.jpg"]];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("iamge downloader", NULL);
    
    dispatch_async(downloadQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[self.imageUrls objectAtIndex:page]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imgView.image = [UIImage imageWithData:imgData];
        });
    });
    return imgView;
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

#pragma -mark view lifecycle

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
