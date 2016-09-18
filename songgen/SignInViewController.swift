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
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didLogIn),
                                               name: AppDelegate.didLoginNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // loginWithSpotify
    @IBAction func loginWithSpotify(_ sender: UIButton) {
        // Construct a login URL and open it
        let loginURL = SPTAuth.defaultInstance().loginURL
        
        // Opening a URL in Safari close to application launch may trigger an iOS bug, so we wait a bit before doing so.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () -> () in
            UIApplication.shared.openURL(loginURL!)
        })
    }
    
    @objc private func didLogIn() {
        loginButton.isHidden = true
        loginButton.isEnabled = false
        getStartedButton.isHidden = false
        getStartedButton.isEnabled = true
    }
}
