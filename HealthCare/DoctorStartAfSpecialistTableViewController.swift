//
//  DoctorStartAfSpecialistTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/25/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

class DoctorStartAfSpecialistTableViewController: UITableViewController, UITextFieldDelegate , UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - variable
    weak var lastIndex : NSIndexPath?
    weak var moc : NSManagedObjectContext?
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAg"
    }
    @IBOutlet weak var invalidLabel: UILabel!
    @IBOutlet weak var specialtyDescription: UILabel!
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description textView
        specialtyDescription.text = NSLocalizedString("Please choose your status or your primary specialty. If you select your primary specialty, please also upload a photo of your medical specialties license.", comment: "In DoctorStartAfSpecialist, description for this page")
        
        invalidLabel.hidden = true
        //setup navigation
        let areaTitle = NSLocalizedString("Area of Practice", comment: "In DoctorStartAfSpecialist's title")
        self.navigationItem.title = areaTitle
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //set pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        specialtyLabel.hidden = true
        //descriptionForSpecialty.hidden = true
        //set specialty camera
        descriptionForSpecialty.layer.borderWidth = 1.0
        descriptionForSpecialty.layer.borderColor = UIColor.redColor().CGColor
        descriptionForSpecialty.text = Storyboard.PhotoPrintForVerify
        
        //add image set
        //setup Default Image
        uploadImage()
        if tempDoctor?.doctorImageSpecialistLicense != nil{
            labelToUpload(isSpecialtyImageUploadLabel)
        }
        
        // deal with previous checkmark
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist"{
                lastIndex = NSIndexPath(forRow: 0, inSection: 0)
            }else if tempDoctor!.doctorProfession!.rangeOfString("PGY") != nil {
                lastIndex = NSIndexPath(forRow: 1, inSection: 0)
            }else if tempDoctor!.doctorProfession!.rangeOfString("Resident") != nil {
                lastIndex = NSIndexPath(forRow: 2, inSection: 0)
                if let aftersince = tempDoctor!.doctorProfession!.rangeOfString("since "){
                    let date = tempDoctor!.doctorProfession![aftersince.endIndex..<tempDoctor!.doctorProfession!.endIndex]
                    residentYear.text = date
                }
                
            }else{
                lastIndex = NSIndexPath(forRow: 3, inSection: 0)
                specialtyLabel.hidden = false
                specialtyLabel.text = tempDoctor!.doctorProfession!
            }
        }
    }
    
    private func uploadImage(){
        if let imagedata = tempDoctor?.doctorImageSpecialistLicense {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                let image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.specialtyPresentImage.image = image
                    self!.specialtyHeight = self!.specialtyPresentImage.frame.width / image!.aspectRatio
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if lastIndex != nil{
            let cell = tableView.cellForRowAtIndexPath(lastIndex!)
            cell?.accessoryType = .Checkmark
            lastIndex = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextButtonClicked(){
        invalidLabel.hidden = true
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist" || tempDoctor!.doctorProfession!.rangeOfString("PGY") != nil{
                performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
            }else if tempDoctor!.doctorProfession!.rangeOfString("Resident") != nil {
                if validateResidentDate(residentYear.text!){
                    performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
                }else{
                    invalidLabel.hidden = false
                }
            }else{
                if tempDoctor?.doctorImageSpecialistLicense != nil{
                    performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
                }else{
                    invalidLabel.hidden = false
                }
            }
        }else{
            invalidLabel.hidden = false
        }
    }
    // MARK: - Internist
    @IBAction func tapInternist(sender: UITapGestureRecognizer) {
        //order of first define tempDoctor?.doctorProfession and then deselectOtherCheckmark() is matter
        tempDoctor?.doctorProfession = "Internist"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    private func deselectOtherCheckmark(){
        var index = NSIndexPath(forRow: 0, inSection: 0)
        var cell = tableView.cellForRowAtIndexPath(index)
        for i in 0...3{
            index = NSIndexPath(forRow: i, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .None
        }
        //move keyboard
        residentYear.resignFirstResponder()
        
        specialistSection = 4
        if tempDoctor?.doctorProfession != nil{
            if tempDoctor!.doctorProfession!.rangeOfString("Resident") == nil {
                residentYear.text = ""
            }
            //set specialty to nil and label hidden if not select specialty
            if tempDoctor?.doctorProfession == "Internist" || tempDoctor?.doctorProfession!.rangeOfString("PGY") != nil || tempDoctor?.doctorProfession!.rangeOfString("Resident") != nil {
                if tempDoctor?.doctorImageSpecialistLicense != nil{
                    tempDoctor?.doctorImageSpecialistLicense = nil
                    labelnotSet(isSpecialtyImageUploadLabel)
                    specialtyLabel.hidden = true
                    specialtyLabel.text = ""
                }
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - PGY
    @IBAction func tapPGY(sender: UITapGestureRecognizer) {
        tempDoctor?.doctorProfession = "PGY(Taiwan medical system only)"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = NSIndexPath(forRow: 1, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    
    // MARK: - Resident
    @IBOutlet weak var residentYear: UITextField!{didSet{residentYear.delegate = self}}
    
    @IBAction func tapResident(sender: UITapGestureRecognizer) {
        // deselect others
        tempDoctor?.doctorProfession = "Resident since \(residentYear!.text!)"
        deselectOtherCheckmark()
        //checkmark
        let index = NSIndexPath(forRow: 2, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    // MARK: - Specialty
    var specialistSection = 4
    @IBOutlet weak var pickerView: UIPickerView!
    var pickerDataSource = [specialty.AllergyandImmunology, specialty.Anesthesiology, specialty.Cardiologist, specialty.ChineseMedicine, specialty.ColonandRectalSurgery, specialty.CosmeticSurgery, specialty.Dentist, specialty.Dermatology, specialty.EmergencyMedicine, specialty.Endocrinologist, specialty.FamilyMedicine, specialty.Gastroenterologist, specialty.InfectiousDiseasesSpecialist, specialty.InternalMedicine, specialty.MedicalGeneticsandGenomics, specialty.NeurologicalSurgery, specialty.Neurology, specialty.NuclearMedicine, specialty.ObstetricsandGynecology, specialty.Oncologist, specialty.Ophthalmology, specialty.OrthopaedicSurgery, specialty.Otolaryngology, specialty.Pathology, specialty.Pediatrics, specialty.PhysicalMedicineandRehabilitation, specialty.PlasticSurgery, specialty.PreventiveMedicine, specialty.Psychiatry, specialty.Radiology, specialty.SurgeryGeneralSurgery, specialty.ThoracicSurgery, specialty.Urology, specialty.VascularSurgeon, specialty.Other]
    @IBOutlet weak var specialtyLabel: UILabel!
    
    
    @IBAction func tapSpecialty(sender: UITapGestureRecognizer) {
        if specialistSection == 4 {
            //for select back if it is still select specialty
            if tempDoctor?.doctorProfession != nil{
                if tempDoctor?.doctorProfession != "Internist" && tempDoctor?.doctorProfession!.rangeOfString("PGY") == nil && tempDoctor?.doctorProfession!.rangeOfString("Resident") == nil {
                    specialtyLabel.hidden = false
                    specialtyLabel.text = tempDoctor!.doctorProfession!
                }
            }
            //for deselect other use
            residentYear.text = ""
            // deselect others
            deselectOtherCheckmark()
            if tempDoctor?.doctorImageSpecialistLicense == nil{
                specialistSection = 6
            }else{
                uploadImage()
                specialistSection = 7
            }
            //checkmark
            let index = NSIndexPath(forRow: 3, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .Checkmark
            tableView.reloadData()
            let indexPath = NSIndexPath(forRow: 5, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            
            
            //tableView.reloadData()
        }else {
            //it's been set true when specialistSection == 4
            if tempDoctor?.doctorProfession != nil {
                specialtyLabel.hidden = false
            }
            specialistSection = 4
            tableView.reloadData()

        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        specialtyLabel.text = pickerDataSource[row]
        specialtyLabel.hidden = false
        tempDoctor?.doctorProfession = pickerDataSource[row]
    }
    
    
    @IBOutlet weak var descriptionForSpecialty: UILabel!

    @IBOutlet weak var specialtyPresentImage: UIImageView!
    @IBOutlet weak var specialtyCameraLabel: UIButton!
    @IBOutlet weak var isSpecialtyImageUploadLabel: UIButton!
    var specialtyHeight = CGFloat(60)
    
    // MARK: - Photo
    
    @IBAction func tapSpecialtyLabel() {
        if tempDoctor?.doctorImageSpecialistLicense == nil{
            getPhoto()
        }else{
            if specialistSection == 6{
                specialistSection = 7
                uploadImage()
                tableView.reloadData()
                let indexPath = NSIndexPath(forRow: 6, inSection: 0)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }else{
                specialistSection = 6
                tableView.reloadData()
            }
            
        }
    }
    
    @IBAction func specialtyCameraButton() {
        getPhoto()
    }
    
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
                popoverController.sourceView = specialtyCameraLabel
                popoverController.sourceRect = specialtyCameraLabel.bounds
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        image = resize.singleton(image! , container: specialtyPresentImage.image!)
        specialtyPresentImage.image = image
        specialtyHeight = specialtyPresentImage.frame.width / image!.aspectRatio
        labelToUpload(isSpecialtyImageUploadLabel)
        if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
            //print("image size %f KB:", imageData.length / 1024)
            tempDoctor?.doctorImageSpecialistLicense = imageData
        }
        dismissViewControllerAnimated(true, completion: nil)
        specialistSection = 7
        tableView.reloadData()
        let indexPath = NSIndexPath(forRow: 6, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        image = nil
        //descriptionForSpecialty.hidden = false
        //specialtyPresentImage.hidden = false
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        tempDoctor?.doctorImageSpecialistLicense = nil
        labelnotSet(isSpecialtyImageUploadLabel)
        specialistSection = 6
        //descriptionForSpecialty.hidden = true
        //specialtyPresentImage.hidden = true
        specialtyHeight = 60
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return specialistSection
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 6 {
            return specialtyHeight
        }else if indexPath.row == 4 {
            return 240
        }
        return 60
    }
    
    
    // MARK: - TextField
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tempDoctor?.doctorProfession = "Resident since \(residentYear!.text!)"
        deselectOtherCheckmark()
        let index = NSIndexPath(forRow: 2, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        //textField.resignFirstResponder()
        return true
    }

    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ag = segue.destinationViewController as? DoctorStartAgCurrentHospitalTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ag.moc = self.moc!
            if tempDoctor?.doctorImageSpecialistLicense != nil{
                specialtyPresentImage.image = nil
                specialistSection = 6
                tableView.reloadData()
            }
            
        }
    }
    


}
