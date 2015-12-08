//
//  AppDelegate.h
//  UCPhotoGalleryExample
//
//  Created by Bryan Oltman on 11/26/15.
//  Copyright © 2015 Compass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSArray *)photoURLs;

@end

