//
//  AppDelegate.h
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "AppDelegate.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

FOUNDATION_EXPORT NSString *const PATH_CONST;
@property (strong, nonatomic) SPTSession *session;
@property (strong, nonatomic) UIWindow *window;


@end

