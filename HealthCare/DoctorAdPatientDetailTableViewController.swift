//
//  DoctorAdPatientDetailTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/14/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit
import CoreLocation
import CoreData
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


class DoctorAdPatientDetailTableViewController: UITableViewController {

    var patient : PersonsPublic?
    weak var MedicalRecordEntity : NSEntityDescription?
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var medicalRecords = [MedicalRecord]()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var ethnicityLabel: UILabel!
    @IBOutlet weak var imageContainer: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    fileprivate struct MVC{
        static let cellIdentifier = "Medical Records"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        personDetail(patient, nameLabel: nameLabel, birthdayLabel: birthdayLabel, genderLabel: genderLabel, heightLabel: heightLabel, weightLabel:weightLabel, bmiLabel: bmiLabel,ethnicityLabel:ethnicityLabel, locationLabel:locationLabel)
        //need also copy below degaultImage() api
        imageUI()
        MedicalRecordEntity = NSEntityDescription.entity(forEntityName: "MedicalRecord", in: moc)
        if patient != nil {
            // need to check AWS api that how do we desgin to fetch medical record
            medicalRecords = fetchMedicalRecords(patient!.email!)!
        }
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    //image API
    func imageUI(){
        if patient?.imageRemoteUrl != nil || patient!.imageRemoteUrl! != ""{
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            if let profileImageURL = patient?.imageRemoteUrl{
                if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                        DispatchQueue.main.async {
                            self!.imageContainer?.image = UIImage(data: imageData)
                        }
                    }
                }else{
                    print("Wrong imageURL for :\(patient!.firstname) \(patient!.lastname)")
                    defaultImage()
                }
            }else{
                print("No image for :\(patient!.firstname) \(patient!.lastname)")
                defaultImage()
            }
        }else{
            print("No image for :\(patient!.firstname) \(patient!.lastname)")
            defaultImage()
        }
    }
    func defaultImage(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                if self!.patient!.gender!.boolValue {
                    self!.imageContainer.image = UIImage(named:"FemaleImage")
                }else{
                    self!.imageContainer.image = UIImage(named:"MaleImage")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //temp for update data
    fileprivate func fetchMedicalRecords(_ patientEmail: String) -> [MedicalRecord]? {
        var testAll = [MedicalRecord]()
        let dateFormatter = DateFormatter()
        var dateAsString = "24-12-2015 23:59"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        if patientEmail == "m@g.com"{
            let testOne = MedicalRecord(entity: MedicalRecordEntity!, insertInto: moc)
            testOne.doctorEmail = "docotor1@gmail.com"
            testOne.doctorFirstName = "欣湄"
            testOne.doctorLastName = "陳"
            testOne.specialtyTitle = "2"
            testOne.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p160x160/13692605_10153942476143285_2377423907395322295_n.jpg?oh=5e2dc23d72ffd91ee88aa2f4fd3eb1db&oe=5857F1EC"
            testOne.patientEmail = "m@g.com"
            testOne.patientFirstName = "Wei-Chih"
            testOne.patientLastName = "Chen"
            testOne.patientImageRemoteURL = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c427.3.533.533/s160x160/1231546_10152098475632345_1368421124_n.jpg?oh=54089e8c829f9f933f9eb155b7a736e1&oe=581C6EF9"
            testOne.specialty = "10"
            testOne.diseases = "些微發燒，肌肉痠痛，喉嚨痛，咳嗽，流鼻水，鼻塞，背部有過敏現象。疑似北美流行性感冒"
            testOne.medicines = "Serratiopeptidase, Acetaminophen"
            testOne.treatments = "多休息，吃點蔬菜水果，多喝熱水，觀察一兩天，沒有改善再來看醫師"
            testOne.duration = 18
            dateAsString = "24-07-2016 21:59"
            testOne.time = dateFormatter.date(from: dateAsString)
            testAll.insert(testOne, at: testAll.count)
            let testTwo = MedicalRecord(entity: MedicalRecordEntity!, insertInto: moc)
            testTwo.doctorEmail = "docotor2@gmail.com"
            testTwo.doctorFirstName = "建志"
            testTwo.doctorLastName = "潘"
            testTwo.specialtyTitle = "2"
            testTwo.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p160x160/13495243_10153716756341964_828187480660825484_n.jpg?oh=5cc1d2f84d4531ae76421566141cc065&oe=58481D46"
            testTwo.patientEmail = "m@g.com"
            testTwo.patientFirstName = "Wei-Chih"
            testTwo.patientLastName = "Chen"
            testTwo.patientImageRemoteURL = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c427.3.533.533/s160x160/1231546_10152098475632345_1368421124_n.jpg?oh=54089e8c829f9f933f9eb155b7a736e1&oe=581C6EF9"
            testTwo.specialty = "28"
            testTwo.diseases = "睡不好，壓力大，疑似焦慮症"
            testTwo.medicines = "Fluoxetine"
            testTwo.treatments = "去藥局買藥，建議去看當地醫師，買抗憂鬱的藥後，一個禮拜來回診一次"
            testTwo.duration = 26
            dateAsString = "12-05-2016 09:29"
            testTwo.time = dateFormatter.date(from: dateAsString)
            testAll.insert(testTwo, at: testAll.count)
            let testThree = MedicalRecord(entity: MedicalRecordEntity!, insertInto: moc)
            testThree.doctorEmail = "docotor3@gmail.com"
            testThree.doctorFirstName = "尚平"
            testThree.doctorLastName = "洪"
            testThree.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/c0.0.160.160/p160x160/13707796_1117482481624265_4589455678116602371_n.jpg?oh=8ea311b496a217b3122637be7e42946f&oe=58538CB4"
            testThree.patientEmail = "m@g.com"
            testThree.patientFirstName = "Wei-Chih"
            testThree.patientLastName = "Chen"
            testThree.patientImageRemoteURL = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c427.3.533.533/s160x160/1231546_10152098475632345_1368421124_n.jpg?oh=54089e8c829f9f933f9eb155b7a736e1&oe=581C6EF9"
            testThree.specialty = "10"
            testThree.diseases = "運動腳底板扭到"
            testThree.medicines = "冰敷"
            testThree.treatments = "冰敷"
            testThree.duration = 10
            testThree.specialtyTitle = "2"
            dateAsString = "09-04-2016 11:23"
            testThree.time = dateFormatter.date(from: dateAsString)
            testAll.insert(testThree, at: testAll.count)
        }
        if patientEmail == "a@g.com"{
            let testOne = MedicalRecord(entity: MedicalRecordEntity!, insertInto: moc)
            testOne.doctorEmail = "docotor1@gmail.com"
            testOne.doctorFirstName = "欣湄"
            testOne.doctorLastName = "陳"
            testOne.specialtyTitle = "2"
            testOne.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p160x160/13692605_10153942476143285_2377423907395322295_n.jpg?oh=5e2dc23d72ffd91ee88aa2f4fd3eb1db&oe=5857F1EC"
            testOne.patientEmail = "a@g.com"
            testOne.patientFirstName = "Chien-Lin"
            testOne.patientLastName = "Chen"
            testOne.patientImageRemoteURL = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c40.0.160.160/p160x160/10154886_694303240612155_803087744422793784_n.jpg?oh=0fb1336f496fb96cb6bacbc1bfcad672&oe=581AB0C6"
            testOne.specialty = "10"
            testOne.diseases = "頭痛，聽不清楚"
            testOne.medicines = "Tmoney"
            testOne.treatments = "耳屎太多，去買耳藥水軟化耳屎清出"
            testOne.duration = 18
            dateAsString = "24-07-2016 20:50"
            testOne.time = dateFormatter.date(from: dateAsString)
            testAll.insert(testOne, at: testAll.count)
        }
        
        return testAll
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return medicalRecords.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MVC.cellIdentifier, for: indexPath) as! DoctorAePatientMedicalRecordTableViewCell
        cell.medicalRecord = medicalRecords[(indexPath as NSIndexPath).row]
        return cell
    }
}

