//
//  KeywordPickerViewController.swift
//  songgen
//
//  Created by Nathan Fuller on 7/10/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

import UIKit

class KeywordPickerViewController: UIViewController, NSURLConnectionDataDelegate, UITextFieldDelegate {
    
    private var responseData: NSMutableData!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var keywordInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.activityView.hidesWhenStopped = true
        self.view.addSubview(self.activityView)
        
        self.keywordInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func getPlaylist(keywords: [String]) {
        // TODO: Might reevaluate current setup
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), { () ->() in
                        self.activityView.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        })
    }
    
    private static func buildKeywordArray(keywordString: String) -> [String] {
        var ret = keywordString.componentsSeparatedByString(" ")
        for i in 0..<ret.count {
            let trimmed = ret[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            ret[i] = trimmed
        }
        return ret
    }
    
    @IBAction func generateButtonPressed(sender: UIButton) {
        self.activityView.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        if let keywordString = self.keywordInput.text {
            let keywordArray = KeywordPickerViewController.buildKeywordArray(keywordString)
            self.getPlaylist(keywordArray)
        }
    }
//    - (IBAction)generateButtonPressed:(id)sender {
//    [_activityView startAnimating];
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    NSString *keywordString = [self.keywordInput text];
//    NSArray *keywordArray = [KeywordPickerViewController buildKeywordArray: keywordString];
//    [self getPlaylist:keywordArray];
//    }
    
    // MARK: - NSURLConnectionData Delegate Methods
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.responseData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.responseData.appendData(data)
    }
    
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        // return nil to indicate not necessary to store a cached response
        return nil
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        // request is complete and data has been received
        
        if self.activityView != nil {
            self.activityView.stopAnimating()
        }
        
        let playlistId = String(data: self.responseData, encoding: NSUTF8StringEncoding)
        let app = UIApplication.sharedApplication()
        let appDelegate = app.delegate as! AppDelegate
        let userId = appDelegate.session?.canonicalUsername
        if let playlistUri = NSURL(string: "http://open.spotify.com/user/\(userId)/playlist/\(playlistId)") {
            app.openURL(playlistUri)
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error.debugDescription)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
