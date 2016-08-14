//
//  PersonsCaMoreTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/11/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData


class PersonsCaMoreTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editLabel: UIButton!
    @IBOutlet weak var selfieView: UIView!
    // for save photoUrl to local CoreData
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private struct MVC{
        static let beDoctorIdentifier = "Be a Certified Doctor"
        static let underReviewIdentifier = "Show DoctorStartAi"
    }
    // MARK: - Camera Function
    @IBAction func editSelfie() {
        
        // alert for chosing where to get new selfie
        //set a new AlertController
        let alertController = UIAlertController(title: nil, message: nil , preferredStyle: .ActionSheet)
        //set cancel action
        let cancelAction = UIAlertAction(title: Storyboard.CancelAlert, style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        //set Take a New Picture action
        let NewPicAction = UIAlertAction(title: Storyboard.TakeANewPictureAlert, style: .Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                picker.allowsEditing = true
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                print("In library")
                let picker = UIImagePickerController()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFontOfSize(17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.blackColor()]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .PhotoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
//                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.allowsEditing = true
                picker.delegate = self //need UINavigationControllerDelegate
                self.presentViewController(picker, animated: true, completion: {
                    //change back to defaul Navigation bar colour after setting image from Photo Library
                    let navbarFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFontOfSize(17)
                    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont,NSForegroundColorAttributeName: UIColor.whiteColor()]
                    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
                    }
                )
            }
        }
        alertController.addAction(profileAction)
        
        //for ipad popover
        alertController.modalPresentationStyle = .Popover
        if let popoverController = alertController.popoverPresentationController{
            popoverController.sourceView = editLabel
            //set popover from bonds rather than editLabel's view's original point
            popoverController.sourceRect = editLabel.bounds
            
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }

        selfieImage.image = image
        saveImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //every time need to reinstill app for checking correct url
        updateImage()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    private func updateUI(){
        //setup selfie image container border
        selfieImageContainer.layer.borderWidth = 1
        selfieImageContainer.layer.borderColor = UIColor(netHex: 0xE6E6E6).CGColor
        
        //setup selfieView view boarder
        let border = CALayer()
        let viewWidth = self.view.layer.frame.size.width
        border.borderColor = UIColor(netHex: 0xE6E6E6).CGColor
        border.frame = CGRect(x: -viewWidth * 0.2, y: 0, width: viewWidth * 2, height: selfieView.layer.frame.size.height)
        border.borderWidth = 0.5
        selfieView.layer.addSublayer(border)
        selfieView.layer.masksToBounds = true
        
        self.tableView.backgroundColor = UIColor(netHex: 0xD7DCE4)
        //updateNameAndDefaultImage()
        updateImage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Image
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var selfieImageContainer: UIView!{
        didSet{
            // we put a generic UIView in our autolayout
            // because it will shrink and grow as the space allows
            // (versus a UIImageView which demands space to show its image)
            // we will manage the frame of the image view ourself
            // (in makeRoomForImage() below)
            //selfieImageContainer.addSubview(selfieImage)
        }
    }
    
    func updateImage() {
        //setup Name
        let NameFormateString = NSLocalizedString("%@ %@", comment: "Print Name by First Name and Last Name")
        userName.text = String.localizedStringWithFormat(NameFormateString, signInUserPublic!.firstname!, signInUserPublic!.lastname!)
        self.navigationItem.title = String.localizedStringWithFormat(NameFormateString, signInUserPublic!.firstname!, signInUserPublic!.lastname!)
        //setup Default Image
        if let imagedata = signInUser!.imageLocal {
            if let image = UIImage(data: imagedata){
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                        dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                        print("Load User self image")
                        dispatch_async(dispatch_get_main_queue()) {
                        self?.selfieImage.image = image
                    }
                }
            }
        }else{
            if signInUserPublic!.gender!.boolValue {
                selfieImage.image = UIImage(named:"FemaleImage.png")
            }else{
                selfieImage.image = UIImage(named:"MaleImage.png")
            }
        }
        //use url to find exist image data. Not use here now. We use NSData to store image in CoreData
//        
//        let url = (signInUser?.imageLocalUrl)!
//        if url == "Default" {
//            if (signInUser?.gender)! == "Male"{
//                selfieImage.image = UIImage(named:"MaleImage.png")
//            }else{
//                selfieImage.image = UIImage(named:"FemaleImage.png")
//            }
//        }else{
//            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
//            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
//                if let imageData = NSData(contentsOfURL: NSURL(string: url)! ) {
//                    if let image = UIImage(data: imageData) {
//                        print("has image")
//                        dispatch_async(dispatch_get_main_queue()) {
//                                self?.selfieImage.image = image
//                        }
//                    }
//                }
//            }
//        }
    }
    
    
    func saveImage()
    {
        if let image = selfieImage.image {
            //get image as JPEG
            if let imageData = UIImageJPEGRepresentation(image, 0.1) {
                //print("image size %f KB:", imageData.length / 1024)
                signInUser?.imageLocal = imageData
                savetoLocalCoredata(imageData)
                // no need to store url, but leave record for future usage
//                let fileManager = NSFileManager()
//                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL! {
//                    let unique = signInUser!.email!
//                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg") //create path on URL
//                    let path = url.absoluteString
//                    if imageData.writeToURL(url, atomically: true) {
//                        //if file has been written save url to
//                    }
//                    
//                }
            }
            
        }
    }
    
    func savetoLocalCoredata(imageData: NSData){
        let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        //fetch a local user in HD

        do {
            let Personresults =  try moc.executeFetchRequest(fetchRequestPerson)
            let person = Personresults as! [NSManagedObject]
            person[0].setValue(imageData, forKey: "imageLocal")
            try moc.save()
            
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - tap Be a Licensed Medical Doctor
    @IBAction func tapJoinBerbi(sender: UITapGestureRecognizer) {
        if signInUser!.isdoctor == false{
            if signInUser!.applicationStatus == Status.userModeNotApply{
                performSegueWithIdentifier(MVC.beDoctorIdentifier, sender: nil)
            }else if signInUser!.applicationStatus == Status.underReview {
                performSegueWithIdentifier(MVC.underReviewIdentifier, sender: nil)
            }else{
                //for doctor mode
            }
        }else{
            performSegueWithIdentifier(MVC.underReviewIdentifier, sender: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        }
        else{
            return 1
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if destination is PersonsCbAccountTableViewController{
            //pass current moc to next controller which use for create Persons object
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

