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
import testKit

@available(iOS 10.0, *)
class PersonsCaMoreTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var editLabel: UIButton!
    @IBOutlet weak var selfieView: UIView!
    @IBOutlet weak var joinBerbiDoctorGroupLabel: UILabel!
    
    // for save photoUrl to local CoreData
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate struct MVC{
        static let beDoctorIdentifier = "Be a Certified Doctor"
        static let underReviewIdentifier = "Show DoctorStartAi"
        static let doctorModeIdentifier = "show Doctor Mode"
        static let logOutIdentifier = "show Login"
        static let joinBeriString = NSLocalizedString("Join Berbi Doctor Group", comment: "In PersonsCaMore, fifth title for user to join berbi doctor")
        static let changeBackString = NSLocalizedString("Change Back to Doctor Mode", comment: "In PersonsCaMore, fifth title for doctor change back to doctor mode")
    }
    // MARK: - Camera Function
    @IBAction func editSelfie() {
        
        // alert for chosing where to get new selfie
        //set a new AlertController
        let alertController = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        //set cancel action
        let cancelAction = UIAlertAction(title: Storyboard.CancelAlert, style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        //set Take a New Picture action
        let NewPicAction = UIAlertAction(title: Storyboard.TakeANewPictureAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                print("In library")
                let picker = UIImagePickerController()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFont(ofSize: 17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .photoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
//                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.allowsEditing = true
                picker.delegate = self //need UINavigationControllerDelegate
                self.present(picker, animated: true, completion: {
                    //change back to defaul Navigation bar colour after setting image from Photo Library
                    let navbarFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 17)
                    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont,NSForegroundColorAttributeName: UIColor.white]
                    UINavigationBar.appearance().tintColor = UIColor.white
                    }
                )
            }
        }
        alertController.addAction(profileAction)
        
        //for ipad popover
        alertController.modalPresentationStyle = .popover
        if let popoverController = alertController.popoverPresentationController{
            popoverController.sourceView = editLabel
            //set popover from bonds rather than editLabel's view's original point
            popoverController.sourceRect = editLabel.bounds
            
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //image have to be editedImage
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        let compressionRate : CGFloat = 0.1
        //transfer to local disc first
        var imageSized : UIImage?
        imageSized =  resize.relfieSingleton(image!,remote: false)
        selfieImage.image = imageSized
        if let imageData = UIImageJPEGRepresentation(imageSized!, compressionRate) {
            print("after resize image size %f KB:", imageData.count / 1024)
            signInUser?.imageLocal = imageData
            savetoLocalCoredata(imageData)
            // also need to update to url
        }
        imageSized = nil
        image = nil
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        //notify for name update
        NotificationCenter.default.addObserver(self, selector: #selector(self.nameBackUpdate), name: NSNotification.Name(rawValue: "updateName"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @objc fileprivate func nameBackUpdate(){
//        let printName = printNameOrder(signInUserPublic!.firstname!, lastName: signInUserPublic!.lastname!)
//        userName.text = printName
//        self.navigationItem.title = printName
        updateImage()
    }
    
    fileprivate func updateUI(){
        //setup selfie image container border
        selfieImageContainer.layer.borderWidth = 1
        selfieImageContainer.layer.borderColor = UIColor(netHex: 0xE6E6E6).cgColor
        
        //setup selfieView view boarder
        let border = CALayer()
        let viewWidth = self.view.layer.frame.size.width
        border.borderColor = UIColor(netHex: 0xE6E6E6).cgColor
        border.frame = CGRect(x: -viewWidth * 0.2, y: 0, width: viewWidth * 2, height: selfieView.layer.frame.size.height)
        border.borderWidth = 0.5
        selfieView.layer.addSublayer(border)
        selfieView.layer.masksToBounds = true
        
        //change label
        if signInUser!.isdoctor!.boolValue{
            joinBerbiDoctorGroupLabel.text = MVC.changeBackString
        }else{
            joinBerbiDoctorGroupLabel.text = MVC.joinBeriString
        }
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
    
    func printNameOrder(_ firstName: String, lastName: String) -> String{
        var returnName = ""
        let englishFormat = "(?=.*[A-Za-z]).*$"
        let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        if langId.range(of: "en") != nil || englishPredicate.evaluate(with: firstName) || englishPredicate.evaluate(with: lastName) {
            returnName = firstName+" "+lastName
        }else if langId.range(of: "zh") != nil{
            returnName = lastName+firstName
        }else{
            returnName = firstName+" "+lastName
        }
        return returnName
    }
    
    func updateImage() {
        //setup Name
        let printName = printNameOrder(signInUserPublic!.firstname!, lastName: signInUserPublic!.lastname!)
        userName.text = printName
        self.navigationItem.title = printName
        //setup Default Image
        if let imagedata = signInUser!.imageLocal {
            if let image = UIImage(data: imagedata){
                //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                        print("updateImage() Load User self image")
                        DispatchQueue.main.async {
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
    
    
//    func saveImage()
//    {
//        if let image = selfieImage.image {
//            //get image as JPEG
//            if let imageData = UIImageJPEGRepresentation(image, 0.1) {
//                print("image size %f KB:", imageData.length / 1024)
//                signInUser?.imageLocal = imageData
//                savetoLocalCoredata(imageData)
//                // no need to store url, but leave record for future usage
////                let fileManager = NSFileManager()
////                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL! {
////                    let unique = signInUser!.email!
////                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg") //create path on URL
////                    let path = url.absoluteString
////                    if imageData.writeToURL(url, atomically: true) {
////                        //if file has been written save url to
////                    }
////                    
////                }
//            }
//            
//        }
//    }
    
    func savetoLocalCoredata(_ imageData: Data){
        //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>        //fetch a local user in HD
        
        do {
            let Personresults =  try moc.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            person[0].setValue(imageData, forKey: "imageLocal")
            try moc.save()
            
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - tap Be a Licensed Medical Doctor
    @IBAction func tapJoinBerbi(_ sender: UITapGestureRecognizer) {
        if signInUser!.isdoctor == false{
            if signInUser!.applicationStatus == Status.userModeNotApply{
                performSegue(withIdentifier: MVC.beDoctorIdentifier, sender: nil)
            }else if signInUser!.applicationStatus == Status.underReview {
                performSegue(withIdentifier: MVC.underReviewIdentifier, sender: nil)
            }
        }else{
            performSegue(withIdentifier: MVC.doctorModeIdentifier, sender: nil)
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 5
        }
        else{
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            let logOutTitle = NSLocalizedString("Log Out", comment: "In PersonsCaMore, alert title for log out.")
            let logOutDetail = NSLocalizedString("Are you sure you want to log out?", comment: "In PersonsCaMore, alert detail for log out.")
            let alert = UIAlertController(title: logOutTitle, message: logOutDetail, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Storyboard.ConfirmAlert, style: .default, handler: { [weak self] (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                signInUser = nil
                signInUserPublic = nil
                signInDoctor = nil
                self!.performSegue(withIdentifier: MVC.logOutIdentifier, sender: nil)
                }))
            
            alert.addAction(UIAlertAction(title: Storyboard.CancelAlert, style: .cancel, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
        
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as UIViewController
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

