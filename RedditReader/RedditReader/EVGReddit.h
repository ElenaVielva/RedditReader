//
//  EVGReddit.h
//  RedditReader
//
//  Created by Elena Vielva on 20/10/13.
//  Copyright (c) 2013 Elena Vielva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVGReddit : NSObject  {

}

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *thumb;
@property (nonatomic, retain) NSString *name;

@end
