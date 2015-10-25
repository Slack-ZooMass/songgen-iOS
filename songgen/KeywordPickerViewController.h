//
//  KeywordPickerViewController.h
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface KeywordPickerViewController : UIViewController<NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@end
