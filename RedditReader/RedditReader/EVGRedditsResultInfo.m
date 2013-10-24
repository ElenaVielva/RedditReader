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

@synthesize reddits;
@synthesize navTitle;
@synthesize afterMark;
@synthesize beforeMark;
@synthesize search;
@synthesize loading;
@synthesize loadingTop;

+(EVGRedditsResultInfo*) sharedInfo {
    if (shared) {
        return shared;
    }
    shared = [[EVGRedditsResultInfo alloc] init];
    return shared;
}

+ (BOOL)updateRedditsWithSearch:(NSURL *)searchUrl {
    NSArray *reddits = [self arrayFromJSONParsing:searchUrl];
    if (reddits == nil) {
        NSLog(@"No results");
        shared.loadingTop = NO;
        return NO;
    }
    if (shared.loading) {
        [shared.reddits addObjectsFromArray:reddits];
        
        shared.beforeMark = ((EVGReddit*)[shared.reddits firstObject]).name;
        shared.afterMark = ((EVGReddit *)[shared.reddits lastObject]).name;
        
        return YES;
    }
    if (shared.loadingTop) {
        NSMutableArray *newFinal = [NSMutableArray arrayWithCapacity:[reddits count]+[shared.reddits count]];
        
        [newFinal addObjectsFromArray:reddits];
        [newFinal addObjectsFromArray:shared.reddits];
        shared.reddits = newFinal;
        shared.beforeMark = ((EVGReddit*)[shared.reddits firstObject]).name;
        
        shared.loadingTop = NO;
        return YES;
    }
    return NO;
    
}

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

+(void) newSearch:(NSURL *) searchUrl {
    
    if (!shared) {
        shared = [EVGRedditsResultInfo sharedInfo];
    }
    shared.reddits = [NSMutableArray array];
    shared.search = searchUrl;
    
    shared.loading = YES;
    [self updateRedditsWithSearch:searchUrl];
    shared.loading = NO;
    
}

+(void) loadMore {
    shared.loading = YES;
    NSString *newSS = [NSString stringWithFormat:@"%@?after=%@",shared.search, shared.afterMark];
    NSURL *newSearch = [NSURL URLWithString:newSS];

    [self updateRedditsWithSearch:newSearch];
    shared.loading = NO;
}

+(BOOL) loadOnTop {
    shared.loadingTop = YES;
    
    NSString *newSS = [NSString stringWithFormat:@"%@?before=%@",shared.search, shared.beforeMark];
    NSURL *newSearch = [NSURL URLWithString:newSS];
    
    return [self updateRedditsWithSearch:newSearch];
}

@end
