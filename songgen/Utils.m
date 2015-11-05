//
//  utils.m
//  songgen
//
//  Created by Nathan Fuller on 11/4/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@implementation Utils

+(NSString*)getBaseUrl {
    
    NSMutableString *baseUrl = [NSMutableString stringWithString:@""];

// TODO: See if we can have DEBUG set to FALSE for master branch?
// Then have it set to TRUE on any other branch?
// For now, just use the actual server :/
    
//#ifdef DEBUG
//    // formatted as XX.XX.XX.XX:[PORT_NUMBER]
//    [baseUrl appendFormat:@"%@", [Utils getPrivateResources][@"localhostIP"]];
//#else
    [baseUrl appendString:@"https://songgen.herokuapp.com"];
//#endif
     
     return baseUrl;
}

+(NSDictionary*)getPrivateResources {
    
    NSDictionary *priv = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"private" ofType:@"plist"];
    
    if (path) {
        priv = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return priv;
}

@end