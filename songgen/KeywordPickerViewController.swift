//
//  KeywordPickerViewController.swift
//  songgen
//
//  Created by Nathan Fuller on 7/10/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

import UIKit

class KeywordPickerViewController: UIViewController, NSURLConnectionDataDelegate, UITextFieldDelegate {
    
    fileprivate var responseData: NSMutableData!
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    fileprivate func getPlaylist(_ keywords: [String]) {
        // TODO: Might reevaluate current setup
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () ->() in
                        self.activityView.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    fileprivate static func buildKeywordArray(_ keywordString: String) -> [String] {
        var ret = keywordString.components(separatedBy: " ")
        for i in 0..<ret.count {
            let trimmed = ret[i].trimmingCharacters(in: CharacterSet.whitespaces)
            ret[i] = trimmed
        }
        return ret
    }
    
    @IBAction func generateButtonPressed(_ sender: UIButton) {
        self.activityView.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
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
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.responseData = NSMutableData()
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.responseData.append(data)
    }
    
    func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
        // return nil to indicate not necessary to store a cached response
        return nil
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        // request is complete and data has been received
        
        if self.activityView != nil {
            self.activityView.stopAnimating()
        }
        
        let playlistId = String(data: self.responseData as Data, encoding: String.Encoding.utf8)
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        let userId = appDelegate.session?.canonicalUsername
        if let playlistUri = URL(string: "http://open.spotify.com/user/\(userId)/playlist/\(playlistId)") {
            app.openURL(playlistUri)
        }
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print(error.localizedDescription)
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
