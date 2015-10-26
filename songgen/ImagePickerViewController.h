//
//  ImagePickerViewController.h
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ImagePickerViewController : UIViewController<NSURLConnectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableData *_responseData;
    UIImagePickerController *ipc;
    UIPopoverController *popover;
}
@property (weak, nonatomic) IBOutlet UIButton *addPhotosButton;
@property (weak, nonatomic) IBOutlet UIImageView *ivPickedImage;
@end
