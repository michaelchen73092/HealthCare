//
//  DoctorAbPatientTableViewCell.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/11/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class DoctorAbPatientTableViewCell: UITableViewCell {

    // MARK: - Variables
    var personspublic : PersonsPublic? {
        didSet{
            updateUI()
        }
    }
    
    var waitlistNumber : Int? {
        didSet{
            updateWaitlistNumber()
        }
    }
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var infoLabel: UIImageView!
    @IBOutlet weak var genderAndYears: UILabel!
    @IBOutlet weak var personsImage: UIImageView!
    @IBOutlet weak var waitnumber: UILabel!
    
    
    // MARK: - functions
    func updateUI(){
        name.text = nil
        infoLabel.isHidden = true
        genderAndYears.text = nil
        personsImage.image = nil
        
        if personspublic?.firstname == nil || personspublic?.lastname == nil || personspublic!.firstname! == "" || personspublic!.lastname! == "" {
            infoLabel.isHidden = true
            name.text = ""
            genderAndYears.text = ""
       //     patientImage.hidden = true
        }else{
            let gender : String?
            if personspublic!.gender!.boolValue {
                gender = Storyboard.female
            }else{
                gender = Storyboard.male
            }
            let now = Date()
            
            let calendar : Calendar = Calendar.current
            let ageComponents = (calendar as NSCalendar).components(.year,
                                                    from: personspublic!.birthday!,
                                                    to: now,
                                                    options: [])
            genderAndYears.text = gender! + "   " + "\(ageComponents.year) " + Storyboard.yearsOld
            infoLabel.isHidden = false
            let localeZH = NSLocale(localeIdentifier: "zh-Hant")
            if Locale.current == localeZH as Locale{
                name.text = personspublic!.lastname! + personspublic!.firstname!
            }else{
                name.text = personspublic!.firstname! + " " + personspublic!.lastname!
            }
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            if personspublic?.imageRemoteUrl != nil || personspublic!.imageRemoteUrl! != ""{
                if let profileImageURL = personspublic?.imageRemoteUrl{
                    if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                            DispatchQueue.main.async {
                                self!.personsImage?.image = UIImage(data: imageData)
                            }
                        }
                    }else{
                        print("Wrong imageURL for :\(personspublic!.firstname) \(personspublic!.lastname)")
                        defaultImage()
                    }
                }else{
                    print("No image for :\(personspublic!.firstname) \(personspublic!.lastname)")
                    defaultImage()
                }
            }else{
                print("No image for :\(personspublic!.firstname) \(personspublic!.lastname)")
                defaultImage()
            }
        }
    }
    
    func defaultImage(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                if self!.personspublic!.gender!.boolValue {
                    self!.personsImage.image = UIImage(named:"FemaleImage")
                }else{
                    self!.personsImage.image = UIImage(named:"MaleImage")
                }
            }
        }
    }
    
    func updateWaitlistNumber(){
        waitnumber.text = "0" + "\(waitlistNumber! + 1)"
    }
    
}


    
