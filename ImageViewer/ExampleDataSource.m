//
//  ExampleDataSource.m
//  ImageViewer
//
//  Created by Adrian Florian on 5/11/12.
//  Copyright (c) 2012 Adrian Florian. All rights reserved.
//

#import "ExampleDataSource.h"
#import "AFImageViewer.h"
@interface ExampleDataSource ()

-(NSArray *) images;

@end

@implementation ExampleDataSource
@synthesize imageViewer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Data source example";
    
    self.imageViewer.images = [self images];
    
    self.imageViewer.contentMode = UIViewContentModeScaleAspectFit;
}

-(NSArray *) images
{
    NSArray *imageNames = [NSArray arrayWithObjects:@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", nil];
    NSMutableArray *images = [NSMutableArray array];
    
    for (NSString *imageName in imageNames) [images addObject:[UIImage imageNamed:imageName]];
    
    return images;
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
