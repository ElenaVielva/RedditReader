//
//  EVGReddit.h
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 ** Class responsible for storing the information of the reddits: title, author, date, url, thumbnail and id
 ** The id is necessary to later on search for newer or older reddits
 **/
@interface EVGReddit : NSObject  {

}

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *thumb;
@property (nonatomic, retain) NSString *name;

@end
