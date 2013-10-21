//
//  EVGViewController.m
//  RedditReader
//
//  Created by Elena Vielva on 19/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import "EVGViewController.h"
#import "EVGRedditsResultInfo.h"

@interface EVGViewController ()

@end

@implementation EVGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(IBAction)toMainReddit:(id)sender {
//    [EVGRedditsResultInfo newSearch:[NSURL URLWithString:@"http://www.reddit.com/new/.json"]];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"topRedditSegue"]) {
        [EVGRedditsResultInfo sharedInfo].navTitle = @"Top";
        [EVGRedditsResultInfo newSearch:[NSURL URLWithString:@"http://www.reddit.com/top/.json"]];
    }
    if ([[segue identifier] isEqualToString:@"newRedditSegue"]) {
        [EVGRedditsResultInfo sharedInfo].navTitle = @"New";
        [EVGRedditsResultInfo newSearch:[NSURL URLWithString:@"http://www.reddit.com/new/.json"]];
    }
    if ([[segue identifier] isEqualToString:@"controversialRedditSegue"]) {
        [EVGRedditsResultInfo sharedInfo].navTitle = @"Controversial";
        [EVGRedditsResultInfo newSearch:[NSURL URLWithString:@"http://www.reddit.com/controversial/.json"]];
    }
}

@end
