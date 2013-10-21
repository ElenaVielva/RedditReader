//
//  EVGRedditsResultInfo.h
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTop,
    kNew,
    kControversial
}typesReddit;

@interface EVGRedditsResultInfo : NSObject {
    
}

@property (nonatomic, strong) NSMutableArray *reddits;
@property (nonatomic) NSString *navTitle;

// Search properties
@property (nonatomic) NSURL *search;
@property (nonatomic) NSString *afterMark;
@property (nonatomic) NSString *beforeMark;
@property (nonatomic) BOOL loading;

+(EVGRedditsResultInfo*) sharedInfo;
+(void) newSearch:(NSURL*) searchUrl;
+(void) loadMore;

@end
