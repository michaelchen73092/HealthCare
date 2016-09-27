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

@available(iOS 10.0, *)
class DoctorStartAcLicenceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var invalidLicenseNumber: UILabel!
    @IBOutlet weak var LicenseTextField: UITextField!{ didSet{ LicenseTextField.delegate = self}}
    @IBOutlet weak var descriptionForImageUsage: UILabel!
    
    weak var moc : NSManagedObjectContext?
    fileprivate struct MVC {
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
        
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //setup UI
        presentImage.isHidden = true
        descriptionForImageUsage.isHidden = true
        descriptionForImageUsage.layer.borderWidth = 1.0
        descriptionForImageUsage.layer.borderColor = UIColor.red.cgColor
        descriptionForImageUsage.text = Storyboard.PhotoPrintForVerify
        invalidLicenseNumber.isHidden = true
        
        if signInUser?.doctorLicenseNumber != nil {
            LicenseTextField.text = signInUser!.doctorLicenseNumber
        }
        
        //setup medicalLicense if any
        checkWhetherStoredImageOrNot()
        
    }

    func checkWhetherStoredImageOrNot(){
        //setup Default Image
        if let imagedata = signInUser!.doctorImageMedicalLicense {
            image = UIImage(data: imagedata)
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                DispatchQueue.main.async {
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

        if validateNumberOnly(LicenseTextField.text!) && (signInUser?.doctorImageMedicalLicense != nil){
            signInUser?.doctorLicenseNumber = LicenseTextField.text
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }else{
            invalidLicenseNumber.isHidden = false
            wiggleInvalidtext(invalidLicenseNumber, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if signInUser?.doctorImageMedicalLicense != nil && presentImage?.image == nil {
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
        let alertController = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        //set cancel action
        let cancelAction = UIAlertAction(title: Storyboard.CancelAlert, style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        //set Take a New Picture action
        let NewPicAction = UIAlertAction(title: Storyboard.TakeANewPictureAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = imagePickerControllerSingleton.singleton()
                picker.sourceType = .camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                //picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                print("In library")
                let picker = imagePickerControllerSingleton.singleton()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFont(ofSize: 17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .photoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
                //                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                //picker.allowsEditing = true
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
            popoverController.sourceView = cameraLabel
            //set popover from bonds rather than editLabel's view's original point
            popoverController.sourceRect = cameraLabel.bounds
            
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // add ratio to new image, reference to stanford cs193p lecture 8
    fileprivate weak var aspectRatioConstraint: NSLayoutConstraint? {
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
    
    fileprivate weak var image: UIImage? {
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
                            attribute: .width,
                            relatedBy: .equal,
                            toItem: constrainedView,
                            attribute: .height,
                            multiplier: newImage.aspectRatio,
                            constant: 0)
                        presentImage.isHidden = false
                        descriptionForImageUsage.isHidden = false
                    } else {
                        aspectRatioConstraint = nil
                    }
                    
                }
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = resize.singleton(info[UIImagePickerControllerOriginalImage] as! UIImage , container: presentImage.image!)
        //print("image?.size.height:\(image?.size.height)")
        //print("image?.size.width:\(image?.size.width)")
        //image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
            //print("image size %f KB:", imageData.length / 1024)
            signInUser?.doctorImageMedicalLicense = imageData
            image = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        signInUser?.doctorLicenseNumber = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ad = segue.destination as? DoctorStartAdGraduateSchoolTableViewController{
            //pass current moc to next controller which use for create Persons object
            ad.moc = self.moc!
            presentImage?.image = nil
            descriptionForImageUsage.isHidden = true
        }
    }

}


