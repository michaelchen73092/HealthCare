//
//  DoctorStartAiInProcessTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/1/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import testKit

@available(iOS 10.0, *)
class DoctorStartAiInProcessTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // MARK: - Variables
    fileprivate struct MVC{
        static let NoUpdate = NSLocalizedString("No Update", comment: "In DoctorStartAiInProcess, the string to indicate that this image is not updated")
    }
    @IBOutlet weak var inProcessDescription: UILabel!
    @IBOutlet weak var medicalLicenseButton: UIButton!
    @IBOutlet weak var medicalDiplomaButton: UIButton!
    @IBOutlet weak var idButton: UIButton!
    @IBOutlet weak var specialtyButton: UIButton!
    @IBOutlet weak var medicalLicenseCameraLabel: UIButton!
    @IBOutlet weak var medicalDiplomaCameraLabel: UIButton!
    @IBOutlet weak var idCameraLabel: UIButton!
    @IBOutlet weak var specialtyCameraLabel: UIButton!
    var medicalLicenseHeight = CGFloat(60)
    var medicalDiplomaHeight = CGFloat(60)
    var idHeight = CGFloat(60)
    var specialtyHeight = CGFloat(60)
    
    @IBOutlet weak var medicalLicensePresentImage: UIImageView!
    @IBOutlet weak var medicalDiplomaPresentImage: UIImageView!
    @IBOutlet weak var idPresentImage: UIImageView!
    @IBOutlet weak var specialtyPresentImage: UIImageView!
    
    @IBOutlet weak var DescriptionMedicalLicense: UILabel!
    @IBOutlet weak var DescriptionMedicalDiploma: UILabel!
    @IBOutlet weak var DescriptionId: UILabel!
    @IBOutlet weak var DescriptionSpecalty: UILabel!
    
    //initial temp image file
    var imageMedicalLicense : Data?
    var imageMedicalDiploma : Data?
    var imageID : Data?
    var imageSpecialty : Data?
    var sectionGlobal = 0
    
    weak var moc : NSManagedObjectContext?
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        //initial
        inProcessDescription.text = NSLocalizedString("Update Documents\n\nBerbi will contact with you by email if there are some documents needed re-upload. You can use below columns to update the documents.", comment: "In DoctorStartAiInProcess, description for this page")
        labelNoUpdate(medicalLicenseButton)
        labelNoUpdate(medicalDiplomaButton)
        labelNoUpdate(idButton)
        labelNoUpdate(specialtyButton)
        descriptionLabelInit(DescriptionMedicalLicense)
        descriptionLabelInit(DescriptionMedicalDiploma)
        descriptionLabelInit(DescriptionId)
        descriptionLabelInit(DescriptionSpecalty)
        moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func dismissVariables(){
        imageMedicalLicense = nil
        imageMedicalDiploma = nil
        imageID = nil
        imageSpecialty = nil
        medicalLicensePresentImage.image = nil
        medicalDiplomaPresentImage.image = nil
        idPresentImage.image = nil
        specialtyPresentImage.image = nil
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {}
        dismissVariables()
    }
    
    @IBAction func update(_ sender: UIBarButtonItem) {
        var itemString = ""
        //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
        do{
            let Personresults =  try moc!.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            if imageMedicalLicense != nil {
                let medicalLicenseString = NSLocalizedString("Medical License", comment: "In DoctorStartAiInProcess, indicate which image is updated")
                person[0].setValue(imageMedicalLicense, forKey: "doctorImageMedicalLicense")
                itemString += medicalLicenseString
            }
            if imageMedicalDiploma != nil {
                let medicalDiplomaString = NSLocalizedString("Medical Diploma", comment: "In DoctorStartAiInProcess, indicate which image is updated")
                person[0].setValue(imageMedicalDiploma, forKey: "doctorImageDiploma")
                if itemString == "" {
                    itemString = medicalDiplomaString
                }else{
                    itemString = itemString + ", " + medicalDiplomaString
                }
            }
            if imageID != nil {
                let idString = NSLocalizedString("ID or Driver License", comment: "In DoctorStartAiInProcess, indicate which image is updated")
                person[0].setValue(imageID, forKey: "doctorImageID")
                if itemString == "" {
                    itemString = idString
                }else{
                    itemString = itemString + ", " + idString
                }
            }
            if imageSpecialty != nil {
                let specialtyString = NSLocalizedString("Specialy License", comment: "In DoctorStartAiInProcess, indicate which image is updated")
                person[0].setValue(imageSpecialty, forKey: "doctorImageSpecialistLicense")
                if itemString == "" {
                    itemString = specialtyString
                }else{
                    itemString = itemString + ", " + specialtyString
                }
            }
            try moc!.save()
        } catch let error as NSError {
            print("Not fetch or save person data: \(error), \(error.userInfo)")
        }
        
        if itemString == "" {
            //alert for no update
            let noupdate = NSLocalizedString("No Update", comment: "In DoctorStartAiInProcess, title for not upate image")
            let noupdatedetail = NSLocalizedString("You do not update any image!", comment: "In DoctorStartAiInProcess, detail for success update image and what image user update")
            let cancelstring = NSLocalizedString("Cancel", comment: "Confrim for exit alert")
            Alert.show(noupdate, message: noupdatedetail, ok: cancelstring, dismissBoth: false, vc: self)
        }else{
            //alert for update successfully
            let success = NSLocalizedString("Success", comment: "In DoctorStartAiInProcess, title for success update image")
            let successdetail = NSLocalizedString("You have updated the following image(s) successfully!: ", comment: "In DoctorStartAiInProcess, detail for success update image and what image user update")
            let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            Alert.show(success, message: successdetail + itemString, ok: okstring, dismissBoth: true, vc: self)
        }
    }
    
    
    func labelToUpload(_ label: UIButton){
        label.setTitle(Storyboard.uploaded, for: UIControlState())
        label.titleLabel!.font = UIFont.systemFont(ofSize: 17)
    }
    
    func labelNoUpdate(_ label: UIButton){
        label.setTitle(MVC.NoUpdate, for: UIControlState())
        label.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }

    func descriptionLabelInit(_ label: UILabel){
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.red.cgColor
        label.text = Storyboard.PhotoPrintForVerify
    }
    
    // MARK: - medical license
    var medicalLicenseSection = 1
    @IBAction func tapMedicalLicense() {
        sectionGlobal = 0
        if imageMedicalLicense == nil{
            getPhoto()
        }else{
            if medicalLicenseSection == 1{
                medicalLicenseSection = 2
            }else{
                medicalLicenseSection = 1
            }
            tableView.reloadData()
        }
        if medicalLicenseSection == 2{
            let indexPath = IndexPath(row: 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    @IBAction func tapMedicalLicenseCamera() {
        sectionGlobal = 0
        getPhoto()
    }
    
    // MARK: - medical diploma
    var medicalDiplomaSection = 1
    @IBAction func tapMedicalDiploma() {
        sectionGlobal = 1
        if imageMedicalDiploma == nil{
            getPhoto()
        }else{
            if medicalDiplomaSection == 1{
                medicalDiplomaSection = 2
            }else{
                medicalDiplomaSection = 1
            }
            tableView.reloadData()
        }
        if medicalDiplomaSection == 2{
            let indexPath = IndexPath(row: 1, section: 1)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    @IBAction func tapMedicalDiplomaCamera() {
        sectionGlobal = 1
        getPhoto()
    }
    
    
    // MARK: - ID
    var idSection = 1
    @IBAction func tapID() {
        sectionGlobal = 2
        if imageID == nil{
            getPhoto()
        }else{
            if idSection == 1{
                idSection = 2
            }else{
                idSection = 1
            }
            tableView.reloadData()
        }
        if idSection == 2{
            let indexPath = IndexPath(row: 1, section: 2)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    @IBAction func tapIdCamera() {
        sectionGlobal = 2
        getPhoto()
    }
    
    // MARK: - Specialty
    var specialtySection = 1
    @IBAction func tapSpecialty() {
        sectionGlobal = 3
        if imageSpecialty == nil{
            getPhoto()
        }else{
            if specialtySection == 1{
                specialtySection = 2
            }else{
                specialtySection = 1
            }
            tableView.reloadData()
        }
        if specialtySection == 2{
            let indexPath = IndexPath(row: 1, section: 3)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    @IBAction func tapSpecialtyCamera() {
        sectionGlobal = 3
        getPhoto()
    }
    
    
    // MARK: - Photo
    func getPhoto(){
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
            switch(sectionGlobal){
            case 0:
                popoverController.sourceView = medicalLicenseCameraLabel
                popoverController.sourceRect = medicalLicenseCameraLabel.bounds
            case 1:
                popoverController.sourceView = medicalDiplomaCameraLabel
                popoverController.sourceRect = medicalDiplomaCameraLabel.bounds
            case 2:
                popoverController.sourceView = idCameraLabel
                popoverController.sourceRect = idCameraLabel.bounds
            default:
                popoverController.sourceView = specialtyCameraLabel
                popoverController.sourceRect = specialtyCameraLabel.bounds
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let compressRate = CGFloat(0.5)
        switch(sectionGlobal){
        case 0:
            image = resize.singleton(image! , container: medicalLicensePresentImage.image!)
            medicalLicensePresentImage.image = image
            medicalLicenseHeight = medicalLicensePresentImage.frame.width / image!.aspectRatio
            labelToUpload(medicalLicenseButton)
            if let imageData = UIImageJPEGRepresentation(image!, compressRate) {
                //print("image size %f KB:", imageData.length / 1024)
                imageMedicalLicense = imageData
                image = nil
            }
            medicalLicenseSection = 2
        case 1:
            image = resize.singleton(image! , container: medicalDiplomaPresentImage.image!)
            medicalDiplomaPresentImage.image = image
            medicalDiplomaHeight = medicalDiplomaPresentImage.frame.width / image!.aspectRatio
            labelToUpload(medicalDiplomaButton)
            if let imageData = UIImageJPEGRepresentation(image!, compressRate) {
                //print("image size %f KB:", imageData.length / 1024)
                imageMedicalDiploma = imageData
                image = nil
            }
            medicalDiplomaSection = 2
        case 2:
            image = resize.singleton(image! , container: idPresentImage.image!)
            idPresentImage.image = image
            idHeight = idPresentImage.frame.width / image!.aspectRatio
            labelToUpload(idButton)
            if let imageData = UIImageJPEGRepresentation(image!, compressRate) {
                //print("image size %f KB:", imageData.length / 1024)
                imageID = imageData
                image = nil
            }
            idSection = 2
        default:
            image = resize.singleton(image! , container: specialtyPresentImage.image!)
            specialtyPresentImage.image = image
            specialtyHeight = specialtyPresentImage.frame.width / image!.aspectRatio
            labelToUpload(specialtyButton)
            if let imageData = UIImageJPEGRepresentation(image!, compressRate) {
                //print("image size %f KB:", imageData.length / 1024)
                imageSpecialty = imageData
                image = nil
            }
            specialtySection = 2
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        switch (sectionGlobal) {
        case 0:
            imageMedicalLicense = nil
            labelNoUpdate(medicalLicenseButton)
        case 1:
            imageMedicalDiploma = nil
            labelNoUpdate(medicalDiplomaButton)
        case 2:
            imageID = nil
            labelNoUpdate(idButton)
        default:
            imageSpecialty = nil
            labelNoUpdate(specialtyButton)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return medicalLicenseSection
        }else if section == 1{
            return medicalDiplomaSection
        }else if section == 2{
            return idSection
        }else{
            return specialtySection
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            return medicalLicenseHeight
        }else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            return medicalDiplomaHeight
        }else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1 {
            return idHeight
        }else if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 1 {
            return specialtyHeight
        }
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
