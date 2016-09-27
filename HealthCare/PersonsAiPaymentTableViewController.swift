//
//  PersonsAiPaymentTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/28/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class PersonsAiPaymentTableViewController: UITableViewController {
    
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
    
    //payment info
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!
    //reservation info
    @IBOutlet weak var priceDescriptionLabel: UILabel!
    @IBOutlet weak var priceDetailLabel: UILabel!
    @IBOutlet weak var makeReservationButton: UIButton!
    @IBOutlet weak var noticeCheckBoxButton: UIButton!
    @IBOutlet weak var noticeTextButton: UIButton!
    
    fileprivate struct MVC{
        static let paymentString = NSLocalizedString("Payment", comment: "In PersonsAiPayment, title for payment column")
        static let settingString = NSLocalizedString("Setting", comment: "In PersonsAiPayment, setting button for credit card info")
        static let RatesAndFeesString = NSLocalizedString("Rates and Fees", comment: "In PersonsAiPayment, title for Rates and Fees column")
        static let RatesAndFeesDetailString = NSLocalizedString("1) Basic fee is $10/10 minutes. If consulting time exceed 10 minutes, charge rate is $1 per minute.\n2) You are free to cancel this reservation before it starts.\n3) If you miss the call from doctor who will call you in 3 minutes, you will be put in the last position in waitlist. And if you miss the call again, we will cancel your reservation.", comment: "In PersonsAiPayment, detail for Rates and Fees column")
        static let noticeTextString = NSLocalizedString("Please tap checkbox which means you are fully understanding this is a medical consulting. Doctor and Berbi platform will not take medical responsibility for this consulting.", comment: "In PersonsAiPayment, description for notice text below confirm button")
        static let waitForDoctorIdentifier = "show wait for doctor"
    }
    // MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.navigationItem.title = doctorNameLabel.text
        paymentMethodLabel.text = "1. "+MVC.paymentString
        paymentButton.setTitle(MVC.settingString, for: UIControlState())
        priceDescriptionLabel.text = "2. "+MVC.RatesAndFeesString
        priceDetailLabel.text = MVC.RatesAndFeesDetailString
        makeReservationButton.setTitle(Storyboard.ConfirmAlert, for: UIControlState())
        
        noticeCheckBoxButton.layer.borderWidth = 1.0
        noticeCheckBoxButton.layer.borderColor = UIColor.darkGray.cgColor
        noticeTextButton.setTitle(MVC.noticeTextString, for: UIControlState())
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func tapcheckMark() {
        checkMark()
    }
    
    @IBAction func tapCheckMarkInfo() {
        checkMark()
    }
    
    
    @IBAction func tapConfirm() {
        if noticeCheckBoxButton.currentImage == nil{
            //alert that no click Guildline
            let fail = NSLocalizedString("No CheckMark", comment: "In DoctorStartAfSpecialist's general reservation, title for not tap checkmark.")
            let details = NSLocalizedString("Please read guildlines and tap checkbox.", comment: "In DoctorStartAfSpecialist's general reservation, detail for not tap checkmark.")
            let okstring = NSLocalizedString("Cancel", comment: "In DoctorStartAfSpecialist's general reservation, cancel for not tap checkmark.")
            Alert.show(fail, message: details, ok: okstring, dismissBoth: false,vc: self)
        }else{
            //upload quota to AWS
            performSegue(withIdentifier: MVC.waitForDoctorIdentifier, sender: nil)
        }
    }
    
    
    fileprivate func checkMark(){
        if noticeCheckBoxButton.currentImage == nil{
            noticeCheckBoxButton.setImage(UIImage(named: "checkMark"), for: UIControlState())
        }else{
            noticeCheckBoxButton.setImage(nil, for: UIControlState())
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let aj = segue.destination as? PersonsAjWaitDoctorViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            aj.Doctor = Doctor
        }
        
    }

}
