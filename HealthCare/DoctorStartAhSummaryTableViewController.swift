//
//  DoctorStartAhSummaryTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/27/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData

class DoctorStartAhSummaryTableViewController: UITableViewController, UITextViewDelegate {
    // MARK: - Variables
    
    @IBOutlet weak var cellPhoneTextView: UITextView!{ didSet{cellPhoneTextView.delegate = self}}
    @IBOutlet weak var cellPhonePlaceholder: UILabel!

    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var medicalLicenseLabel: UILabel!
    @IBOutlet weak var invalidLicenseLabel: UILabel!
    @IBOutlet weak var licensePresentImage: UIImageView!
    var licenseHeight = CGFloat(60)
    
    @IBOutlet weak var graduatedSchoolLabel: UILabel!
    
    @IBOutlet weak var medicalDiplomaLabel: UILabel!
    @IBOutlet weak var invalidmedicalDiplomaLabel: UILabel!
    @IBOutlet weak var medicalDiplomaPresentImage: UIImageView!
    var medicalDiplomaHeight = CGFloat(60)
    @IBOutlet weak var medicalDiplomaAdd: UIImageView!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var invalidIDLabel: UILabel!
    @IBOutlet weak var idPresentImage: UIImageView!
    var idHeight = CGFloat(60)
    @IBOutlet weak var idAdd: UIImageView!
    
    @IBOutlet weak var specialtyLabel: UILabel!
    @IBOutlet weak var invalidSpecialtyLabel: UILabel!
    @IBOutlet weak var specialtyPresentImage: UIImageView!
    var specialtyHeight = CGFloat(60)
    @IBOutlet weak var specialtyAdd: UIImageView!
    
    @IBOutlet weak var currentHospitalLabel: UILabel!
    
    @IBOutlet weak var experienceOneLabel: UILabel!
    @IBOutlet weak var experienceTwoLabel: UILabel!
    @IBOutlet weak var experienceThreeLabel: UILabel!
    @IBOutlet weak var experienceFourLabel: UILabel!
    @IBOutlet weak var experienceFiveLabel: UILabel!
    var experienceSection = 1
    
