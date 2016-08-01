//
//  DoctorStartAcLicenceViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/21/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class DoctorStartAcLicenceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var invalidLicenseNumber: UILabel!
    @IBOutlet weak var LicenseTextField: UITextField!{ didSet{ LicenseTextField.delegate = self}}
    @IBOutlet weak var descriptionForImageUsage: UILabel!
    
    weak var moc : NSManagedObjectContext?
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAd"
    }
    @IBOutlet weak var medicalLicenseDescription: UILabel!
    
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description 
        medicalLicenseDescription.text = NSLocalizedString("Please enter your license number and upload a clear image of your medicine license to verify your doctor identity.", comment: "In DoctorStartAcLicence, description for this page")
        
        //setup navigation
        let medicalLicenseTitle = NSLocalizedString("Medical License", comment: "In DoctorStartAcLicense's title")
        self.navigationItem.title = medicalLicenseTitle
        
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //setup UI
        presentImage.hidden = true
        descriptionForImageUsage.hidden = true
        descriptionForImageUsage.layer.borderWidth = 1.0
        descriptionForImageUsage.layer.borderColor = UIColor.redColor().CGColor
        descriptionForImageUsage.text = Storyboard.PhotoPrintForVerify
        invalidLicenseNumber.hidden = true
        
        if tempDoctor?.doctorLicenseNumber != nil {
            LicenseTextField.text = tempDoctor!.doctorLicenseNumber
        }
        
        //setup medicalLicense if any
        checkWhetherStoredImageOrNot()
        
    }

    func checkWhetherStoredImageOrNot(){
        //setup Default Image
        if let imagedata = tempDoctor!.doctorImageMedicalLicense {
            image = UIImage(data: imagedata)
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                dispatch_async(dispatch_get_main_queue()) {
                    self!.presentImage.image = self!.image
                }
            }
            
        }
    }
    
    func nextButtonClicked(){
        //set back item's title to ""
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem

        if validateNumberOnly(LicenseTextField.text!) && (tempDoctor?.doctorImageMedicalLicense != nil){
            tempDoctor?.doctorLicenseNumber = LicenseTextField.text
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }else{
            invalidLicenseNumber.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if tempDoctor?.doctorImageMedicalLicense != nil && presentImage?.image == nil {
            checkWhetherStoredImageOrNot()
        }
    }
    
    // MARK: - Update Photo function
    @IBOutlet weak var presentImage: UIImageView!
    @IBOutlet weak var cameraLabel: UIButton!
    @IBAction func cameraButton() {
        LicenseTextField.resignFirstResponder()
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
                let picker = imagePickerControllerSingleton.singleton()
                picker.sourceType = .Camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                //picker.allowsEditing = true
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .Default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                print("In library")
                let picker = imagePickerControllerSingleton.singleton()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFontOfSize(17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.blackColor()]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .PhotoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
                //                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                //picker.allowsEditing = true
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
            popoverController.sourceView = cameraLabel
            //set popover from bonds rather than editLabel's view's original point
            popoverController.sourceRect = cameraLabel.bounds
            
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // add ratio to new image, reference to stanford cs193p lecture 8
    private weak var aspectRatioConstraint: NSLayoutConstraint? {
        willSet {
            if let existingConstraint = aspectRatioConstraint {
                view.removeConstraint(existingConstraint)
            }
        }
        didSet {
            if let newConstraint = aspectRatioConstraint {
                view.addConstraint(newConstraint)
            }
        }
    }
    
    private weak var image: UIImage? {
        get {
            return presentImage?.image
        }
        set {
            if newValue != nil{
                presentImage?.image = newValue
                if let constrainedView = presentImage {
                    if let newImage = newValue {
                        aspectRatioConstraint = NSLayoutConstraint(
                            item: constrainedView,
                            attribute: .Width,
                            relatedBy: .Equal,
                            toItem: constrainedView,
                            attribute: .Height,
                            multiplier: newImage.aspectRatio,
                            constant: 0)
                        presentImage.hidden = false
                        descriptionForImageUsage.hidden = false
                    } else {
                        aspectRatioConstraint = nil
                    }
                    
                }
            }
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = resize.singleton(info[UIImagePickerControllerOriginalImage] as! UIImage , container: presentImage.image!)
        //print("image?.size.height:\(image?.size.height)")
        //print("image?.size.width:\(image?.size.width)")
        //image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
            //print("image size %f KB:", imageData.length / 1024)
            tempDoctor?.doctorImageMedicalLicense = imageData
            image = nil
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - textField
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tempDoctor?.doctorLicenseNumber = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ad = segue.destinationViewController as? DoctorStartAdGraduateSchoolTableViewController{
            //pass current moc to next controller which use for create Persons object
            ad.moc = self.moc!
            presentImage?.image = nil
            descriptionForImageUsage.hidden = true
        }
    }

}


