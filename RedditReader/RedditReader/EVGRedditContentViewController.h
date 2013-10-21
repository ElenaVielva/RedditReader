//
//  EVGRedditContentViewController.h
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVGReddit.h"

@interface EVGRedditContentViewController : UIViewController {
    IBOutlet UIWebView *content;
}

@property (nonatomic) EVGReddit *reddit;


@end
