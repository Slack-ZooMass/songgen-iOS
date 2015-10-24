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
@end

@implementation AppDelegate

NSString *const PATH_CONST = @"http://localhost:3000/%@";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *keys;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"];
    
    if (path)
        keys = [[NSDictionary alloc] initWithContentsOfFile:path];
        
    [[SPTAuth defaultInstance] setClientID: keys[@"spotifyClientID"]];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"songgen://callback"]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            NSLog(@"%@",url);
//            if (error != nil) {
//                NSLog(@"*** Auth error: %@", error);
//                return;
//            }
//            
//            NSString *url = [NSString stringWithFormat:PATH_CONST, @"users/authenticate"];
//            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
//                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                               timeoutInterval:15.0];
//            
//            NSMutableDictionary *dataDict = [NSMutableDictionary new];
//            [dataDict setObject:[session accessToken] forKey:@"accessToken"];
//            [dataDict setObject:[session canonicalUsername] forKey:@"canonicalUsername"];
//            
//            NSError *err;
//            NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&err];
//            
//            if (err) {
//                NSLog(@"%@", err);
//            }
//            
//            [request setHTTPMethod:@"POST"];
//            [request setHTTPBody:postData];
//            
//            BOOL canHandle = [NSURLConnection canHandleRequest:request];
//            NSLog(@"%@", canHandle ? @"true" : @"false");
//            
//            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//            
            
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
