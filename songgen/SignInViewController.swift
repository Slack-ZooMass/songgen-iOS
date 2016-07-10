//
//  SignInViewController.swift
//  songgen
//
//  Created by Nathan Fuller on 7/9/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

class SignInViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var getStartedButton: UIButton! // used for manual segue to move into application
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // loginWithSpotify
    @IBAction func loginWithSpotify(sender: UIButton) {
        // Construct a login URL and open it
        let loginURL = SPTAuth.defaultInstance().loginURL
        
        // Opening a URL in Safari close to application launch may trigger an iOS bug, so we wait a bit before doing so.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> () in
            UIApplication.sharedApplication().openURL(loginURL)
        })
    }
}
