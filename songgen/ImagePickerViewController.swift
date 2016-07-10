//
//  ImagePickerViewController.swift
//  songgen
//
//  Created by Nathan Fuller on 7/9/16.
//  Copyright © 2016 Nathan Fuller. All rights reserved.
//

import MobileCoreServices
import UIKit

class ImagePickerViewController: UIViewController, NSURLConnectionDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var pathToFile: String?
    private var ipc: UIImagePickerController!
    private var responseData: NSMutableData!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var addPhotosButton: UIButton!
    @IBOutlet weak var editPhotosButton: UIButton!
    @IBOutlet weak var chosenImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.activityView.hidesWhenStopped = true
        self.view .addSubview(self.activityView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPhotosButtonPressed(sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let mainBundle = NSBundle.mainBundle()
            if let fileStr = mainBundle.pathForResource("test", ofType: "zip") {
                if NSFileManager.defaultManager().fileExistsAtPath(fileStr) {
                    self.pathToFile = fileStr
                }
            }
        } else {
            self.ipc = UIImagePickerController()
            self.ipc.delegate = self
            
            // TODO: see how app performs when we try other sources
            self.ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
                self.presentViewController(self.ipc, animated: true, completion: nil)
            } else {
                let sourceRect = CGRectMake(self.view.frame.size.width/2-200,
                                            self.view.frame.size.height/2-300,
                                            400, 400)
                self.ipc.modalPresentationStyle = UIModalPresentationStyle.Popover
                self.presentViewController(self.ipc, animated: true, completion: nil)
                self.ipc.popoverPresentationController?.sourceRect = sourceRect
                self.ipc.popoverPresentationController?.sourceView = self.view
            }
        }
    }
    
    @IBAction func editPhotosButtonPressed(sender: UIButton) {
        // TODO: implement ability to let users remove/change which photo's they'e picked
    }
    
    @IBAction func generateButtonPressed(sender: UIButton) {
        self.activityView.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.getPlaylist(self.pathToFile)
    }
    
    // MARK: - ImagePickerController Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        let imagePath = documentsDirectory.stringByAppendingString("/latest_photo.png")
        
        // extracting image from the picker and saving it
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        if mediaType == "public.image" {
            guard let editedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                print("ERROR: Something went wrong choosing that image.")
                return
            }
            
            let webData = UIImagePNGRepresentation(editedImage)
            webData?.writeToFile(imagePath, atomically: true)

            let fileManager = NSFileManager.defaultManager()
//            let directoryContent = try? fileManager.contentsOfDirectoryAtPath(documentsDirectory)
            
            var path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            path = String(format: "%@/%@.zip", path, NSUUID().UUIDString)
            
            
//            let success = SSZipArchive.createZipFileAtPath(path, withContentsOfDirectory: documentsDirectory)
//            print("\(success)")
            
            var zipDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            zipDir = String(format: "%@/", zipDir)
            
//            let zipDirectoryContent = try? fileManager.contentsOfDirectoryAtPath(zipDir)
            
            if fileManager.fileExistsAtPath(path) {
                self.pathToFile = path
            }
        }
        
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            picker.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Server Communication Handling
    private func getPlaylist(pathToZip: String?) {
        // TODO: Might reevaluate current setup
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), { () ->() in
                        self.activityView.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        })
    }
    
    private func generateBoundaryString() -> String? {
        return String(format: "Boundary-%@", NSUUID().UUIDString)
    }
    
    private func mimeTypeForPath(path: String?) -> String? {
        // TODO:
        return nil
    }
    
    private func createBodyWithBoundary(boundary: String,
                                        paramaters: [String: AnyObject],
                                        paths: [String],
                                        fieldName: String) -> NSData? {
        // TODO:
        return nil
    }
    
    // MARK: - NSURLConnection Delegate Methods
    
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
        // request is complete and data has been received, parse the data
        if (self.activityView != nil) {
            self.activityView.stopAnimating()
        }
        
        // stop ignoring input
        let app = UIApplication.sharedApplication()
        app.endIgnoringInteractionEvents()
        
        // grab the Spotify URI string and attempt to open it
        let playlistId = String(data: self.responseData, encoding: NSUTF8StringEncoding)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let userId = appDelegate.session?.canonicalUsername
        if let playlistUri = NSURL(string: "http://open.spotify.com/user/\(userId)/playlist/\(playlistId)") {
            app.openURL(playlistUri)
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        // request failed for some reason
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
