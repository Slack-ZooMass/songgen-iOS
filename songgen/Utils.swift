//
//  Utils.swift
//  songgen
//
//  Created by Nathan Fuller on 7/9/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

import Foundation

@objc class Utils: NSObject {
    
    static func getBaseUrl() -> NSString {
        let baseUrl = NSMutableString(string: "")
        
        baseUrl.append("https://songgen.herokuapp.com")
        
        return baseUrl
    }
    
    static func getPrivateResources() -> NSDictionary? {
        if let path = Bundle.main.path(forResource: "private", ofType: "plist") {
            return NSDictionary.init(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
}

