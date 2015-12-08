//
//  AppDelegate.m
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/26/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSArray *)photoURLs {
    static NSArray *photos = nil;
    if (!photos) {
        photos = @[
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1447014421976-7fec21d26d86?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1446771326090-d910bfaf00f6?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1446426156356-92b664d86b77?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1446071103084-c257b5f70672?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1445699269025-bcc2c8f3faee?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"],
                   [NSURL URLWithString:@"https://images.unsplash.com/photo-1444792131309-2e517032ded6?crop=entropy&dpr=2&fit=crop&fm=jpg&h=900&ixjsv=2.1.0&ixlib=rb-0.3.5&q=50&w=1700"]
                   ];
    }

    return photos;
}

@end
