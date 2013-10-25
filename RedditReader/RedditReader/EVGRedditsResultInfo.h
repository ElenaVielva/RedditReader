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

@property (nonatomic) NSMutableDictionary *cacheReddits;
@property (nonatomic) NSMutableDictionary *cacheBefMark;
@property (nonatomic) NSMutableDictionary *cacheAftMark;

@property (nonatomic, strong) NSMutableArray *reddits;
@property (nonatomic) NSString *navTitle;

// Search properties
@property (nonatomic) NSURL *search;
@property (nonatomic) NSString *aftMark;
@property (nonatomic) NSString *befMark;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL loadingTop;


+(EVGRedditsResultInfo*) sharedInfo;
+(void) newSearch:(NSURL*) searchUrl;
+(void) loadMore;
+(BOOL) loadOnTop;

@end
