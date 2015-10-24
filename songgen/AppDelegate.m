//
//  AppDelegate.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player; // possibly don't need this at all
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [[SPTAuth defaultInstance] setClientID: @"56f27508025e44f883156431203ca88d"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"songgen://callback"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    return YES;
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            // Handle stuff
            
        }];
        return YES;
    }
    return NO;
}

+ (BOOL)giveAccessToken:(NSString *)accessToken {
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
