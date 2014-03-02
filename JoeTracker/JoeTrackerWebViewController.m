//
//  JoeTrackerWebViewController.m
//  JoeTracker
//
//  Created by Joseph Jackson on 3/2/14.
//  Copyright (c) 2014 Joseph Jackson. All rights reserved.
//

#import "JoeTrackerWebViewController.h"

@interface JoeTrackerWebViewController ()

@end

@implementation JoeTrackerWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSString *fullURL = @"http://jackson.local:8000";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
