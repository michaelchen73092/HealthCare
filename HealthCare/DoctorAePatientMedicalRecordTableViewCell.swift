//
//  DoctorAePatientMedicalRecordTableViewCell.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/15/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit

class DoctorAePatientMedicalRecordTableViewCell: UITableViewCell {

    // MARK: - Variables
    var medicalRecord : MedicalRecord? {
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var timeDurationLabel: UILabel!
    @IBOutlet weak var doctorSpecialtyLabel: UILabel!
    @IBOutlet weak var referralLabel: UILabel!
    @IBOutlet weak var symptomsAndDiseasesTitleLabel: UILabel!
    @IBOutlet weak var symptomsAndDiseasesDetailLabel: UILabel!
    @IBOutlet weak var medicinesTitleLabel: UILabel!
    @IBOutlet weak var medicinesDetailLabel: UILabel!
    @IBOutlet weak var treatmentTitleLabel: UILabel!
    @IBOutlet weak var treatmentDetailLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    // MARK: - updateUI
    fileprivate func updateUI(){
        //time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.long
        timeLabel.text = dateFormatter.string(from: medicalRecord!.time!)
        //image
        if medicalRecord?.doctorImageRemoteURL != nil || medicalRecord!.doctorImageRemoteURL! != ""{
            if let profileImageURL = medicalRecord?.doctorImageRemoteURL{
                //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                        DispatchQueue.main.async {
                            self!.doctorImage?.image = UIImage(data: imageData)
                        }
                    }
                }else{
                    print("Wrong imageURL for doctor :\(medicalRecord!.doctorFirstName!) \(medicalRecord!.doctorLastName)")
                    defaultImage()
                }
            }else{
                print("No image for doctor :\(medicalRecord!.doctorFirstName!) \(medicalRecord!.doctorLastName)")
                defaultImage()
            }
        }else{
            print("No image for doctor :\(medicalRecord!.doctorFirstName!) \(medicalRecord!.doctorLastName)")
            defaultImage()
        }
        
        //doctor name
        if medicalRecord!.doctorLastName != nil && medicalRecord!.doctorFirstName != nil{
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            let englishFormat = "(?=.*[A-Za-z]).*$"
            let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
            if langId.range(of: "en") != nil || englishPredicate.evaluate(with: medicalRecord!.doctorFirstName!) || englishPredicate.evaluate(with: medicalRecord!.doctorLastName!) {
                doctorNameLabel.text = "Dr. "+medicalRecord!.doctorFirstName!+" "+medicalRecord!.doctorLastName!
            }else if langId.range(of: "zh") != nil{
                doctorNameLabel.text = medicalRecord!.doctorLastName!+medicalRecord!.doctorFirstName!+" "+Storyboard.doctorTitle
            }else{
                doctorNameLabel.text = Storyboard.doctorTitle+" "+medicalRecord!.doctorFirstName!+" "+medicalRecord!.doctorLastName!
            }
        }
        //time duration
        let duration = NSLocalizedString("Consultant Time:", comment: "In DoctorAePatientMedicalRecord")
        timeDurationLabel.text = duration+" "+String(describing: medicalRecord!.duration!)+" "+Storyboard.fullNameMinutes
        //specialty
        let specialtyString = NSLocalizedString("Specialty:", comment: "In DoctorAePatientMedicalRecord")
        
        //no matter there is doctorImageSpecialistLicense or not, we alway show doctorProfession
        if medicalRecord!.specialtyTitle != nil {
            if Int(medicalRecord!.specialtyTitle!) != nil && Int(medicalRecord!.specialty!) != nil{
                doctorSpecialtyLabel.text = specialtyString+" "+specialty.allSpecialty[Int(medicalRecord!.specialty!)!] +  " " + specialty.title[Int(medicalRecord!.specialtyTitle!)!]
            }
        }else{
            if medicalRecord!.specialty! == "Internist"{
                doctorSpecialtyLabel.text = specialtyString+" "+Storyboard.internist
            }else{
                doctorSpecialtyLabel.text = specialtyString+" "+Storyboard.pgy
            }
        }
        //referral
        let referral = NSLocalizedString("Referral:", comment: "In DoctorAePatientMedicalRecord")
        let yes = NSLocalizedString("Yes", comment: "In DoctorAePatientMedicalRecord")
        let no = NSLocalizedString("No", comment: "In DoctorAePatientMedicalRecord")
        referralLabel.text = referral+" "+(medicalRecord!.referral!.boolValue ? yes : no)
        //title label
        let symptomsAndDiseases = NSLocalizedString("Symptoms or Diseases:", comment: "In DoctorAePatientMedicalRecord")
        symptomsAndDiseasesTitleLabel.text = symptomsAndDiseases
        let medicines = NSLocalizedString("Medicines:", comment: "In DoctorAePatientMedicalRecord")
        medicinesTitleLabel.text = medicines
        let treatment = NSLocalizedString("Suggested Treatments :", comment: "In DoctorAePatientMedicalRecord")
        treatmentTitleLabel.text = treatment
        
        //detail label
        if medicalRecord!.diseases != nil {
            symptomsAndDiseasesDetailLabel.text = medicalRecord!.diseases!
        }else{
            symptomsAndDiseasesDetailLabel.text = ""
        }
        if medicalRecord!.medicines != nil{
            medicinesDetailLabel.text = medicalRecord!.medicines!
        }else{
            medicinesDetailLabel.text = ""
        }
        if medicalRecord!.treatments != nil{
            treatmentDetailLabel.text = medicalRecord!.treatments!
        }else{
            treatmentDetailLabel.text = ""
        }
    }
    
    func defaultImage(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                self!.doctorImage!.image = UIImage(named:"doctor")
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
