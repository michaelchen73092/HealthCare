//
//  DoctorStartAhSummaryTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/27/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit
import CoreLocation
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
    @IBOutlet weak var currentHospitalAddress: UILabel!
    
    @IBOutlet weak var experienceOneLabel: UILabel!
    @IBOutlet weak var experienceTwoLabel: UILabel!
    @IBOutlet weak var experienceThreeLabel: UILabel!
    @IBOutlet weak var experienceFourLabel: UILabel!
    @IBOutlet weak var experienceFiveLabel: UILabel!
    var experienceSection = 1
    
    @IBOutlet weak var invalidCellPhone: UILabel!
    weak var moc : NSManagedObjectContext?
    
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAi"
        static let cellphonePlaceholderString = NSLocalizedString("Ex: XXX-XXX-XXXX or XXXXXXXXXX", comment: "In DoctorStartAhSummary, placeholder for cellphone format")
    }
    @IBOutlet weak var summaryDescription: UILabel!
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description textView
        summaryDescription.text = NSLocalizedString("Please check your information and documents. If you want to edit, click top right button or click submit to deliver application. Berbi will contact you within 2 business days to update your applcation status.\n\nWelcome to join Berbi group!", comment: "In DoctorStartAhSummary, description for this page")

        
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
        //print language
        if tempDoctor?.doctorLanguage != nil && tempDoctor?.doctorLanguage != ""{
            languageLabel.text = printLanguage(tempDoctor!.doctorLanguage!)
        }
        if signInUser?.doctorLicenseNumber != nil{
            medicalLicenseLabel.text = signInUser!.doctorLicenseNumber!
        }
        if let imagedata = signInUser?.doctorImageMedicalLicense {
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
            let langId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
            if langId.rangeOfString("en") != nil{
                graduatedSchoolLabel.text = School.school[Int(tempDoctor!.doctorGraduateSchool!)!][1]
            }else{
                graduatedSchoolLabel.text = School.school[Int(tempDoctor!.doctorGraduateSchool!)!][0]
            }
        }
        if let imagedata = signInUser?.doctorImageDiploma {
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
        if let imagedata = signInUser?.doctorImageID {
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
        if tempDoctor?.doctorProfessionTitle != nil {
            if Int(tempDoctor!.doctorProfessionTitle!) != nil && Int(tempDoctor!.doctorProfession!) != nil{
                specialtyLabel.text = specialty.allSpecialty[Int(tempDoctor!.doctorProfession!)!] +  " " + specialty.title[Int(tempDoctor!.doctorProfessionTitle!)!]
            }
        }else{
            specialtyLabel.text = tempDoctor?.doctorProfession
        }
        if let imagedata = signInUser?.doctorImageSpecialistLicense {
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
        printLocation()
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
            wiggleInvalidtext(invalidCellPhone, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            signInUser?.applicationStatus = Status.underReview
            saveLocal()
            //need update tempDoctor info to AWS
            //alert for update successfully
            let success = NSLocalizedString("Success", comment: "In DoctorStartAhSummary, title for successfully submit doctor application")
            let successdetail = NSLocalizedString("Congratulation! You have submitted your doctor application successfully!", comment: "In DoctorStartAhSummary, detail for successfully submit doctor application")
            let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            Alert.show(success, message: successdetail, ok: okstring, dismissBoth: true, vc: self)
        }
    }
    
    //save to local CoreData
    private func saveLocal(){
        do{
            let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
            let Personresults =  try moc!.executeFetchRequest(fetchRequestPerson)
            let person = Personresults as! [NSManagedObject]
            if signInUser?.doctorImageMedicalLicense != nil{
                person[0].setValue(signInUser?.doctorImageMedicalLicense, forKey: "doctorImageMedicalLicense")
            }
            if signInUser?.doctorImageDiploma != nil{
                person[0].setValue(signInUser?.doctorImageDiploma, forKey: "doctorImageDiploma")
            }
            if signInUser?.doctorImageID != nil{
                person[0].setValue(signInUser?.doctorImageID, forKey: "doctorImageID")
            }
            if signInUser?.doctorImageSpecialistLicense != nil{
                person[0].setValue(signInUser?.doctorImageSpecialistLicense, forKey: "doctorImageSpecialistLicense")
            }
            person[0].setValue(signInUser?.doctorLicenseNumber, forKey: "doctorLicenseNumber")
            person[0].setValue(signInUser?.cellPhone, forKey: "cellPhone")
            person[0].setValue(signInUser?.applicationStatus, forKey: "applicationStatus")
            if signInUserPublic?.imageRemoteUrl != nil && signInUserPublic?.imageRemoteUrl != ""{
                signInDoctor?.doctorImageRemoteURL = signInUserPublic!.imageRemoteUrl!
            }
            //save tempDoctor and update signInUser info
            try moc!.save()
        } catch _ as NSError
        {
            print("failure to store tempDoctor to Core Data in Submit page")
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
        if signInUser?.doctorImageDiploma != nil{
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
        if signInUser?.doctorImageID != nil{
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
        if signInUser?.doctorImageSpecialistLicense != nil{
            if specialtySection == 1{
                specialtySection = 2
            }else{
                specialtySection = 1
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Current Hospital Address
    func printLocation(){
        if (tempDoctor!.doctorHospitalLatitude! != 0) || (tempDoctor!.doctorHospitalLongitude! != 0) {
            currentHospitalAddress.font = UIFont(name: "HelveticaNeue-Light", size: 17) ?? UIFont.systemFontOfSize(17)
            let userLocation = CLLocation(latitude: Double(tempDoctor!.doctorHospitalLatitude!), longitude: Double(tempDoctor!.doctorHospitalLongitude!))
            CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if error != nil {
                    print("Inside printLocation: Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks?.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    self.displayLocationInfo(pm)
                }else{
                    print("Problem with the data received from geocoder")
                }
            }
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark){
        // put a space between "4" and "Melrose Place"
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? ""
        )
        let country = (placemark.country != nil) ? placemark.country! : ""
        currentHospitalAddress.text = addressLine + ", \(country)"

        
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
        }else if section == 7{
            return 2
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
    

    
    // MARK: - prepareForSegue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if destination is DoctorStartAiInProcessTableViewController{
            //pass current moc to next controller which use for create Persons object
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }

}



