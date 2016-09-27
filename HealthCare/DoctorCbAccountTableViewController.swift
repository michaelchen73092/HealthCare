//
//  DoctorCbAccountTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/18/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices
import CoreData
import testKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


@available(iOS 10.0, *)
class DoctorCbAccountTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate , UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // MARK: - variables
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var licenseNumberLabel: UILabel!
    @IBOutlet weak var graduatedSchoolLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var specialtyFullNameLabel: UILabel!
    @IBOutlet weak var internistLabel: UILabel!
    @IBOutlet weak var pgyLabel: UILabel!
    @IBOutlet weak var primarySpecialtyLabel: UILabel!
    var specialtyLastIndex : IndexPath?
    @IBOutlet weak var specialtyPickerView: UIPickerView!
    @IBOutlet weak var specialtyLabel: UILabel!
    @IBOutlet weak var invalidLabel: UILabel!
    
    @IBOutlet weak var specialtyTitleTitleLabel: UILabel!
    @IBOutlet weak var specialtyTitleLabel: UILabel!
    @IBOutlet weak var specialtyTitleSegment: UISegmentedControl!

    @IBOutlet weak var boardCertificationLabel: UILabel!
    
    @IBOutlet weak var currentHospital: UITextView!{didSet{currentHospital.delegate = self}}
    @IBOutlet weak var HospitalAddress: UILabel!
    let MIN_SIZE = CGFloat(11.0)
    var tempLatitude : NSNumber?
    var tempLongitude : NSNumber?
    
    @IBOutlet weak var firstExperience: UITextView!{didSet{firstExperience.delegate = self}}
    @IBOutlet weak var secondExperience: UITextView!{didSet{secondExperience.delegate = self}}
    @IBOutlet weak var thirdExperience: UITextView!{didSet{thirdExperience.delegate = self}}
    @IBOutlet weak var fourthExperience: UITextView!{didSet{fourthExperience.delegate = self}}
    @IBOutlet weak var fifthExperience: UITextView!{didSet{fifthExperience.delegate = self}}
    var experienceSection = 1
    
    @IBOutlet weak var cellphone: UITextView!{didSet{cellphone.delegate = self}}
    
    @IBOutlet weak var boardCertificatedDescription: UILabel!
    var boardCertificatedSection = 1
    @IBOutlet weak var boardCertificatedImageLabel: UILabel!
    @IBOutlet weak var boardCertificationCamera: UIButton!
    var tempdoctorImageSpecialistLicense : Data?
    
    var sectionNumber = 10
    
    var tempLanguage : String?
    //deal tempSpecialty to deal all change in here, if update, update this variables to coredata
    var tempSpecialty : String?
    var tempSpecialtyTitle : String?

    
    fileprivate struct MVC{
        static let primarySpecialty = NSLocalizedString("Primary Specialty:", comment: "DoctorCbAccount")
        static let specialtyTitle = NSLocalizedString("Specialty Title:", comment: "DoctorCbAccount")
        static let languageIdentifier = "show Doctor Cc"
        static let addressIdentifier = "show Address"
        static let experienceAlertTitle = NSLocalizedString("Left Blank", comment: "In DoctorCbAccount, title for alert that do not enter blank for past experience")
        static let experienceAlertDetail = NSLocalizedString("Please do not leave blank when adding futher experience.", comment: "In DoctorCbAccount, detail for alert that do not enter blank for past experience")
        static let experienceAlertOk = NSLocalizedString("Ok", comment: "In DoctorCbAccount, ok for alert that do not enter blank for past experience")
        static let boardCertifiedDoctor = NSLocalizedString("Board Certified Doctor", comment: "In DoctorCbAccountTableViewController, for board certification, tell doctor that he/she is a Board Certified Doctor")
    }
    
    // MARK: - view cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let accountTitle = NSLocalizedString("Account", comment: "In DoctorCbAccount, title for account.")
        self.navigationItem.title = accountTitle
        
        
        //name
        let printName = printNameOrder(signInDoctor!.doctorFirstName!, lastName: signInDoctor!.doctorLastName!)
        nameLabel.text = printName
        //gender
        if signInUserPublic!.gender!.boolValue{
            genderLabel.text = Storyboard.female
        }else{
            genderLabel.text = Storyboard.male
        }
        //birthday
        let dateFormatter = DateFormatter()
        // set dateFormate
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthdayLabel.text = dateFormatter.string(from: (signInUserPublic?.birthday)!)
        if signInUser?.doctorLicenseNumber != nil && signInUser!.doctorLicenseNumber! != ""{
            licenseNumberLabel.text = signInUser!.doctorLicenseNumber!
        }
        //graduated school
        if signInDoctor?.doctorGraduateSchool != nil && signInDoctor!.doctorGraduateSchool! != "" {
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            if langId.range(of: "en") != nil{
                graduatedSchoolLabel.text = School.school[Int(signInDoctor!.doctorGraduateSchool!)!][1]
            }else{
                graduatedSchoolLabel.text = School.school[Int(signInDoctor!.doctorGraduateSchool!)!][0]
            }
        }
        //language
        //print language
        //tempLanguage need to set before DoctorAccountLanguageBack()
        tempLanguage = signInDoctor!.doctorLanguage!
        DoctorAccountLanguageBack()
        
        //add notification for language send back
        NotificationCenter.default.addObserver(self, selector: #selector(self.DoctorAccountLanguageBack), name: NSNotification.Name(rawValue: "DoctorAccountLanguageBack"), object: nil)
        
        //if not speciality hidden specialtyLabel
        specialtyLabel.isHidden = true
        //specialty
        internistLabel.text = Storyboard.internist
        pgyLabel.text = Storyboard.pgy
        primarySpecialtyLabel.text = MVC.primarySpecialty
        invalidLabel.isHidden = true
        if signInDoctor?.doctorProfessionTitle != nil {
            if Int(signInDoctor!.doctorProfessionTitle!) != nil && signInDoctor!.doctorProfession != nil && Int(signInDoctor!.doctorProfession!) != nil{
                specialtyFullNameLabel.text = specialty.allSpecialty[Int(signInDoctor!.doctorProfession!)!] +  " " + specialty.title[Int(signInDoctor!.doctorProfessionTitle!)!]
            }
        }else{
            specialtyFullNameLabel.text = signInDoctor!.doctorProfession!
            print("signInDoctor!.doctorProfession!:\(signInDoctor!.doctorProfession)")
        }
        // deal with previous checkmark
        if signInDoctor?.doctorProfession != nil {
            if signInDoctor!.doctorProfession! == "Internist"{
                specialtyLastIndex = IndexPath(row: 1, section: 4)
            }else if signInDoctor!.doctorProfession!.range(of: "PGY") != nil {
                specialtyLastIndex = IndexPath(row: 2, section: 4)
            }else{
                specialtyLastIndex = IndexPath(row: 3, section: 4)
                specialtyLabel.isHidden = false
                if Int(signInDoctor!.doctorProfession!) != nil {
                    specialtyLabel.text = specialty.allSpecialty[Int(signInDoctor!.doctorProfession!)!]
                }
            }
        }
        
        tempSpecialty = signInDoctor!.doctorProfession!
        specialtyPickerView.delegate = self
        specialtyPickerView.dataSource = self

        
        //specialty title
        specialtyTitleTitleLabel.text = MVC.specialtyTitle
        specialtyTitleLabel.text = Storyboard.notSet
        if signInDoctor?.doctorProfessionTitle != nil{
            if Int(signInDoctor!.doctorProfessionTitle!) != nil{
                specialtyTitleLabel.text = specialty.title[Int(signInDoctor!.doctorProfessionTitle!)!]
                specialtyTitleLabel.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
                //assign doctorProfessionTitle to tempSpecialtyTitle if it has
                tempSpecialtyTitle = signInDoctor!.doctorProfessionTitle!
            }
        }
        specialtyTitleSegment.setTitle(specialty.title[0], forSegmentAt: 0)
        specialtyTitleSegment.setTitle(specialty.title[1], forSegmentAt: 1)
        specialtyTitleSegment.setTitle(specialty.title[2], forSegmentAt: 2)

        // deal with previous checkmark
        if signInDoctor?.doctorProfessionTitle != nil {
            switch(Int(signInDoctor!.doctorProfessionTitle!)!){
            case 0 :
                specialtyTitleSegment.selectedSegmentIndex = 0
            case 1 :
                specialtyTitleSegment.selectedSegmentIndex = 1
            default :
                specialtyTitleSegment.selectedSegmentIndex = 2
            }
        }else{
            specialtyTitleSegment.selectedSegmentIndex = 0
        }
        
        //Board Certification
        
        if signInDoctor!.doctorCertificated!.boolValue{
            boardCertificationLabel.text = MVC.boardCertifiedDoctor
            sectionNumber = 9
        }else{
            boardCertificationLabel.text = Storyboard.notSet
            boardCertificationLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
            sectionNumber = 10
        }
        
        //current hospital
        if signInDoctor?.doctorHospital != nil{
            currentHospital.text = signInDoctor!.doctorHospital!
        }else{
            currentHospital.text = Storyboard.notSet
            currentHospital.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        }
        if signInDoctor?.doctorHospitalLatitude != nil && signInDoctor?.doctorHospitalLongitude != nil && !(signInDoctor!.doctorHospitalLatitude! == 0 && signInDoctor!.doctorHospitalLongitude! == 0){
            printLocation()
        }else{
            HospitalAddress.text = Storyboard.notSet
            HospitalAddress.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        }
        
        //add location back notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.HospitalAddressBackUpdate), name: NSNotification.Name(rawValue: "HospitalAddress"), object: nil)
        
        //past experience
        if signInDoctor?.doctorExperienceOne == nil{
            experienceSection = 1
            firstExperience.text = Storyboard.notSet
        }else{
            experienceSection = 1
            firstExperience.text = signInDoctor!.doctorExperienceOne!
            if signInDoctor?.doctorExperienceTwo != nil{
                experienceSection = 2
                secondExperience.text = signInDoctor!.doctorExperienceTwo!
                if signInDoctor?.doctorExperienceThree != nil{
                    experienceSection = 3
                    thirdExperience.text = signInDoctor!.doctorExperienceThree!
                    if signInDoctor?.doctorExperienceFour != nil{
                        experienceSection = 4
                        fourthExperience.text = signInDoctor!.doctorExperienceFour!
                        if signInDoctor?.doctorExperienceFive != nil{
                            experienceSection = 5
                            fifthExperience.text = signInDoctor!.doctorExperienceFive!
                        }
                    }
                }
            }
        }
        
        //cell phone
        if signInUser?.cellPhone != nil{
            cellphone.text = signInUser!.cellPhone!
        }
        
        //board certificated image upload
        boardCertificatedDescription.text = NSLocalizedString("If you want to upload your board certification license, please tap plus button on right. If you want to canel upload, please tap minus button.", comment: "In DoctorCbAccountTableViewController, for upload board certification licese image, tell doctor how to upload image")
        
        
        let saveTitle = NSLocalizedString("Update", comment: "In PersonsCbAccount, the title for save update")
        let rightSaveNavigationButton = UIBarButtonItem(title: saveTitle , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveButtonClicked))
        self.navigationItem.rightBarButtonItem = rightSaveNavigationButton
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func DoctorAccountLanguageBack(){
        if signInDoctor?.doctorLanguage != nil && signInDoctor?.doctorLanguage != ""{
            languageLabel.text = printLanguage(signInDoctor!.doctorLanguage!)
        }
        //put updated language into tempLanguage and set signInDoctor!.doctorLanguage! to origianl
        //if not updated, still signInDoctor!.doctorLanguage = signInDoctor!.doctorLanguage
        let updated = signInDoctor!.doctorLanguage!
        signInDoctor!.doctorLanguage = tempLanguage
        tempLanguage = updated
    }
    
    func printLocation(){
        if !(signInDoctor!.doctorHospitalLatitude! == 0 && signInDoctor!.doctorHospitalLongitude! == 0) {
            let userLocation = CLLocation(latitude: Double(signInDoctor!.doctorHospitalLatitude!), longitude: Double(signInDoctor!.doctorHospitalLongitude!))
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
    
    func displayLocationInfo(_ placemark: CLPlacemark){
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
        HospitalAddress.text = addressLine + ", \(country)"
        
    }
    
    func HospitalAddressBackUpdate(){
        printLocation()
        let tempLa = tempLatitude
        let tempLo = tempLongitude
        tempLatitude = signInDoctor!.doctorHospitalLatitude!
        tempLongitude = signInDoctor!.doctorHospitalLongitude!
        signInDoctor?.doctorHospitalLatitude = tempLa
        signInDoctor?.doctorHospitalLongitude = tempLo
    }
    
    @objc
    fileprivate func saveButtonClicked(){
        //verified specialty
        cellphone.resignFirstResponder()
        firstExperience.resignFirstResponder()
        secondExperience.resignFirstResponder()
        thirdExperience.resignFirstResponder()
        fourthExperience.resignFirstResponder()
        fifthExperience.resignFirstResponder()
        currentHospital.resignFirstResponder()
        
        if tempSpecialty != nil {
            if tempSpecialty! == "Internist" || tempSpecialty!.range(of: "PGY") != nil{
            }else{
                
                if tempSpecialtyTitle != nil{
                }else{
                    specialistSection = 7
                    tableView.reloadData()
                    invalidLabel.isHidden = false
                    wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
                    let indexPath = IndexPath(row: 4, section: 4)
                    tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                    return
                }
            }
        }else{
            specialistSection = 7
            tableView.reloadData()
            invalidLabel.isHidden = false
            wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
            let indexPath = IndexPath(row: 4, section: 4)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            return
        }
        
        //end specialty
        //verified current hospital address
        if  tempLongitude != nil && tempLatitude != nil && (tempLatitude! == 0) && (tempLongitude! == 0) || currentHospital.text == "" {
            let hospitalTitle = NSLocalizedString("Current Hospital Blank", comment: "In DoctorCbAccount, title for alert update information or not.")
            let hospitalDetail = NSLocalizedString("Please enter current hospital/clinic AND its address.", comment: "In DoctorCbAccount, title for alert update information or not.")
            Alert.show(hospitalTitle, message: hospitalDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
            return
        }//end current hospital
        //verified past experiense
        if (experienceSection == 2 && (firstExperience.text == "")) || (experienceSection == 3 && (firstExperience.text == "" || secondExperience.text == "")) || (experienceSection == 4 && (firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "")) || (experienceSection == 5 && (firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "" || fourthExperience.text == "")){
            let experienceTitle = NSLocalizedString("Past Experience", comment: "In DoctorCbAccount, title for alert update information or not.")
            let experienceDetail = NSLocalizedString("Please do not leave blank when adding futher experience.", comment: "In DoctorCbAccount, title for alert update information or not.")
            Alert.show(experienceTitle, message: experienceDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
            return
        }//end past experiense
        //verified cellphone
        if !validatePhone(cellphone.text){
            let cellphoneTitle = NSLocalizedString("Cell Phone", comment: "In DoctorCbAccount, title for alert update information or not.")
            let cellphoneDetail = NSLocalizedString("Please enter a valide USA cell phone number.", comment: "In DoctorCbAccount, title for alert update information or not.")
            Alert.show(cellphoneTitle, message: cellphoneDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
            return
        }
        //after all check, tell doctor what did he/she update
        alertForUpdate()
    }//end save buttonclicked()
    
    func alertForUpdate(){
            let updateTitle = NSLocalizedString("Update Information", comment: "In DoctorCbAccount, title for alert update information or not.")
            var updateDetail : String?
            
            if tempdoctorImageSpecialistLicense != nil {
                updateDetail = NSLocalizedString("You try to update following items. After updating, your information will immediatedly change. And your board certificated license will be reviewed by our specialist. We will tell you the final result within two business days.", comment: "In DoctorCbAccount, detail for alert update information which include board certification image.")
            }else{
                updateDetail = NSLocalizedString("You try to update following items. After updating, your information will immediatedly change.", comment: "In DoctorCbAccount, detail for alert update information which not include board certification image.")
            }
            let language = NSLocalizedString("Language", comment: "In DoctorCbAccount, items are been update.")
            let specialty = NSLocalizedString("Area of Practice", comment: "In DoctorCbAccount, items are been update.")
            let currentHospitalString = NSLocalizedString("Current Hospital", comment: "In DoctorCbAccount, items are been update.")
            let currentHospitalAddress = NSLocalizedString("Current Hospital Address", comment: "In DoctorCbAccount, items are been update.")
            let pastExperience = NSLocalizedString("Past Experience", comment: "In DoctorCbAccount, items are been update.")
            let cellPhoneString = NSLocalizedString("Cell Phone", comment: "In DoctorCbAccount, items are been update.")
            let boardCertificationImage = NSLocalizedString("Board Certification Image", comment: "In DoctorCbAccount, items are been update.")
            let updateItems = NSLocalizedString("Updated Items:", comment: "In DoctorCbAccount, tell dotor that what item he/she is try to update")
            var items = ""
            if tempLanguage != nil && signInDoctor!.doctorLanguage != nil && tempLanguage != signInDoctor!.doctorLanguage!{
                items = language
            }
            if tempSpecialty != nil && signInDoctor!.doctorProfession != nil && tempSpecialty != signInDoctor!.doctorProfession!{
                if items == ""{
                    items = specialty
                }else{
                    items = items + ", "+specialty
                }
            }
            
            if signInDoctor!.doctorHospital != nil && currentHospital.text != signInDoctor!.doctorHospital! {
                if items == ""{
                    items = currentHospitalString
                }else{
                    items = items + ", "+currentHospitalString
                }
            }
            if tempLatitude != nil && tempLongitude != nil && !(tempLatitude! == 0 || tempLongitude! == 0) && (signInDoctor!.doctorHospitalLatitude != nil && tempLatitude != signInDoctor!.doctorHospitalLatitude! || signInDoctor!.doctorHospitalLongitude != nil && tempLongitude != signInDoctor!.doctorHospitalLongitude!){
                if items == ""{
                    items = currentHospitalAddress
                }else{
                    items = items + ", "+currentHospitalAddress
                }
            }
            if (firstExperience.text != signInDoctor!.doctorExperienceOne) || (secondExperience.text != signInDoctor!.doctorExperienceTwo) || (thirdExperience.text != signInDoctor!.doctorExperienceThree) || (fourthExperience.text != signInDoctor!.doctorExperienceFour) || (fifthExperience.text != signInDoctor!.doctorExperienceFive) {
                if items == ""{
                    items = pastExperience
                }else{
                    items = items + ", "+pastExperience
                }
            }
            if signInUser!.cellPhone != nil && cellphone.text != signInUser!.cellPhone! {
                if items == ""{
                    items = cellPhoneString
                }else{
                    items = items + ", "+cellPhoneString
                }
            }
            if tempdoctorImageSpecialistLicense != nil {
                if items == ""{
                    items = boardCertificationImage
                }else{
                    items = items + ", "+boardCertificationImage
                }
            }
            if items != "" {
                let alert = UIAlertController(title: updateTitle, message: updateDetail!+"\n\n"+updateItems+" "+items, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: Storyboard.ConfirmAlert, style: .default, handler: { [weak self] (action: UIAlertAction!) in
                    alert.dismiss(animated: true, completion: nil)
                    self!.navigationController?.popViewController(animated: true)
                    //need to update to AWS
                    self!.savelocal()
                    }))
                
                alert.addAction(UIAlertAction(title: Storyboard.CancelAlert, style: .cancel, handler: { (action: UIAlertAction!) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                
                present(alert, animated: true, completion: nil)
            }else{
                let noItems = NSLocalizedString("You do not update any item.", comment: "In DoctorCbAccount, tell dotor that what item he/she is try to update")
                Alert.show(updateTitle, message: noItems, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
            }
       
    }
    
    func savelocal(){
        do{
            
            //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
            let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
            let Personresults =  try moc.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            
            //let fetchRequestDoctor = NSFetchRequest(entityName: "Doctors")
            let fetchRequestDoctor: NSFetchRequest<Doctors> = Doctors.fetchRequest() as! NSFetchRequest<Doctors>
            let Doctorresults =  try moc.fetch(fetchRequestDoctor)
            let Doctor = Doctorresults //as! [NSManagedObject]

            if tempLanguage != nil && signInDoctor!.doctorLanguage != nil && tempLanguage != signInDoctor!.doctorLanguage!{
                Doctor[0].setValue(tempLanguage, forKey: "doctorLanguage")
                signInDoctor?.doctorLanguage = tempLanguage
            }
            if tempSpecialty != nil && signInDoctor!.doctorProfession != nil && tempSpecialty != signInDoctor!.doctorProfession!{
                Doctor[0].setValue(tempSpecialty, forKey: "doctorProfession")
                signInDoctor?.doctorProfession = tempSpecialty
                Doctor[0].setValue(tempSpecialtyTitle, forKey: "doctorProfessionTitle")
                signInDoctor?.doctorProfessionTitle = tempSpecialtyTitle
            }
            if signInDoctor!.doctorHospital != nil && currentHospital.text != signInDoctor!.doctorHospital! {
                Doctor[0].setValue(currentHospital.text, forKey: "doctorHospital")
                signInDoctor?.doctorHospital = currentHospital.text
            }
            if tempLatitude != nil && tempLongitude != nil && !(tempLatitude! == 0 || tempLongitude! == 0) && (signInDoctor!.doctorHospitalLatitude != nil && tempLatitude != signInDoctor!.doctorHospitalLatitude! || signInDoctor!.doctorHospitalLongitude != nil && tempLongitude != signInDoctor!.doctorHospitalLongitude!){
                Doctor[0].setValue(tempLatitude, forKey: "doctorHospitalLatitude")
                Doctor[0].setValue(tempLongitude, forKey: "doctorHospitalLongitude")
                signInDoctor?.doctorHospitalLatitude = tempLatitude
                signInDoctor?.doctorHospitalLongitude = tempLongitude
            }
            if firstExperience.text != Storyboard.notSet && firstExperience.text != ""{
                Doctor[0].setValue(firstExperience.text, forKey: "doctorExperienceOne")
                signInDoctor?.doctorExperienceOne = firstExperience.text
            }else{
                Doctor[0].setValue(nil, forKey: "doctorExperienceOne")
                signInDoctor?.doctorExperienceOne = nil
            }
            if secondExperience.text != "" {
                Doctor[0].setValue(secondExperience.text, forKey: "doctorExperienceTwo")
                signInDoctor?.doctorExperienceTwo = secondExperience.text
            }else{
                Doctor[0].setValue(nil, forKey: "doctorExperienceTwo")
                signInDoctor?.doctorExperienceTwo = nil
            }
            if thirdExperience.text != "" {
                Doctor[0].setValue(thirdExperience.text, forKey: "doctorExperienceThree")
                signInDoctor?.doctorExperienceThree = thirdExperience.text
            }else{
                Doctor[0].setValue(nil, forKey: "doctorExperienceThree")
                signInDoctor?.doctorExperienceThree = nil
            }
            if fourthExperience.text != "" {
                Doctor[0].setValue(fourthExperience.text, forKey: "doctorExperienceFour")
                signInDoctor?.doctorExperienceFour = fourthExperience.text
            }else{
                Doctor[0].setValue(nil, forKey: "doctorExperienceFour")
                signInDoctor?.doctorExperienceFour = nil
            }
            if fifthExperience.text != "" {
                Doctor[0].setValue(fifthExperience.text, forKey: "doctorExperienceFive")
                signInDoctor?.doctorExperienceFive = fifthExperience.text
            }else{
                Doctor[0].setValue(nil, forKey: "doctorExperienceFive")
                signInDoctor?.doctorExperienceFive = nil
            }
            if signInUser!.cellPhone != nil && cellphone.text != signInUser!.cellPhone! {
                person[0].setValue(cellphone.text, forKey: "cellPhone")
                signInUser?.cellPhone = cellphone.text
            }
            if tempdoctorImageSpecialistLicense != nil {
                person[0].setValue(tempdoctorImageSpecialistLicense, forKey: "doctorImageSpecialistLicense")
                signInUser?.doctorImageSpecialistLicense = tempdoctorImageSpecialistLicense
            }
            //save tempDoctor and update signInUser info
            try moc.save()
        }catch _ as NSError
        {
            print("failure to store doctor's data to Core Data in update page in DoctorCbAccountTableViewController")
        }
        
        
    }
    
    // MARK: - specialty
    var specialistSection = 1
    
    @IBAction func tapSpecialty(_ sender: UITapGestureRecognizer) {
        if specialistSection == 1 {
            specialistSection = 4
            //it has to be reloadData to view 4 section before show checkmark in below
            tableView.reloadData()
            if specialtyLastIndex != nil{
                let cell = tableView.cellForRow(at: specialtyLastIndex!)
                cell?.accessoryType = .checkmark
                specialtyLastIndex = nil
            }
            //tableView.reloadData()
        }else if specialistSection == 4{
            specialistSection = 1
            tableView.reloadData()
        }else{
            //three place to check specialty formate is correct (select specialty + specialty title) (1)
            
            if tempSpecialtyTitle != nil && Int(tempSpecialtyTitle!) != nil && tempSpecialty != nil && Int(tempSpecialty!) != nil{
                specialistSection = 1
                tableView.reloadData()
            }else{
                invalidLabel.isHidden = false
                wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
                tableView.reloadData()
                let indexPath = IndexPath(row: 4, section: 4)
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            }

        }
    }
    

    @IBAction func tapInternist(_ sender: UITapGestureRecognizer) {
        tempSpecialty = "Internist"
        tempSpecialtyTitle =  nil
        specialtyTitleLabel.text = Storyboard.notSet
        specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        specialtyFullNameLabel.text = Storyboard.internist
        //checkmark
        var index = IndexPath(row: 2, section: 4)
        var cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .none
        index = IndexPath(row: 3, section: 4)
        cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .none
        index = IndexPath(row: 1, section: 4)
        cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .checkmark
        specialistSection = 4
        specialtyLabel.isHidden = true
        tableView.reloadData()
    }
    
    @IBAction func tapPGY(_ sender: UITapGestureRecognizer) {
        tempSpecialty = "PGY(Taiwan medical system only)"
        tempSpecialtyTitle =  nil
        specialtyTitleLabel.text = Storyboard.notSet
        specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        specialtyFullNameLabel.text = Storyboard.pgy
        // deselect others
        //checkmark
        var index = IndexPath(row: 1, section: 4)
        var cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .none
        index = IndexPath(row: 3, section: 4)
        cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .none
        index = IndexPath(row: 2, section: 4)
        cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .checkmark
        specialistSection = 4
        specialtyLabel.isHidden = true
        tableView.reloadData()
    }
    
    @IBAction func tapPrimarySpecialty(_ sender: UITapGestureRecognizer) {
        if specialistSection == 4 {
            specialistSection = 7
            tableView.reloadData()
            
            invalidLabel.isHidden = true
            // deselect others
            var index = IndexPath(row: 1, section: 4)
            var cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .none
            index = IndexPath(row: 2, section: 4)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .none
            //checkmark
            index = IndexPath(row: 3, section: 4)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .checkmark
            let indexPath = IndexPath(row: 6, section: 4)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            //clear previous value if it is not specialty
            if tempSpecialty != nil{
                if Int(tempSpecialty!) == nil{
                    tempSpecialty = nil
                }
            }
            if tempSpecialtyTitle == nil {
                specialtyTitleSegment.selectedSegmentIndex = 0
                specialtyTitleLabel.text = Storyboard.notSet
                specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
            }
            
            tableView.reloadData()
        }else {
            //three place to check specialty formate is correct (select specialty + specialty title) (2)
            if tempSpecialtyTitle != nil && Int(tempSpecialtyTitle!) != nil && tempSpecialty != nil && Int(tempSpecialty!) != nil{
                    specialtyFullNameLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!] +  " " + specialty.title[Int(tempSpecialtyTitle!)!]
                    specialtyLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!]
                    specialistSection = 4
                    tableView.reloadData()
            }else{
                invalidLabel.isHidden = false
                wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
                tableView.reloadData()
                let indexPath = IndexPath(row: 4, section: 4)
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            }
        }
    }
    
    
    // MARK: - specialty title
    @IBAction func selectTitle(_ sender: AnyObject) {
        var idx = 0
        if specialtyTitleSegment.selectedSegmentIndex == 0{
            tempSpecialtyTitle = "0"
        }else if specialtyTitleSegment.selectedSegmentIndex == 1 {
            tempSpecialtyTitle = "1"
            idx = 1
        }
        else {
            tempSpecialtyTitle = "2"
            idx = 2
        }
        specialtyTitleLabel.text = specialty.title[idx]
        specialtyTitleLabel.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
        //it change whole label only when we got specialty + title
        if tempSpecialtyTitle != nil && Int(tempSpecialtyTitle!) != nil && tempSpecialty != nil && Int(tempSpecialty!) != nil{
            specialtyFullNameLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!] +  " " + specialty.title[Int(tempSpecialtyTitle!)!]
        }
    }

    
    func changeSpecialtyFullNameLabeltext(){
        //with specialty + specialty title ->change SpecialtyFullNameLabe
        //if only specialty title -> not chage
        if tempSpecialty != nil && Int(tempSpecialty!) != nil{
            specialtyFullNameLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!] +  " " + specialty.title[Int(tempSpecialtyTitle!)!]
            tableView.reloadData()
        }
    }
    
    // MARK: - Current Hospital
    @IBAction func currentHospitalEditButton() {
        currentHospital.becomeFirstResponder()
    }
    
    @IBAction func tapAddress(_ sender: UITapGestureRecognizer) {
        tempLatitude = signInDoctor!.doctorHospitalLatitude!
        tempLongitude = signInDoctor!.doctorHospitalLongitude!
        performSegue(withIdentifier: MVC.addressIdentifier, sender: nil)
    }
    
    // MARK: - Past Experience
    @IBAction func firstExperienceAdd() {
        if firstExperience.text == ""{
            Alert.show(MVC.experienceAlertTitle, message: MVC.experienceAlertDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
        }else{
            experienceSection = 2
            tableView.reloadData()
        }
    }
    
    @IBAction func secondExperienceSub() {
        if experienceSection == 2{
            experienceSection = 1
            secondExperience.text = ""
            tableView.reloadData()
        }
    }
    
    @IBAction func secondExperienceAdd() {
        if firstExperience.text == "" || secondExperience.text == ""{
            Alert.show(MVC.experienceAlertTitle, message: MVC.experienceAlertDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
        }else{
            experienceSection = 3
            tableView.reloadData()
        }
    }
    
    @IBAction func thirdExperienceSub() {
        if experienceSection == 3{
            experienceSection = 2
            thirdExperience.text = ""
            tableView.reloadData()
        }
    }
    
    @IBAction func thirdExperienceAdd() {
        if firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == ""{
            Alert.show(MVC.experienceAlertTitle, message: MVC.experienceAlertDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
        }else{
            experienceSection = 4
            tableView.reloadData()
        }
    }
    
    @IBAction func fourthExperienceSub() {
        if experienceSection == 4{
            experienceSection = 3
            fourthExperience.text = ""
            tableView.reloadData()
        }
    }
    
    @IBAction func fourthExperienceAdd() {
        if firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "" || fourthExperience.text == ""{
            Alert.show(MVC.experienceAlertTitle, message: MVC.experienceAlertDetail, ok: MVC.experienceAlertOk, dismissBoth: false, vc: self)
        }else{
            experienceSection = 5
            tableView.reloadData()
        }
    }
    
    @IBAction func fifthExperienceSub() {
        if experienceSection == 5{
            experienceSection = 4
            fifthExperience.text = ""
            tableView.reloadData()
        }
    }
    
    // MARK: - cellphone
    @IBAction func tapCellPhone() {
        cellphone.becomeFirstResponder()
    }
    
    // MARK: - upload board certificated image
    
    @IBAction func tapBCadd() {
        boardCertificatedSection = 2
        if tempdoctorImageSpecialistLicense != nil {
            boardCertificatedImageLabel.text = Storyboard.uploaded
        }else{
            boardCertificatedImageLabel.text = Storyboard.notSet
            boardCertificatedImageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        }
        tableView.reloadData()
        let indexPath = IndexPath(row: 1, section: 9)
        tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    @IBAction func tapBCsub() {
        boardCertificatedSection = 1
        tempdoctorImageSpecialistLicense = nil
        tableView.reloadData()
    }
    
    @IBAction func tapCamera() {
        getPhoto()
    }
    
    @IBAction func tapCameraRow(_ sender: UITapGestureRecognizer) {
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
            popoverController.sourceView = boardCertificationCamera
            popoverController.sourceRect = boardCertificationCamera.bounds
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        boardCertificatedImageLabel.text = Storyboard.uploaded
        boardCertificatedImageLabel.font = UIFont(name: "HelveticaNeue", size: 16) ?? UIFont.systemFont(ofSize: 16)
        if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
            //print("image size %f KB:", imageData.length / 1024)
            tempdoctorImageSpecialistLicense = imageData
            image = nil
        }
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        tempdoctorImageSpecialistLicense = nil
        boardCertificatedDescription.text = Storyboard.notSet
        boardCertificatedDescription.font = UIFont(name: "HelveticaNeue-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialty.allSpecialty.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialty.allSpecialty[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        specialtyLabel.text = specialty.allSpecialty[row]
        specialtyLabel.isHidden = false
        tempSpecialty = String(row)
        if tempSpecialtyTitle != nil {
            if Int(tempSpecialtyTitle!) != nil && Int(tempSpecialty!) != nil{
                specialtyFullNameLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!] +  " " + specialty.title[Int(tempSpecialtyTitle!)!]
            }
        }else{
            if Int(tempSpecialty!) != nil {
                specialtyFullNameLabel.text = specialty.allSpecialty[Int(tempSpecialty!)!]
            }
        }
    }
    
    // MARK: - Keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        //currentHospital is updated and ready to update
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let pos = textView.endOfDocument
        let currentRect = textView.caretRect(for: pos)
        if textView.bounds.size.width - 20 <= currentRect.origin.x{
            if textView.font?.pointSize >= MIN_SIZE{
                textView.font = UIFont.systemFont(ofSize: textView.font!.pointSize - 1)
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionNumber
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 3
        }else if section == 4{
            return specialistSection
        }else if section == 6{
            return 2
        }else if section == 7{
            return experienceSection
        }else if section == 9{
            return boardCertificatedSection
        }
        return 1
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

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.destination as? DoctorCcLanguageTableViewController{
            let temp = signInDoctor!.doctorLanguage!
            signInDoctor!.doctorLanguage = tempLanguage
            tempLanguage = temp
        }
        
//        if let identifier = segue.identifier {
//            if identifier == MVC.languageIdentifier{
//                if let _ = segue.destinationViewController as? DoctorCcLanguageTableViewController{
//                    let temp = signInDoctor!.doctorLanguage!
//                    signInDoctor!.doctorLanguage = tempLanguage
//                    tempLanguage = temp
//                }
//            }
//        }
    }
}
