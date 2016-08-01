//
//  DoctorStartAdGraduateSchoolTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/22/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class DoctorStartAdGraduateSchoolTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    @IBOutlet weak var graduatedLabel: UILabel!
    @IBOutlet weak var medicalDiplomaLabel: UIButton!
    @IBOutlet weak var descriptionForDiploma: UILabel!
    
    @IBOutlet weak var idCardLabel: UIButton!
    @IBOutlet weak var descriptionForIDCard: UILabel!
    
    @IBOutlet weak var invalidNotification: UILabel!
    
    var diplomaHeight = CGFloat(60)
    var idCardHeight = CGFloat(60)
    weak var moc : NSManagedObjectContext?
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAf"
    }
    @IBOutlet weak var graduatedDescription: UILabel!
    
    // MARK: - view cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description 
        graduatedDescription.text = NSLocalizedString("Please choose the school where you graudated AND upload either Medical Diploma OR ID Card(Driver License) to verify your identity.", comment: "In DoctorStartAdGraduateSchool, description for this page")
        
        //for description initailiaztion
        descriptionForDiploma.layer.borderWidth = 1.0
        descriptionForDiploma.layer.borderColor = UIColor.redColor().CGColor
        descriptionForDiploma.text = Storyboard.PhotoPrintForVerify
        
        descriptionForIDCard.layer.borderWidth = 1.0
        descriptionForIDCard.layer.borderColor = UIColor.redColor().CGColor
        descriptionForIDCard.text = Storyboard.PhotoPrintForVerify
        //setup
        invalidNotification.hidden = true
        //setup navigation
        let graudateSchoolTitle = NSLocalizedString("Professional Education", comment: "In DoctorStartAdGraduateSchool's title")
        self.navigationItem.title = graudateSchoolTitle
        
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //add graduate back notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.graduateSchoolUpdate), name: "graduateSchoolBack", object: nil)
        //add Default graduate school
        graduateSchoolUpdate()
        //add image set
        //setup Default Image
        imageDiploma()
        if tempDoctor?.doctorImageDiploma != nil{
            labelToUpload(medicalDiplomaLabel)
        }
        imageID()
        if tempDoctor?.doctorImageID != nil{
            labelToUpload(idCardLabel)
        }
    }
    
    private func imageDiploma(){
        if let imagedata = tempDoctor?.doctorImageDiploma {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                var image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.diplomaPresentImage.image = image
                    self!.diplomaHeight = self!.diplomaPresentImage.frame.width / image!.aspectRatio
                    image = nil
                }
            }
        }
    }
    
    private func imageID(){
        if let imagedata = tempDoctor?.doctorImageID {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                var image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.idCardImage.image = image
                    self!.idCardHeight = self!.idCardImage.frame.width / image!.aspectRatio
                    image = nil
                }
            }
        }
    }
    // MARK: - Graudated School
    func graduateSchoolUpdate(){
        if tempDoctor?.doctorGraduateSchool != nil {
            graduatedLabel.text = tempDoctor!.doctorGraduateSchool!
            graduatedLabel.font = UIFont.systemFontOfSize(17)
        }
    }
    
    func nextButtonClicked(){
        invalidNotification.hidden = true
        //set back item's title to ""
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        if (tempDoctor?.doctorGraduateSchool != nil) && (tempDoctor?.doctorImageID != nil || tempDoctor?.doctorImageDiploma != nil){
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }else{
            invalidNotification.hidden = false
        }
        
        
    }

    // MARK: - Medical Diploma
    var diplomaOrIDCard = false //false is diploma, true is ID Card
    var diplomaSection = 1
    @IBOutlet weak var diplomaPresentImage: UIImageView!
    @IBOutlet weak var diplomaCameraLabel: UIButton!
    
    @IBAction func tapDiplomaLabel() {
        if tempDoctor?.doctorImageDiploma == nil {
            diplomaOrIDCard = false
            getPhoto()
        }else{
            if diplomaSection == 1 {
                imageDiploma()
                diplomaSection = 2
            }else{
                diplomaSection = 1
            }
            tableView.reloadData()
        }
        if diplomaSection == 2 {
            let indexPath = NSIndexPath(forRow: 1, inSection: 1)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    @IBAction func diplomaCameraButton() {
        diplomaOrIDCard = false
        getPhoto()
    }

    // MARK: - ID Card
    var idCardSection = 1
    @IBOutlet weak var idCardImage: UIImageView!
    @IBOutlet weak var idCardCameraLabel: UIButton!
    
    @IBAction func tapIDCardLabel() {
        if tempDoctor?.doctorImageID == nil {
            diplomaOrIDCard = true
            getPhoto()
        }else{
            if idCardSection == 1 {
                imageID()
                idCardSection = 2
            }else{
                idCardSection = 1
            }
            tableView.reloadData()
        }
        if idCardSection == 2 {
            let indexPath = NSIndexPath(forRow: 1, inSection: 2)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }

    @IBAction func idCardCameraButton() {
        diplomaOrIDCard = true
        getPhoto()
    }

    
    // MARK: - Photo
    func getPhoto(){
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
            if !diplomaOrIDCard {
                popoverController.sourceView = diplomaCameraLabel
                popoverController.sourceRect = diplomaCameraLabel.bounds
            }else{
                popoverController.sourceView = idCardCameraLabel
                popoverController.sourceRect = idCardCameraLabel.bounds
            }
            
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closemedicalDiplomaImage(sender: UITapGestureRecognizer) {
        diplomaSection = 1
        tableView.reloadData()
    }
    
    @IBAction func closeIDCardImage(sender: UITapGestureRecognizer) {
        idCardSection = 1
        tableView.reloadData()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if !diplomaOrIDCard {
            image = resize.singleton(image! , container: diplomaPresentImage.image!)
            diplomaPresentImage.image = image
            diplomaHeight = diplomaPresentImage.frame.width / image!.aspectRatio
            labelToUpload(medicalDiplomaLabel)
            if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                //print("image size %f KB:", imageData.length / 1024)
                tempDoctor?.doctorImageDiploma = imageData
                image = nil
            }
            diplomaSection = 2
        }else{
            image = resize.singleton(image! , container: idCardImage.image!)
            idCardImage.image = image
            idCardHeight = idCardImage.frame.width / image!.aspectRatio
            labelToUpload(idCardLabel)
            if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                //print("image size %f KB:", imageData.length / 1024)
                tempDoctor?.doctorImageID = imageData
                image = nil
            }
            idCardSection = 2
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
            
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if !diplomaOrIDCard {
            tempDoctor?.doctorImageDiploma = nil
            labelnotSet(medicalDiplomaLabel)
        }else{
            tempDoctor?.doctorImageID = nil
            labelnotSet(idCardLabel)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func labelToUpload(label: UIButton){
        label.setTitle(Storyboard.uploaded, forState: .Normal)
        label.titleLabel!.font = UIFont.systemFontOfSize(17)
    }
    
    func labelnotSet(label: UIButton){
        label.setTitle(Storyboard.notSet, forState: .Normal)
        label.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0{
            return 1
        }else if section == 1{
            return diplomaSection
        }else {
            return idCardSection
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            return diplomaHeight
        }else if indexPath.section == 2 && indexPath.row == 1 {
            return idCardHeight
        }
        return 60
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let af = segue.destinationViewController as? DoctorStartAfSpecialistTableViewController{
            //pass current moc to next controller which use for create Persons object
            af.moc = self.moc!
            diplomaPresentImage.image = nil
            idCardImage.image = nil
            diplomaSection = 1
            idCardSection = 1
            tableView.reloadData()
        }
    }

}
