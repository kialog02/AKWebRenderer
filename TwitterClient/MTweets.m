//
//  MTweets.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/05.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "MTweets.h"

static NSMutableArray *objects;
static NSMutableSet *objectIDs;

@implementation MTweets

- (MTWeetsType)tweetType
{
    if (self.urls.count) {
        for (NSURL *url in self.urls) {
            // XXX: should implement better URL recognition engine for images
            NSString *extension = url.pathExtension;
            if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"png"]) {
                return MTWeetsTypeImage;
            }
        }
        return MTWeetsTypeWeb;
    } else {
        return MTWeetsTypeText;
    }
}

#pragma mark -

+ (void)load
{
    [super load];
    if (objects == nil) {
        objects = [NSMutableArray array];
    }
    if (objectIDs == nil) {
        objectIDs = [NSMutableSet set];
    }
}

+ (NSInteger)count
{
    @synchronized(objects) {
        return objects.count;
    }
}

+ (NSArray *)allObjects
{
    @synchronized(objects) {
        return [NSArray arrayWithArray:objects];
    }
}

+ (void)insertNewObject:(MTweets *)object
{
    @synchronized(objects) {
        if (![objectIDs containsObject:object.tweetID]) {
            [objects addObject:object];
            [objectIDs addObject:object.tweetID];
        }
    }
}

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        self.tweetID        = jsonObject[@"id"];
        self.userID         = jsonObject[@"user"][@"id_str"];
        self.userScreenName = jsonObject[@"user"][@"screen_name"];
        self.username       = jsonObject[@"user"][@"name"];
        self.text           = jsonObject[@"text"];
        
        NSMutableArray *urlBuffer = [NSMutableArray array];
        for (NSDictionary *urlObject in jsonObject[@"entities"][@"urls"]) {
            NSURL *url = urlObject[@"expanded_url"];
            [urlBuffer addObject:url];
        }
        self.urls = [NSArray arrayWithArray:urlBuffer];
        
        NSDictionary *retweetedStatusObject = jsonObject[@"retweeted_status"];
        if (retweetedStatusObject) {
            MTweets *retweetedStatus = [[MTweets alloc] initWithJSONObject:retweetedStatusObject];
            self.retweetedStatus = retweetedStatus;
        }
    }
    return self;
}

@end