public func personDetail(_ persons: PersonsPublic?, nameLabel: UILabel, birthdayLabel: UILabel, genderLabel: UILabel, heightLabel: UILabel, weightLabel:UILabel, bmiLabel: UILabel, ethnicityLabel:UILabel, locationLabel: UILabel){
    //print Ethnicity API
    func printEthnicity(_ signInUserethnicity: String, array: [String]) -> String{
        //need to check if tempDoctor?.doctorLanguage != nil && tempDoctor?.doctorLanguage != ""
        var ethnicityString = ""
        var tempsignInUserethnicity = signInUserethnicity
        while(tempsignInUserethnicity != ""){
            var temp = ""
            if let decimalRange = tempsignInUserethnicity.range(of: " ,"){
                temp = tempsignInUserethnicity[tempsignInUserethnicity.startIndex..<decimalRange.lowerBound]
                // it's possible there are two blank
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                tempsignInUserethnicity.removeSubrange(tempsignInUserethnicity.startIndex..<decimalRange.upperBound)
            }
            else if tempsignInUserethnicity != ""{
                temp = tempsignInUserethnicity
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                tempsignInUserethnicity = ""
            }
            // write to languageStirng
            if ethnicityString == ""{
                ethnicityString = array[Int(temp)!]
            }else{
                ethnicityString = ethnicityString + ", " + array[Int(temp)!]
            }
        }
        return ethnicityString
    }
    
    if persons != nil && persons?.firstname != "" && persons?.lastname != ""{
        //name label
        var genderTitle = ""
        if persons!.gender!.boolValue {
            genderTitle = "女士"
        }else{
            genderTitle = "先生"
        }
        let birthday = NSLocalizedString("Birthday:", comment: "In DoctorAdPatientDetail, translate for Birthday")
        let gender = NSLocalizedString("Gender:", comment: "In DoctorAdPatientDetail, translate for Gender")
        let height = NSLocalizedString("Height:", comment: "In DoctorAdPatientDetail, translate for Height")
        let weight = NSLocalizedString("Weight:", comment: "In DoctorAdPatientDetail, translate for Height")
        let ethnicity = NSLocalizedString("Ethnicity:", comment: "In DoctorAdPatientDetail, translate for Ethnicity")
        let location = NSLocalizedString("Location:", comment: "In DoctorAdPatientDetail, translate for Location")
        if persons?.firstname != nil && persons?.lastname != nil{
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            let englishFormat = "(?=.*[A-Za-z]).*$"
            let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
            if langId.range(of: "en") != nil || englishPredicate.evaluate(with: persons!.firstname!) || englishPredicate.evaluate(with: persons!.lastname!) {
                nameLabel.text = persons!.firstname!+" "+persons!.lastname!
            }else if langId.range(of: "zh") != nil{
                nameLabel.text = persons!.lastname!+persons!.firstname!+" "+genderTitle
            }else{
                nameLabel.text = persons!.firstname!+" "+persons!.lastname!
            }
        }
        //birthday label
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthdayLabel.text = birthday+" "+dateFormatter.string(from: (persons!.birthday)!)
        //gender label
        genderLabel.text = gender+" "+(persons!.gender!.boolValue ? Storyboard.female : Storyboard.male)
        //height label
        if persons!.height != nil && persons!.height! != 0 {
            let heightcm = Double(persons!.height!.intValue)
            var inches = heightcm * 0.3937
            let feetes = inches / 12
            inches -= feetes * 12
            let printFeet = "\(Int(feetes))'\(Int(inches))\""
            let printMeter = "(\(String(format: "%.1f", heightcm))cm)"
            heightLabel.text = height+" "+printFeet + printMeter
        }else{
            heightLabel.text = height+" "+Storyboard.notSet
        }
        //weight label
        if persons!.weight != nil && persons!.weight! != 0 {
            let weightKg = Double(persons!.weight!.intValue)
            let pound = weightKg * 2.2046
            let printPound = "\(String(format: "%.1f", pound))lbs"
            let printKg = "(\(String(format: "%.1f", weightKg))kg)"
            weightLabel.text = weight+" "+printPound + printKg
        }else{
            weightLabel.text = weight+" "+Storyboard.notSet
        }
        //bmi label
        if (persons?.height != nil) && (persons?.weight != nil) && (persons!.height! != 0) && (persons!.weight! != 0){
            let height = Float(persons!.height!) / 100
            let bmi = Float(persons!.weight!) / (height * height)
            if (height != 0) && (Float(persons!.weight!) != 0){
                let Underweight =  NSLocalizedString("Underweight", comment: "In DoctorAdPatientDetail for bmi Meaning")
                let Normal =  NSLocalizedString("Normal", comment: "In DoctorAdPatientDetail for bmi Meaning")
                let Overweight =  NSLocalizedString("Overweight", comment: "In DoctorAdPatientDetail for bmi Meaning")
                let Obese =  NSLocalizedString("Obese", comment: "In DoctorAdPatientDetail for bmi Meaning")
                var bmiMeaning : String?
                if bmi < 18.5 { bmiMeaning = Underweight}
                else if bmi >= 18.5 && bmi < 24.9 {bmiMeaning = Normal}
                else if bmi >= 24.9 && bmi < 29.9 {bmiMeaning = Overweight}
                else {bmiMeaning = Obese}

                bmiLabel.text = "BMI: \(String(format: "%.1f", bmi))(\(bmiMeaning!))"
                
            }
        }
        
        //ethnicity update
        if persons?.ethnicity != nil {
            if persons!.ethnicity! != "" {
                ethnicityLabel.text = ethnicity+" "+printEthnicity(persons!.ethnicity!, array: Ethnicity.ethnicity)
            }else{
                ethnicityLabel.text = ethnicity+" "+Storyboard.notSet
            }
        }
        if !(persons!.locationLatitude! == 0 && persons!.locationlongitude! == 0) {
            let userLocation = CLLocation(latitude: Double(persons!.locationLatitude!), longitude: Double(persons!.locationlongitude!))
            CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if error != nil {
                    print("Inside printLocation: Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks?.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    let city = (pm.locality != nil) ? pm.locality! : ""
                    let state = (pm.administrativeArea != nil) ? pm.administrativeArea! : ""
                    let country = (pm.country != nil) ? pm.country! : ""
                    locationLabel.text = location+" \(city), \(state) in \(country)"
                }else{
                    print("Problem with the data received from geocoder")
                }
            }
        }else{
            locationLabel.text = location+" "+Storyboard.notSet
        }
    }//end if persons != nil && persons?.firstname != "" && persons?.lastname != ""
}
