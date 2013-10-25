//
//  EVGRedditsResultInfo.m
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import "EVGRedditsResultInfo.h"
#import "EVGReddit.h"

static EVGRedditsResultInfo *shared;

@implementation EVGRedditsResultInfo

@synthesize reddits, search;
@synthesize navTitle;
@synthesize aftMark, befMark;
@synthesize loading, loadingTop;
@synthesize cacheReddits, cacheBefMark, cacheAftMark;

/*
 * Singleton pattern. Just one result info object
 */
+(EVGRedditsResultInfo*) sharedInfo {
    if (shared) {
        return shared;
    }
    shared = [[EVGRedditsResultInfo alloc] init];
    return shared;
}

-(id) init {
    self = [super init];
    if (self) {
        cacheReddits = [NSMutableDictionary dictionary];
        cacheBefMark = [NSMutableDictionary dictionary];
        cacheAftMark = [NSMutableDictionary dictionary];
    }
    return self;
}

/*
 * Update the reddits information with the new search (first search or load older/newer reddits)
 */
+ (BOOL)updateRedditsWithSearch:(NSURL *)searchUrl {
    NSArray *reddits = [self arrayFromJSONParsing:searchUrl];
    if (reddits == nil) {
        NSLog(@"No results");
        shared.loadingTop = NO;
        return NO;
    }
    if (shared.loading) {
        [shared.reddits addObjectsFromArray:reddits];
        
        shared.befMark = ((EVGReddit*)[shared.reddits firstObject]).name;
        shared.aftMark = ((EVGReddit *)[shared.reddits lastObject]).name;
        
        [shared.cacheReddits setObject:shared.reddits forKey:shared.search];
        [shared.cacheBefMark setObject:shared.befMark forKey:shared.search];
        [shared.cacheAftMark setObject:shared.aftMark forKey:shared.search];
        
        return YES;
    }
    if (shared.loadingTop) {
        NSMutableArray *newFinal = [NSMutableArray arrayWithCapacity:[reddits count]+[shared.reddits count]];
        
        [newFinal addObjectsFromArray:reddits];
        [newFinal addObjectsFromArray:shared.reddits];
        shared.reddits = newFinal;
        shared.befMark = ((EVGReddit*)[shared.reddits firstObject]).name;
        
        [shared.cacheReddits setObject:shared.reddits forKey:shared.search];
        [shared.cacheBefMark setObject:shared.befMark forKey:shared.search];
        
        shared.loadingTop = NO;
        return YES;
    }
    return NO;
    
}

/*
 * From a url query to the reddit api, parse the json response and return an array with the reddits (evgreddit)
 */
+(NSArray*) arrayFromJSONParsing: (NSURL *)searchUrl {
    
    NSData *data = [NSData dataWithContentsOfURL: searchUrl];
    
    NSError *e = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonDict) {
        NSLog(@"Error parsing JSON: %@", e);
        return nil;
    }
        
    NSDictionary *dataDict = [jsonDict valueForKey:@"data"];
    NSArray *redditsArray = [dataDict valueForKey:@"children"];
    
    int sizeOfResult = [redditsArray count];
    if (sizeOfResult==0) {
        return nil;
    }
    NSMutableArray *reddits = [NSMutableArray arrayWithCapacity:sizeOfResult];
    
    for (NSDictionary *redditElem in redditsArray) {
        
        NSDictionary *realDataOfRedditElem = [redditElem valueForKey:@"data"];
        
        NSString *author = [realDataOfRedditElem valueForKey:@"author"];
        NSString *title = [realDataOfRedditElem valueForKey:@"title"];
        NSURL *url = [NSURL URLWithString:[realDataOfRedditElem valueForKey:@"url"]];
        NSURL *thumbUrl;
        NSString *name = [realDataOfRedditElem valueForKey:@"name"];
        if ([[realDataOfRedditElem valueForKey:@"thumbnail"] isEqualToString:@""]) {
            thumbUrl=nil;
        }else {
            thumbUrl=[NSURL URLWithString:[realDataOfRedditElem valueForKey:@"thumbnail"]];
        }
        
        int utcDate = [[realDataOfRedditElem valueForKey:@"created_utc"] intValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"HH:mm dd/MM/yy"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcDate];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        EVGReddit *reddit = [[EVGReddit alloc] init];
        reddit.author = author;
        reddit.title = title;
        reddit.url = url;
        reddit.thumb = thumbUrl;
        reddit.date = dateString;
        reddit.name = name;
        
        [reddits addObject:reddit];
    }
    return reddits;
}

/*
 * First query to the api
 */
+(void) newSearch:(NSURL *) searchUrl {
    
    if (!shared) {
        shared = [EVGRedditsResultInfo sharedInfo];
    }
    shared.search = searchUrl;
    
    NSMutableArray *cachedReddits = [shared.cacheReddits objectForKey:searchUrl];
    if (cachedReddits) {
        shared.reddits = cachedReddits;
        shared.aftMark = [shared.cacheAftMark objectForKey:searchUrl];
        shared.befMark = [shared.cacheBefMark objectForKey:searchUrl];
        
    } else {
        shared.reddits = [NSMutableArray array];
        
        shared.loading = YES;
        [self updateRedditsWithSearch:searchUrl];
        shared.loading = NO;
        
        [shared.cacheReddits setObject:shared.reddits forKey:searchUrl];
        [shared.cacheBefMark setObject:shared.befMark forKey:searchUrl];
        [shared.cacheAftMark setObject:shared.aftMark forKey:searchUrl];
    }
    
    
}

/*
 * Query the api to get more reddits
 */
+(void) loadMore {
    if (shared.loading) {
        return;
    }
    shared.loading = YES;
    NSString *newSS = [NSString stringWithFormat:@"%@?after=%@",shared.search, shared.aftMark];
    NSURL *newSearch = [NSURL URLWithString:newSS];

    [self updateRedditsWithSearch:newSearch];
    shared.loading = NO;
}

/*
 * Query the api to get newer reddits
 */
+(BOOL) loadOnTop {
    if (shared.loadingTop) {
        return NO;
    }
    shared.loadingTop = YES;
    
    NSString *newSS = [NSString stringWithFormat:@"%@?before=%@",shared.search, shared.befMark];
    NSURL *newSearch = [NSURL URLWithString:newSS];
    
    return [self updateRedditsWithSearch:newSearch];
}

@end