    @IBOutlet weak var invalidCellPhone: UILabel!
    weak var moc : NSManagedObjectContext?
    
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAh"
        static let cellphonePlaceholderString = NSLocalizedString("Ex: XXX-XXX-XXXX or XXXXXXXXXX", comment: "In DoctorStartAhSummary, placeholder for cellphone format")
    }
    @IBOutlet weak var summaryDescription: UILabel!
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description textView
        summaryDescription.text = NSLocalizedString("Please check your information and documents. If you want to edit, click top right button or click sumit to deliver application. Berbi will contact you within 2 business days to update your applcation status.\n\nWelcome to join Berbi group!", comment: "In DoctorStartAhSummary, description for this page")

        
        //setup navigation
        let summaryTitle = NSLocalizedString("Summary", comment: "In DoctorStartAhSummary's title")
        self.navigationItem.title = summaryTitle
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.editNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.editButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //setup invalid UI
        cellPhonePlaceholder.text = MVC.cellphonePlaceholderString
        invalidCellPhone.hidden = true
        invalidLicenseLabel.layer.borderWidth = 1.0
        invalidLicenseLabel.layer.borderColor = UIColor.redColor().CGColor
        invalidLicenseLabel.text = Storyboard.PhotoPrintForVerify
        
        invalidmedicalDiplomaLabel.layer.borderWidth = 1.0
        invalidmedicalDiplomaLabel.layer.borderColor = UIColor.redColor().CGColor
        invalidmedicalDiplomaLabel.text = Storyboard.PhotoPrintForVerify
        
        invalidIDLabel.layer.borderWidth = 1.0
        invalidIDLabel.layer.borderColor = UIColor.redColor().CGColor
        invalidIDLabel.text = Storyboard.PhotoPrintForVerify
        
        invalidSpecialtyLabel.layer.borderWidth = 1.0
        invalidSpecialtyLabel.layer.borderColor = UIColor.redColor().CGColor
        invalidSpecialtyLabel.text = Storyboard.PhotoPrintForVerify
        
        //setup Initialization
        if tempDoctor?.doctorLanguage != nil{
            languageLabel.text = tempDoctor!.doctorLanguage!
        }
        if tempDoctor?.doctorLicenseNumber != nil{
            medicalLicenseLabel.text = tempDoctor!.doctorLicenseNumber!
        }
        if let imagedata = tempDoctor?.doctorImageMedicalLicense {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                let image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.licensePresentImage.image = image
                    self!.licenseHeight = self!.licensePresentImage.frame.width / image!.aspectRatio
                }
            }
        }
        if tempDoctor?.doctorGraduateSchool != nil{
            graduatedSchoolLabel.text = tempDoctor!.doctorGraduateSchool!
        }
        if let imagedata = tempDoctor?.doctorImageDiploma {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                let image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.medicalDiplomaPresentImage.image = image
                    self!.medicalDiplomaHeight = self!.medicalDiplomaPresentImage.frame.width / image!.aspectRatio
                }
            }
            labelToUpload(medicalDiplomaLabel)
        }else{
            labelnotSet(medicalDiplomaLabel, add: medicalDiplomaAdd)
        }
        if let imagedata = tempDoctor?.doctorImageID {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                let image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.idPresentImage.image = image
                    self!.idHeight = self!.idPresentImage.frame.width / image!.aspectRatio
                }
            }
            labelToUpload(idLabel)
        }else{
            labelnotSet(idLabel, add: idAdd)
        }
        //no matter there is doctorImageSpecialistLicense or not, we alway show doctorProfession
        specialtyLabel.text = tempDoctor?.doctorProfession
        if let imagedata = tempDoctor?.doctorImageSpecialistLicense {
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                let image = UIImage(data: imagedata)
                dispatch_async(dispatch_get_main_queue()) {
                    self!.specialtyPresentImage.image = image
                    self!.specialtyHeight = self!.specialtyPresentImage.frame.width / image!.aspectRatio
                }
            }
        }else{
            //no image no specialtyAdd
            specialtyAdd.hidden = true
        }
        currentHospitalLabel.text = tempDoctor?.doctorHospital
        
        if tempDoctor?.doctorExperienceOne == nil{
            experienceSection = 1
            experienceOneLabel.text = Storyboard.notSet
            experienceOneLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        }else{
            experienceSection = 1
            experienceOneLabel.text = tempDoctor!.doctorExperienceOne!
            if tempDoctor?.doctorExperienceTwo != nil{
                experienceSection = 2
                experienceTwoLabel.text = tempDoctor!.doctorExperienceTwo!
                if tempDoctor?.doctorExperienceThree != nil{
                    experienceSection = 3
                    experienceThreeLabel.text = tempDoctor!.doctorExperienceThree!
                    if tempDoctor?.doctorExperienceFour != nil{
                        experienceSection = 4
                        experienceFourLabel.text = tempDoctor!.doctorExperienceFour!
                        if tempDoctor?.doctorExperienceFive != nil{
                            experienceSection = 5
                            experienceFiveLabel.text = tempDoctor!.doctorExperienceFive!
                        }
                    }
                }
            }
        }
    }

    
    func editButtonClicked(){
        for  i in 0...6 {
            if(self.navigationController?.viewControllers[i].isKindOfClass(DoctorStartAbLanguageTableViewController) == true) {
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[i], animated: true)
                break
            }
        }
        licensePresentImage.image = nil
        medicalDiplomaPresentImage.image = nil
        idPresentImage.image = nil
        specialtyPresentImage.image = nil
    }
    
    @IBAction func sumitButton() {
        invalidCellPhone.hidden = true
        if !validatePhone(cellPhoneTextView.text){
            invalidCellPhone.hidden = false
        }else{
            
        }
    }
    
    
    func labelToUpload(label: UILabel){
        label.text = Storyboard.uploaded
        label.font = UIFont.systemFontOfSize(17)
    }
    
    func labelnotSet(label: UILabel, add: UIImageView){
        label.text = Storyboard.notSet
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        add.hidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Medical License
    var licenseSection = 1
    @IBAction func tapMedicalLicense(sender: UITapGestureRecognizer) {
        if licenseSection == 1{
            licenseSection = 2
        }else{
            licenseSection = 1
        }
        tableView.reloadData()
    }
    
    // MARK: - Medical Diploma
    var medicalDiplomaSection = 1
    @IBAction func tapMedicalDiploma(sender: UITapGestureRecognizer) {
        //if no image, no expand
        if tempDoctor?.doctorImageDiploma != nil{
            if medicalDiplomaSection == 1{
                medicalDiplomaSection = 2
            }else{
                medicalDiplomaSection = 1
            }
            tableView.reloadData()
        }
    }

    // MARK: - ID
    var idSection = 1
    @IBAction func tapID(sender: UITapGestureRecognizer) {
        //if no image, no expand
        if tempDoctor?.doctorImageID != nil{
            if idSection == 1{
                idSection = 2
            }else{
                idSection = 1
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - specialty
    var specialtySection = 1
    @IBAction func tapSpecialty(sender: UITapGestureRecognizer) {
        if tempDoctor?.doctorImageSpecialistLicense != nil{
            if specialtySection == 1{
                specialtySection = 2
            }else{
                specialtySection = 1
            }
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 9
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 2{
            return licenseSection
        }else if section == 4{
            return medicalDiplomaSection
        }else if section == 5{
            return idSection
        }else if section == 6{
            return specialtySection
        }else if section == 8{
            return experienceSection
        }
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1{
            return licenseHeight
        }
        if indexPath.section == 4 && indexPath.row == 1{
            return medicalDiplomaHeight
        }
        if indexPath.section == 5 && indexPath.row == 1{
            return idHeight
        }
        if indexPath.section == 6 && indexPath.row == 1{
            return specialtyHeight
        }
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        if !textView.hasText(){
            cellPhonePlaceholder.hidden = false
        }else{
            cellPhonePlaceholder.hidden = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true
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
