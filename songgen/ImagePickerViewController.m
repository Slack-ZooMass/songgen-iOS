//
//  ImagePickerViewController.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "SSZipArchive.h"

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
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *myFile = [mainBundle pathForResource: @"test" ofType: @"zip"];
        if([[NSFileManager defaultManager] fileExistsAtPath:myFile]) {
            [self getPlaylist:myFile];
        }
        return;
    }
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
    // TODO: implement ability to let users remove/change which photos they've picked
}
- (IBAction)generateButtonPressed:(id)sender {
    // TODO: Handle button press for images slected
}

- (void)getPlaylist:(NSString *)pathToZip {
    // NSLog(pathToZip);
    
    NSString *url = [NSString stringWithFormat:PATH_CONST, @"/build-playlist/with-images"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0];
    
    NSData *theData = [NSData dataWithContentsOfFile:pathToZip];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    SPTSession *session = appDelegate.session;
    
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    [dataDict setObject:[session accessToken] forKey:@"access_token"];
    [dataDict setObject:[session canonicalUsername] forKey:@"user_id"];
    [dataDict setObject:theData forKey:@"file"];
    
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&err];
    
    if (err) {
        NSLog(@"%@", err);
    }
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if ([NSURLConnection canHandleRequest:request]) {
        // TODO: provide some feedback that there may be connection issues?
    }
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


#pragma mark - ImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
    NSLog(@"%@", imagePath);
    
    // extracting image from the picker and saving it
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (!editedImage) {
            NSLog(@"Ya fucked up");
        }
        NSData *webData = UIImagePNGRepresentation(editedImage);
        [webData writeToFile:imagePath atomically:YES];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *directoryContent = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        path = [NSString stringWithFormat: @"%@/%@.zip", path, [[NSUUID UUID] UUIDString]];
        
        BOOL success = [SSZipArchive createZipFileAtPath:path withContentsOfDirectory:documentsDirectory];
        NSLog(@"%@", success ? @"true" : @"false");
        
        NSString *zipDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        zipDir = [NSString stringWithFormat: @"%@/", zipDir];
        
        NSArray *directoryConten = [fileManager contentsOfDirectoryAtPath:zipDir error:nil];
        NSLog(@"%d",(int)[directoryConten count]);
        
        if([fileManager fileExistsAtPath: path])
            [self getPlaylist:path];
            
    }
    
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

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCaCheResponse:(NSCachedURLResponse *)cachedResponse {
    // return nil to indicate not necessary to store a cached response
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    // request is complete and data has been received, parse stuff in variable now
    // NSLog(@"Request body %@", [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding]);
    NSString *playlist = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *user_id = [appDelegate.session canonicalUsername];
    
    NSString *playlistUri = [NSString stringWithFormat: @"http://open.spotify.com/user/%@/playlist/%@", user_id, playlist];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:playlistUri]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // request failed for some reason
    if (error) {
        NSLog(@"%@", error);
    }
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
