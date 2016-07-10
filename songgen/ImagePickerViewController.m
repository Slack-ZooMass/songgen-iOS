//
//  ImagePickerViewController.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "SSZipArchive.h"
@import MobileCoreServices;

@interface ImagePickerViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UIButton *editPhotosButton;
@end

@implementation ImagePickerViewController {
    NSString *pathToFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_activityView setHidesWhenStopped:YES];
    [self.view addSubview: _activityView];
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
            pathToFile = myFile;
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
    [_activityView startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self getPlaylist:pathToFile];
}

- (void)getPlaylist:(NSString *)pathToZip {
    
    NSString *base = [Utils getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@",base, @"/build-playlist/with-images"];
    NSLog(@"%@", url);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    SPTSession *session = appDelegate.session;
    
    NSDictionary *params = @{@"user_id"     : [session canonicalUsername],
                             @"access_token"    : [session accessToken]};
    
    NSString *boundary = [self generateBoundaryString];
    
    // configure the request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    // set content type
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // create body
    
    NSData *httpBody = [self createBodyWithBoundary:boundary parameters:params paths:@[pathToZip] fieldName:@"images_file"];
    
     request.HTTPBody = httpBody;
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

/**
 Source: http://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c
 */
- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

/**
 Source: http://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c
 */
- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

/**
 Source: http://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c
 */
- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             paths:(NSArray *)paths
                         fieldName:(NSString *)fieldName
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
    
    for (NSString *path in paths) {
        NSString *filename  = [path lastPathComponent];
        NSData   *data      = [NSData dataWithContentsOfFile:path];
        NSString *mimetype  = [self mimeTypeForPath:path];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
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
            NSLog(@"Ya done messed up");
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
            pathToFile = path;
            
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
    
    if (_activityView != nil) {
        [_activityView stopAnimating];
    }
    
    // stop ignoring input
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
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
