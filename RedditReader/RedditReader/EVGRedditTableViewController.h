//
//  EVGRedditTableViewController.h
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVGRedditTableViewController : UITableViewController <UIScrollViewDelegate> {
    
    NSMutableDictionary *cachedThumbnails;
    BOOL isLoading;
    BOOL loadingTop;
    UIImage *loadingImage;
}

@end
