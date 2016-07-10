//
//  AppDelegate.swift
//  songgen
//
//  Created by Nathan Fuller on 7/9/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var session: SPTSession?
    private let auth = SPTAuth.defaultInstance()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        guard let resources = Utils.getPrivateResources() else {
            return false
        }
        
        auth.clientID = "\(resources["spotifyClientID"]!)"
        auth.redirectURL = NSURL(string: "songgen://callback")
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // Ask SPTAuth if the URL given is a Spotify authentication callback
        if auth.canHandleURL(url) {
            auth.handleAuthCallbackWithTriggeredAuthURL(url, callback: {
                error, session in
                self.session = session
            })
            
            return true
        }
        
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}