//
//  ImagePickerViewController.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import "ImagePickerViewController.h"

@interface ImagePickerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UIButton *editPhotosButton;
@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addPhotos:(id)sender {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO))
        // TODO: Display some feedback for the user that they cannot use this feature.
        // ALT TODO: Make this check at the previous screen to determine whether
        // the "IMAGE" button even appears
        return;
    ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    // TODO: see how app performs when we try other sources
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        [self presentViewController:ipc animated:YES completion:nil];
    else
    {
        popover=[[UIPopoverController alloc] initWithContentViewController:ipc];
        [popover presentPopoverFromRect:_addPhotosButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
- (IBAction)editPhotos:(id)sender {
}
- (IBAction)generateButtonPressed:(id)sender {
}

#pragma mark - ImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        [popover dismissPopoverAnimated:YES];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
