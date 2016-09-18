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
    
    fileprivate var pathToFile: String?
    fileprivate var ipc: UIImagePickerController!
    fileprivate var responseData: NSMutableData!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var editPhotosButton: UIBarButtonItem!
    @IBOutlet weak var addPhotosButton: UIBarButtonItem!
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
    
    @IBAction func addPhotosButtonPressed(_ sender: UIBarButtonItem) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let mainBundle = Bundle.main
            if let fileStr = mainBundle.path(forResource: "test", ofType: "zip") {
                if FileManager.default.fileExists(atPath: fileStr) {
                    self.pathToFile = fileStr
                }
            }
        } else {
            self.ipc = UIImagePickerController()
            self.ipc.delegate = self
            
            // TODO: see how app performs when we try other sources
            self.ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                self.present(self.ipc, animated: true, completion: nil)
            } else {
                let sourceRect = CGRect(x: self.view.frame.size.width/2-200,
                                            y: self.view.frame.size.height/2-300,
                                            width: 400, height: 400)
                self.ipc.modalPresentationStyle = UIModalPresentationStyle.popover
                self.present(self.ipc, animated: true, completion: nil)
                self.ipc.popoverPresentationController?.sourceRect = sourceRect
                self.ipc.popoverPresentationController?.sourceView = self.view
            }
        }
    }
    
    @IBAction func editPhotosButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: implement ability to let users remove/change which photo's they'e picked
    }
    
    @IBAction func generateButtonPressed(_ sender: UIButton) {
        self.activityView.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.getPlaylist(self.pathToFile)
    }
    
    // MARK: - ImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let imagePath = documentsDirectory + "/latest_photo.png"
        
        // extracting image from the picker and saving it
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        if mediaType == "public.image" {
            guard let editedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                print("ERROR: Something went wrong choosing that image.")
                return
            }
            
            let webData = UIImagePNGRepresentation(editedImage)
            try? webData?.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])

            let fileManager = FileManager.default
//            let directoryContent = try? fileManager.contentsOfDirectoryAtPath(documentsDirectory)
            
            var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            path = String(format: "%@/%@.zip", path, UUID().uuidString)
            
            
//            let success = SSZipArchive.createZipFileAtPath(path, withContentsOfDirectory: documentsDirectory)
//            print("\(success)")
            
            var zipDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            zipDir = String(format: "%@/", zipDir)
            
//            let zipDirectoryContent = try? fileManager.contentsOfDirectoryAtPath(zipDir)
            
            if fileManager.fileExists(atPath: path) {
                self.pathToFile = path
            }
        }
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            picker.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Server Communication Handling
    fileprivate func getPlaylist(_ pathToZip: String?) {
        // TODO: Might reevaluate current setup
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { () ->() in
                        self.activityView.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    fileprivate func generateBoundaryString() -> String? {
        return String(format: "Boundary-%@", UUID().uuidString)
    }
    
    fileprivate func mimeTypeForPath(_ path: String?) -> String? {
        // TODO:
        return nil
    }
    
    fileprivate func createBodyWithBoundary(_ boundary: String,
                                        paramaters: [String: AnyObject],
                                        paths: [String],
                                        fieldName: String) -> Data? {
        // TODO:
        return nil
    }
    
    // MARK: - NSURLConnection Delegate Methods
    
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
        // request is complete and data has been received, parse the data
        if (self.activityView != nil) {
            self.activityView.stopAnimating()
        }
        
        // stop ignoring input
        let app = UIApplication.shared
        app.endIgnoringInteractionEvents()
        
        // grab the Spotify URI string and attempt to open it
        let playlistId = String(data: self.responseData as Data, encoding: String.Encoding.utf8)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userId = appDelegate.session?.canonicalUsername
        if let playlistUri = URL(string: "http://open.spotify.com/user/\(userId)/playlist/\(playlistId)") {
            app.openURL(playlistUri)
        }
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        // request failed for some reason
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
