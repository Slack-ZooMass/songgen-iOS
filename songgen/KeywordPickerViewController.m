//
//  KeywordPickerViewController.m
//  songgen
//
//  Created by Nathan Fuller on 10/24/15.
//  Copyright © 2015 Nathan Fuller. All rights reserved.
//

#import "KeywordPickerViewController.h"
#import <Spotify/Spotify.h>
#import "Utils.h"

@interface KeywordPickerViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UITextField *keywordInput;
@end

@implementation KeywordPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_activityView setHidesWhenStopped:YES];
    [self.view addSubview: _activityView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)generateButtonPressed:(id)sender {
    [_activityView startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSString *keywordString = [self.keywordInput text];
    NSArray *keywordArray = [KeywordPickerViewController buildKeywordArray: keywordString];
    [self getPlaylist:keywordArray];
}

- (void)getPlaylist:(NSArray *)keywords {
    
    NSString *base = [Utils getBaseUrl];
    NSString *url = [NSString stringWithFormat:@"%@%@", base, @"/build-playlist/with-words"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:15.0];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    SPTSession *session = appDelegate.session;
    
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    [dataDict setObject:[session accessToken] forKey:@"access_token"];
    [dataDict setObject:[session canonicalUsername] forKey:@"user_id"];
    [dataDict setObject:keywords forKey:@"words"];

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

+ (NSArray *)buildKeywordArray:(NSString *)keywordString {
    NSMutableArray *ret = [[keywordString componentsSeparatedByString:@" "] mutableCopy];
    for (int i = 0; i < [ret count]; i++) {
        NSString *trimmed = [[ret objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [ret replaceObjectAtIndex:i withObject:trimmed];
    }
    NSArray *immutableCopy = [ret copy];
    return immutableCopy;
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
    
    if (_activityView != nil) {
        [_activityView stopAnimating];
    }
    
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
