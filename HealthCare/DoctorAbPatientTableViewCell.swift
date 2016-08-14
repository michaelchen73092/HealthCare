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
        infoLabel.hidden = true
        genderAndYears.text = nil
        personsImage.image = nil
        
        if personspublic?.firstname == nil || personspublic?.lastname == nil || personspublic!.firstname! == "" || personspublic!.lastname! == "" {
            infoLabel.hidden = true
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
            let now = NSDate()
            
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            let ageComponents = calendar.components(.Year,
                                                    fromDate: personspublic!.birthday!,
                                                    toDate: now,
                                                    options: [])
            genderAndYears.text = gender! + "   " + "\(ageComponents.year) " + Storyboard.yearsOld
            infoLabel.hidden = false
            if NSLocale.currentLocale() == "zh-Hant"{
                name.text = personspublic!.lastname! + personspublic!.firstname!
            }else{
                name.text = personspublic!.firstname! + " " + personspublic!.lastname!
            }
            let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
            if personspublic?.imageRemoteUrl != nil || personspublic!.imageRemoteUrl! != ""{
                if let profileImageURL = personspublic?.imageRemoteUrl{
                    if let imageData = NSData(contentsOfURL: NSURL(string:profileImageURL)!) {
                        dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                            dispatch_async(dispatch_get_main_queue()) {
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
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) { [weak self] in
            dispatch_async(dispatch_get_main_queue()) {
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


    