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

+(EVGRedditsResultInfo*) sharedInfo {
    if (shared) {
        return shared;
    }
    shared = [[EVGRedditsResultInfo alloc] init];
    return shared;
}

+ (void)jsonQueryParser:(NSURL *)searchUrl {
    NSData *data = [NSData dataWithContentsOfURL: searchUrl];
    
    NSError *e = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonDict) {
        NSLog(@"Error parsing JSON: %@", e);
    } else {
        
        NSDictionary *dataDict = [jsonDict valueForKey:@"data"];
        NSArray *redditsArray = [dataDict valueForKey:@"children"];
        
        shared.afterMark = [dataDict valueForKey:@"after"];
        
        for (NSDictionary *redditElem in redditsArray) {
            NSDictionary *realDataOfRedditElem = [redditElem valueForKey:@"data"];
            NSString *author = [realDataOfRedditElem valueForKey:@"author"];
            NSString *title = [realDataOfRedditElem valueForKey:@"title"];
            NSURL *url = [NSURL URLWithString:[realDataOfRedditElem valueForKey:@"url"]];
            NSURL *thumbUrl;
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
            
            [shared.reddits addObject:reddit];
        }
    }
}

+(void) newSearch:(NSURL *) searchUrl {
    
    if (!shared) {
        shared = [EVGRedditsResultInfo sharedInfo];
    }
    shared.reddits = [NSMutableArray array];
    shared.search = searchUrl;
    
    shared.loading = YES;
    [self jsonQueryParser:searchUrl];
    shared.loading = NO;
    
}

+(void) loadMore {
    shared.loading = YES;
    NSString *newSS = [NSString stringWithFormat:@"%@?after=%@",shared.search, shared.afterMark];
    NSURL *newSearch = [NSURL URLWithString:newSS];

    [self jsonQueryParser:newSearch];
    shared.loading = NO;
}

@end
