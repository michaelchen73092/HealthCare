//
//  DoctorAaNowTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/2/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class DoctorAaNowTableViewController: UITableViewController {

    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorImageView: UIImageView!

    //description follow top to down order
    @IBOutlet weak var doctorSpecialty: UILabel!
    @IBOutlet weak var doctorGraduateSchool: UILabel!
    @IBOutlet weak var doctorCurrentHospital: UILabel!
    @IBOutlet weak var doctorLanguage: UILabel!
    //right board certificated image
    @IBOutlet weak var doctorIsBoardCertificated: UIImageView!

    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    ///////////////////////////
    //general reservation setting
    @IBOutlet weak var presentQuota: UILabel!
    @IBOutlet weak var quotaSlider: UISlider!
    
    
    @IBOutlet weak var onlineSwitch: UISwitch!
    @IBOutlet weak var onlineLabel: UILabel!
    

    
    @IBOutlet weak var descriptionOneTitle: UILabel!
    @IBOutlet weak var descriptionOne: UILabel!
    @IBOutlet weak var descriptionTwoTitle: UILabel!
    @IBOutlet weak var descriptionTwo: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
 //   @IBOutlet weak var checkUsagedescription: UILabel!
    @IBOutlet weak var checkUsageButton: UIButton!
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation title
        doctorUpdateUI(doctorNameLabel, doctorGraduateSchool: doctorGraduateSchool,doctorCurrentHospital: doctorCurrentHospital,doctorLanguage: doctorLanguage, doctorSpecialty: doctorSpecialty, doctorImageView:doctorImageView, doctorIsBoardCertificated: doctorIsBoardCertificated, doctor:signInDoctor, starA: starOne, starB: starTwo, starC: starThree, starD: starFour, starE: starFive)
        self.navigationItem.title = doctorNameLabel.text
        tableView.allowsSelection = false
        //setup UI
        onlineLabel.text = Storyboard.offLine
        onlineLabel.textColor = UIColor.lightGray
        presentQuota.text = "\(Int(quotaSlider.value))"
        //setup General appointment UI
        presentQuota.layer.borderWidth = 1.0
        presentQuota.layer.borderColor = UIColor.lightGray.cgColor
        checkButton.layer.borderWidth = 1.0
        checkButton.layer.borderColor = UIColor.darkGray.cgColor
        descriptionOneTitle.text = NSLocalizedString("Maximum Waitlist Patients:", comment: "In DoctorStartAfSpecialist's general appointment , Set Quota for max patients can be online")
        descriptionOne.text = NSLocalizedString("Maximum number that patients can be on waitlist. When your waitlist is reaching this number, system will automatically change your status to OFFLINE. After you have vacant, system will turn your status ONLINE again.", comment: "In DoctorStartAfSpecialist's general reservation, description for set quota")
        descriptionTwoTitle.text = NSLocalizedString("Guideline:", comment: "In DoctorStartAfSpecialist's general reservation note")
        descriptionTwo.text = NSLocalizedString("1) After tapping confirm button, system will offical turn your status into ONLINE. Users are able to search you and make appointment.\n\n2) You can stop making appointments by turning your status OFFLINE. System will stop any further appointment from patients.\n\n3) Please response patient's appointment within 20 minutes, or system regards you as OFFLINE and cancels all reservations on your waitlist. And please notice that all patients on your waitlist have permission to leave comment and give evaluation to you.", comment: "In DoctorStartAfSpecialist's general appointment, description for How it works?")
        checkUsageButton.setTitle(NSLocalizedString("Tap checkbox after read below guidelines.", comment: "In DoctorStartAfSpecialist's general appointment note"), for: UIControlState())
    }


    @IBAction func onOffSwitch(_ sender: UISwitch) {
        if !onlineSwitch.isOn {
            onlineLabel.textColor = UIColor.lightGray
            onlineLabel.text = Storyboard.offLine
            onlineSwitch.setOn(false, animated: true)
        }else{
            onlineLabel.textColor = UIColor(netHex: 0x42D451)
            onlineLabel.text = Storyboard.onLine
            onlineSwitch.setOn(true, animated: true)
        }
    }

    @IBAction func tapcheckMark() {
        checkMark()
    }
    
    @IBAction func tapcheckButton() {
        checkMark()
    }
    
    fileprivate func checkMark(){
        if checkButton.currentImage == nil{
            checkButton.setImage(UIImage(named: "checkMark"), for: UIControlState())
        }else{
            checkButton.setImage(nil, for: UIControlState())
        }
    }
    
    @IBAction func tapInfo() {
        if generalReservationSection == 1{
            generalReservationSection = 2
        }else{
            generalReservationSection = 1
        }
        tableView.reloadData()
    }
    
    
    
    @IBAction func tapConfirm() {
        if checkButton.currentImage == nil{
            //alert that no click Guildline
            let fail = NSLocalizedString("No CheckMark", comment: "In DoctorStartAfSpecialist's general reservation, title for not tap checkmark.")
            let details = NSLocalizedString("Please read guildlines and tap checkbox.", comment: "In DoctorStartAfSpecialist's general reservation, detail for not tap checkmark.")
            let okstring = NSLocalizedString("Cancel", comment: "In DoctorStartAfSpecialist's general reservation, cancel for not tap checkmark.")
            Alert.show(fail, message: details, ok: okstring, dismissBoth: false,vc: self)
        }else{
            //upload quota to AWS
            generalReservation.quota = Int(presentQuota.text!)
            performSegue(withIdentifier: "Show DoctorAb", sender: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - General Reservation
    var generalReservationSection = 2
    @IBAction func setQuota(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        presentQuota.text = "\(currentValue)"
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return generalReservationSection
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}


// image use user image. can't use for doctor
public func doctorUpdateUI(_ nameLabel: UILabel, doctorGraduateSchool: UILabel, doctorCurrentHospital: UILabel, doctorLanguage: UILabel, doctorSpecialty: UILabel,doctorImageView: UIImageView, doctorIsBoardCertificated: UIImageView, doctor: Doctors?, starA: UIImageView, starB: UIImageView, starC: UIImageView, starD: UIImageView, starE: UIImageView)  {
    let englishFormat = "(?=.*[A-Za-z]).*$"
    let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
    if doctor!.doctorLastName != nil && doctor!.doctorFirstName != nil{
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        if langId.range(of: "en") != nil || englishPredicate.evaluate(with: doctor!.doctorFirstName!) || englishPredicate.evaluate(with: doctor!.doctorLastName!) {
            nameLabel.text = "Dr. "+doctor!.doctorFirstName!+" "+doctor!.doctorLastName!
        }else if langId.range(of: "zh") != nil{
            nameLabel.text = doctor!.doctorLastName!+doctor!.doctorFirstName!+" "+Storyboard.doctorTitle
        }else{
            nameLabel.text = Storyboard.doctorTitle+" "+doctor!.doctorFirstName!+" "+doctor!.doctorLastName!
        }
    }
    let school = NSLocalizedString("Edu: ", comment: "translate for school")
    let hospital = NSLocalizedString("Serve at ", comment: "translate where is doctor employed")
    let language = NSLocalizedString("Language: ", comment: "translate language")
    if doctor!.doctorGraduateSchool != nil && doctor!.doctorHospital != nil && doctor!.doctorLanguage != nil{
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        if langId.range(of: "en") != nil{
            doctorGraduateSchool.text = school+School.school[Int(doctor!.doctorGraduateSchool!)!][1]
        }else{
            doctorGraduateSchool.text = school+School.school[Int(doctor!.doctorGraduateSchool!)!][0]
        }
        doctorCurrentHospital.text = hospital+doctor!.doctorHospital!
        if doctor!.doctorLanguage != nil && doctor!.doctorLanguage != ""{
            doctorLanguage.text = language+printLanguage(doctor!.doctorLanguage!)
        }
    }
    //show doctorIsBoardCertificated or not
    doctorIsBoardCertificated.isHidden = true
    if doctor!.doctorCertificated!.boolValue {
        doctorIsBoardCertificated.isHidden = false
    }
    //no matter there is doctorImageSpecialistLicense or not, we alway show doctorProfession
    if doctor!.doctorProfession != nil{
        if doctor!.doctorProfessionTitle != nil {
            if Int(doctor!.doctorProfessionTitle!) != nil && Int(doctor!.doctorProfession!) != nil{
                doctorSpecialty.text = specialty.allSpecialty[Int(doctor!.doctorProfession!)!] +  " " + specialty.title[Int(doctor!.doctorProfessionTitle!)!]
            }
        }else{
            if doctor!.doctorProfession! == "Internist"{
                doctorSpecialty.text = Storyboard.internist
            }else{
                doctorSpecialty.text = Storyboard.pgy
            }
        }
    }
    //doctorImage
    if doctor!.doctorImageRemoteURL != nil && doctor!.doctorImageRemoteURL! != ""{
        if let profileImageURL = doctor!.doctorImageRemoteURL{
            //let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
//                dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self!.doctorImage?.image = UIImage(data: imageData)
//                    }
//                }
                doctorImageView.image = UIImage(data: imageData)
            }else{
                print("Wrong imageURL for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
                doctorImageView.image = UIImage(named:"doctor")
            }
        }else{
            print("No image for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
            doctorImageView.image = UIImage(named:"doctor")
        }
    }else{
        //setup Default Image
        if let imagedata = signInUser!.imageLocal {
            if let image = UIImage(data: imagedata){
                doctorImageView.image = image
            }
        }else{
            if signInUserPublic!.gender!.boolValue == true {
                doctorImageView.image = UIImage(named:"FemaleImage.png")
            }else{
                doctorImageView.image = UIImage(named:"MaleImage.png")
            }
        }
    }
    //star image
    let startotal = Double(doctor!.doctorOneStarNumber!) + Double(doctor!.doctorTwoStarNumber!) + Double(doctor!.doctorThreeStarNumber!) + Double(doctor!.doctorFourStarNumber!) + Double(doctor!.doctorFiveStarNumber!)
    var starEverage = Double(doctor!.doctorOneStarNumber!) * 1
    starEverage += Double(doctor!.doctorTwoStarNumber!) * 2
    starEverage += Double(doctor!.doctorThreeStarNumber!) * 3
    starEverage += Double(doctor!.doctorFourStarNumber!) * 4
    starEverage += Double(doctor!.doctorFiveStarNumber!) * 5
    starEverage = (startotal == 0) ? 0 : starEverage * 100 / startotal
    switch Int(starEverage) {
    case 0:
        starA.image = UIImage(named: "starEmpty")
        starB.image = UIImage(named: "starEmpty")
        starC.image = UIImage(named: "starEmpty")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 1...49:
        starA.image = UIImage(named: "starHalfFull")
        starB.image = UIImage(named: "starEmpty")
        starC.image = UIImage(named: "starEmpty")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 50...100:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starEmpty")
        starC.image = UIImage(named: "starEmpty")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 101...149:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starHalfFull")
        starC.image = UIImage(named: "starEmpty")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 150...200:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starEmpty")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 201...249:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starHalfFull")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 250...300:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starFull")
        starD.image = UIImage(named: "starEmpty")
        starE.image = UIImage(named: "starEmpty")
    case 301...349:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starFull")
        starD.image = UIImage(named: "starHalfFull")
        starE.image = UIImage(named: "starEmpty")
    case 350...400:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starFull")
        starD.image = UIImage(named: "starFull")
        starE.image = UIImage(named: "starEmpty")
    case 401...449:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starFull")
        starD.image = UIImage(named: "starFull")
        starE.image = UIImage(named: "starHalfFull")
    default:
        starA.image = UIImage(named: "starFull")
        starB.image = UIImage(named: "starFull")
        starC.image = UIImage(named: "starFull")
        starD.image = UIImage(named: "starFull")
        starE.image = UIImage(named: "starFull")
    }
}


//for general reservation's parameter
public struct generalReservation{
    static var quota : Int?
}
