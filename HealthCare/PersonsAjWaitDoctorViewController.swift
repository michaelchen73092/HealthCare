//
//  PersonsAjWaitDoctorViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/29/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class PersonsAjWaitDoctorViewController: UIViewController {

    // MARK: - Variables
    var Doctor : Doctors?
    //Doctor settings
    //description follow top to down order
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorImageView: UIImageView!
    //right board certificated image
    @IBOutlet weak var doctorSpecialty: UILabel!
    @IBOutlet weak var doctorGraduateSchool: UILabel!
    @IBOutlet weak var doctorCurrentHospital: UILabel!
    @IBOutlet weak var doctorLanguage: UILabel!
    
    @IBOutlet weak var doctorIsBoardCertificated: UIImageView!
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    ///////////////////////////
    @IBOutlet weak var onlineLabel: UILabel!
    
    @IBOutlet weak var patientWaiting: UILabel!
    @IBOutlet weak var doctorWaitTimeLabel: UILabel!
    
    @IBOutlet weak var missDoctorNoteLabel: UILabel!
    @IBOutlet weak var cancelReservationButton: UIButton!
    
    
    fileprivate struct MVC{
        static let patientWaitingString =  NSLocalizedString("Patient Waiting", comment: "In PersonsAjWait, show how many paitents are waiting")
        static let doctorWaitingString =  NSLocalizedString("Doctor Waiting Time", comment: "In PersonsAjWait, show how many minutes did doctor wait")
        static let doctorWaitingNoticeString =  NSLocalizedString("If your doctor waits for more than three minutes, we will put you in the last of waiting list.", comment: "In PersonsAjWait, description for you missing a doctor call")
        static let cancelReservationString =  NSLocalizedString("Cancel Reservation", comment: "In PersonsAjWait, cancel reservation button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.navigationItem.title = doctorNameLabel.text
        patientWaiting.text = "2 "+MVC.patientWaitingString
        doctorWaitTimeLabel.text = MVC.doctorWaitingString+" "+"00 "+Storyboard.minutes+" 00 "+Storyboard.seconds
        missDoctorNoteLabel.text = MVC.doctorWaitingNoticeString
        cancelReservationButton.setTitle(MVC.cancelReservationString, for: UIControlState())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func updateUI(){
        onLineDoctorUpdateUI(doctorNameLabel, doctorGraduateSchool: doctorGraduateSchool,doctorCurrentHospital: doctorCurrentHospital,doctorLanguage: doctorLanguage, doctorSpecialty: doctorSpecialty, doctorImageView:doctorImageView, doctorIsBoardCertificated: doctorIsBoardCertificated, doctor:Doctor, starA: starOne, starB: starTwo, starC: starThree, starD: starFour, starE: starFive)
        onlineLabel.textColor = UIColor(netHex: 0x42D451)
        onlineLabel.text = Storyboard.onLine
        
    }
    
    func onLineDoctorUpdateUI(_ nameLabel: UILabel, doctorGraduateSchool: UILabel, doctorCurrentHospital: UILabel, doctorLanguage: UILabel, doctorSpecialty: UILabel,doctorImageView: UIImageView, doctorIsBoardCertificated: UIImageView, doctor: Doctors?, starA: UIImageView, starB: UIImageView, starC: UIImageView, starD: UIImageView, starE: UIImageView)  {
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
                //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                        DispatchQueue.main.async {
                            self!.doctorImageView?.image = UIImage(data: imageData)
                        }
                    }
                }else{
                    print("Wrong imageURL for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
                    defaultImage()
                }
            }else{
                print("No image for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
                defaultImage()
            }
        }else{
            defaultImage()
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
    
    func defaultImage(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                self!.doctorImageView?.image = UIImage(named:"doctor")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
