//
//  PersonsCbAccountTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/13/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
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


@available(iOS 10.0, *)
class PersonsCbAccountTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    // MARK: - Setting for each attribute
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var ethnicityLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    var isDoctorSet = false
    
    fileprivate struct MVC {
        static let manuallySearchCityIdentifier = "SearchCity"
        static let notSet =  NSLocalizedString("Not Set", comment: "In PersonsCbAccount for Not set constant")
    }
    var tempGender : NSNumber?
    var tempLatitude : NSNumber?
    var tempLongitude : NSNumber?
    var tempEthnicity : String?
    var tempHeight : NSNumber?
    var tempWeight : NSNumber?
    // for updateUserInfo to local CoreData
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Edit for Name
    //each time change section number, we need to reloadData
    //We set tap gesture on every row to controller tap situation
    @IBOutlet weak var firstNameField: UITextField!{ didSet{ firstNameField.delegate = self}}
    @IBOutlet weak var lastNameField: UITextField!{ didSet{ lastNameField.delegate = self}}
    @IBOutlet weak var invalidName: UILabel!
    @IBOutlet weak var namePancelImage: UIImageView!
    
    var nameSection = 1
    @IBAction func tapName(_ sender: UITapGestureRecognizer) {
        if !signInUser!.isdoctor!.boolValue{
            invalidName.isHidden = true
            if nameSection == 1{
                nameSection = 2
            }else{
                nameSection = 1
            }
            //close other
            genderSection = 1
            locationSection = 1
            birthdaySection = 1
            bmiSection = 1
            nameLabel?.text = printNameOrder(firstNameField.text!, lastName: lastNameField.text!)
            tableView.reloadData()
        }
    }

    // MARK: - Edit for Gender
    var genderSection = 1
    @IBOutlet weak var genderSegmentController: UISegmentedControl!
    @IBOutlet weak var genderPencilImage: UIImageView!
    
    @IBAction func genderSegmentAction() {
        if genderSegmentController.selectedSegmentIndex == 0{
            tempGender = NSNumber(value: false as Bool)  // false is male
        }else{
            tempGender = NSNumber(value: true as Bool) // true is female
        }
        if tempGender != nil {
            genderLabel?.text = (tempGender!.boolValue) ? Storyboard.female : Storyboard.male
        }
    }
    
    @IBAction func tapGender(_ sender: UITapGestureRecognizer) {
        if !signInUser!.isdoctor!.boolValue{
            if genderSection == 1{
                genderSection = 2
            }else{
                genderSection = 1
            }
            
            //close other
            nameSection = 1
            locationSection = 1
            birthdaySection = 1
            bmiSection = 1
            tableView.reloadData()
        }
    }
    
    // MARK: - Edit for location
    var locationSection = 1
    
    @IBAction func tapLocation(_ sender: UITapGestureRecognizer) {
        if locationSection == 1{
            locationSection = 3
        }else{
            locationSection = 1
        }
        
        //close other
        nameSection = 1
        genderSection = 1
        birthdaySection = 1
        bmiSection = 1
        tableView.reloadData()
    }
    let locationManager = CLLocationManager()
    
    @IBAction func manuallySearchCity() {
        //It Segue to PersonsCc in Storyboard, no need for set performSegue Here
        //performSegueWithIdentifier(MVC.manuallySearchCityIdentifier, sender: nil)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        //definesPresentationContext = true
    }
    
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("in didUpdateLocations")
        //print location
        if manager.location != nil{
            let userLocation = CLLocation(latitude: manager.location!.coordinate.latitude, longitude: manager.location!.coordinate.longitude)
            print("manager.location!.coordinate.latitude:\(manager.location!.coordinate.latitude)")
            print("manager.location!.coordinate.longitude:\(manager.location!.coordinate.longitude)")
            GeoLocation(userLocation)
            locationLabel.font = UIFont.systemFont(ofSize: 17)
        }
    }

    func printLocation(){
        let tempLa = signInUserPublic!.locationLatitude
        let tempLo = signInUserPublic!.locationlongitude
        signInUserPublic?.locationLatitude = tempLatitude
        signInUserPublic?.locationlongitude = tempLongitude
        tempLatitude = tempLa
        tempLongitude = tempLo
        
        if !(tempLatitude == 0 && tempLongitude == 0) {
            locationLabel.font = UIFont.systemFont(ofSize: 17)
            let userLocation = CLLocation(latitude: Double(tempLatitude!), longitude: Double(tempLongitude!))
            CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if error != nil {
                    print("Inside printLocation: Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks?.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    self.displayLocationInfo(pm)
                    print("@@@@@@@@@@SUCESS@@@@@@@@@")
                }else{
                    print("Problem with the data received from geocoder")
                }
            }
        }
    }
    
    func GeoLocation(_ location: CLLocation?){
        CLGeocoder().reverseGeocodeLocation(location!) { (placemarks, error) in
            if error != nil {
                let noInternet = NSLocalizedString("No Internet Connection", comment: "Title for error message that no internet in PersonCb's LocationLabel")
                let noInternetMessage =  NSLocalizedString("Please Use Wi-Fi to Access Data", comment: "Message for error message that no internet in PersonCb's LocationLabel")
                let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
                Alert.show(noInternet, message: noInternetMessage, ok: okstring, dismissBoth: false,vc: self)
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks?.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                //store latitude and longitude for user info
                self.tempLatitude = location!.coordinate.latitude as NSNumber?
                self.tempLongitude = location!.coordinate.longitude as NSNumber?
                self.displayLocationInfo(pm)
                //wait finish update then tableView reload
                self.locationSection = 1
                self.tableView.reloadData()
                self.locationManager.stopUpdatingLocation()
            }else{
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark){
        let city = (placemark.locality != nil) ? placemark.locality! : ""
        let state = (placemark.administrativeArea != nil) ? placemark.administrativeArea! : ""
        let country = (placemark.country != nil) ? placemark.country! : ""
        if city != ""{
            locationLabel.text = "\(city)"
        }else{
            locationLabel.text = ""
        }
        if state != ""{
            if locationLabel.text == "" {
                locationLabel.text = "\(state)"
            }else{
                locationLabel.text = locationLabel.text! + ", \(state)"
            }
        }
        print("\(country)")
        if country != ""{
            if locationLabel.text == "" {
                locationLabel.text = "\(country)"
            }else{
                locationLabel.text = locationLabel.text! + ", \(country)"
            }
        }
        print("locationLabel.text:\(locationLabel.text!)")
        print("displayLocationInfo")
        
    }
    
    
    @IBAction func tapEditLocation(_ sender: UITapGestureRecognizer) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1000.0 // Will notify the LocationManager every 1000 meters, not aler all the time
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Birthday
    var birthdaySection = 1
    @IBOutlet weak var datePicker: UIDatePicker!
    let dateFormatter = DateFormatter()
    @IBOutlet weak var invalidBirthday: UILabel!
    @IBOutlet weak var virthdayPencilImage: UIImageView!

    
    @IBAction func tapBirthday(_ sender: UITapGestureRecognizer) {
        if !signInUser!.isdoctor!.boolValue{
            if birthdaySection == 1{
                birthdaySection = 2
            }else{
                birthdaySection = 1
            }
            
            //close other
            nameSection = 1
            genderSection = 1
            locationSection = 1
            bmiSection = 1
            tableView.reloadData()
            // moveup birthday row if it spread out
            if birthdaySection == 2{
                let indexPath = IndexPath(row: 1, section: 3)
                tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }

    func datePickerChanged(_ datePicker:UIDatePicker) {
        invalidBirthday?.isHidden = true
        let strDate = dateFormatter.string(from: datePicker.date)
        if strDate == dateFormatter.string(from: Date()){
            invalidBirthday?.isHidden = false
        }else{
            birthdayLabel?.text = strDate
        }
    }
    
    // MARK: - Height / Weight
    var bmiSection = 1
    @IBOutlet weak var heightValue: UILabel!
    @IBOutlet weak var weightValue: UILabel!
    @IBOutlet weak var heightSliderValue: UISlider!
    @IBOutlet weak var weightSliderValue: UISlider!
    @IBOutlet weak var bmiValue: UILabel!
    @IBOutlet weak var bmiMeaning: UILabel!
    
    
    @IBAction func tapBMI(_ sender: UITapGestureRecognizer) {
        if bmiSection == 1{
            bmiSection = 3
        }else{
            bmiSection = 1
        }
        //close other
        nameSection = 1
        genderSection = 1
        locationSection = 1
        birthdaySection = 1
        tableView.reloadData()
        if bmiSection == 3{
            let numberOfSections = tableView.numberOfSections
            let numberOfRows = tableView.numberOfRows(inSection: numberOfSections-1)
            let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    fileprivate func bmiCalculate(){
        if (tempHeight != nil) && (tempWeight != nil){
            let height = Float(tempHeight!) / 100
            let bmi = Float(tempWeight!) / (height * height)
            if (height != 0) && (Float(tempWeight!) != 0){
                bmiValue.text = String(format: "%.1f", bmi)
                
                let Underweight =  NSLocalizedString("Underweight", comment: "In PersonsCbAccount for bmi Meaning")
                let Normal =  NSLocalizedString("Normal", comment: "In PersonsCbAccount for bmi Meaning")
                let Overweight =  NSLocalizedString("Overweight", comment: "In PersonsCbAccount for bmi Meaning")
                let Obese =  NSLocalizedString("Obese", comment: "In PersonsCbAccount for bmi Meaning")
                
                if bmi < 18.5 { bmiMeaning.text = Underweight}
                else if bmi >= 18.5 && bmi < 24.9 {bmiMeaning.text = Normal}
                else if bmi >= 24.9 && bmi < 29.9 {bmiMeaning.text = Overweight}
                else {bmiMeaning.text = Obese}
                
                bmiLabel.font = UIFont.systemFont(ofSize: 17)
                bmiLabel.text = "BMI:\(String(format: "%.1f", bmi))(\(bmiMeaning.text!))"
                
            }
        }
    }
    
    func heightCalculate(){
        var inches = heightSliderValue.value * 0.3937
        let feetes = inches / 12
        inches -= feetes * 12
        let printFeet = "\(Int(feetes))'\(Int(inches))\""
        let printMeter = "(\(String(format: "%.1f", heightSliderValue.value))cm)"
        heightValue.text = printFeet + printMeter
    }
    
    func weightCalculate(){
        let pound = weightSliderValue.value * 2.2046
        let printPound = "\(String(format: "%.1f", pound))lbs"
        let printKg = "(\(String(format: "%.1f", weightSliderValue.value))kg)"
        weightValue.text = printPound + printKg
    }

    fileprivate func bmiInit(){
        heightSliderValue.minimumValue = 30.0
        heightSliderValue.maximumValue = 274.0
        if (signInUserPublic!.height!.intValue != 0) {
            heightSliderValue.value = Float(signInUserPublic!.height!)
        }else{
            heightSliderValue.value = (heightSliderValue.maximumValue + heightSliderValue.minimumValue) / 2
        }
        heightCalculate()
        weightSliderValue.minimumValue = 0.0
        weightSliderValue.maximumValue = 180.0
        if (signInUserPublic!.weight!.intValue != 0){
            weightSliderValue.value = Float(signInUserPublic!.weight!)
        }else{
            print("before weightSliderValue.value :\(weightSliderValue.value)")
            weightSliderValue.value = weightSliderValue.maximumValue / 2
            print("after weightSliderValue.value :\(weightSliderValue.value)")
        }
        weightCalculate()
        tempHeight = signInUserPublic!.height
        tempWeight = signInUserPublic!.weight
        bmiCalculate()
    }
    
    @IBAction func heightSlider(_ sender: UISlider) {
        heightCalculate()
        tempHeight = heightSliderValue.value as NSNumber?
        bmiCalculate()
    }
    
    @IBAction func weightSlider(_ sender: UISlider) {
        weightCalculate()
        tempWeight = weightSliderValue.value as NSNumber?
        bmiCalculate()
    }

    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation bar, set back button title in PersonsCa's prepareForSeque
        let accountTitle = NSLocalizedString("Basic Info", comment: "In PersonsCbAccount, the title for Account setting")
        self.navigationItem.title = accountTitle
        let saveTitle = NSLocalizedString("Save", comment: "In PersonsCbAccount, the title for save update")
        let rightSaveNavigationButton = UIBarButtonItem(title: saveTitle , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveButtonClicked))
        self.navigationItem.rightBarButtonItem = rightSaveNavigationButton
        
        //setup UI
        invalidName.isHidden = true
        isDoctorSet = signInUser!.isdoctor!.boolValue
        updateUI()
        //location initialization
        tempLatitude = signInUserPublic!.locationLatitude
        tempLongitude = signInUserPublic!.locationlongitude
        printLocation()
        //BMI initialization
        bmiInit()
        
        //add datePicker event
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
        //add ethnicity back notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.ethnicityBackUpdate), name: NSNotification.Name(rawValue: "ethnicityBack"), object: nil)
        //add location back notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.searchCityBackUpdate), name: NSNotification.Name(rawValue: "searchCityBack"), object: nil)
        
        print("In viewDidLoad")
        
    }

    func ethnicityBackUpdate(){
        //if Ethnicity is changed it will show in here
        let temp = signInUserPublic!.ethnicity
        signInUserPublic!.ethnicity = tempEthnicity
        tempEthnicity = temp
        
        if tempEthnicity! != "" {
            ethnicityLabel?.text = printEthnicity(tempEthnicity!, array: Ethnicity.ethnicity)
            ethnicityLabel?.font = UIFont.systemFont(ofSize: 17)
        }else{
            let navbarFont = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
            ethnicityLabel?.font = navbarFont
            ethnicityLabel?.text = MVC.notSet
        }
        print("get EthnicityBack notice")
    }
    
    func searchCityBackUpdate(){
        printLocation()
        print("get SearchCityBack notice")
    }
    
    func saveButtonClicked(){
        //if validateName is show whether input have some strange characters
        if validateName(firstNameField.text!) || validateName(lastNameField.text!) {
            nameSection = 2
            tableView.reloadData()
            invalidName.isHidden = false
            wiggleInvalidtext(invalidName, Duration: 0.03, RepeatCount: 10, Offset: 2)
            let indexPath = IndexPath(row: 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            return
        }
        
        
        saveToCoreData()
        // After saving go back to previous page
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ethnicityBack"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "searchCityBack"), object: nil)
        //Add notification for update name
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateName"), object: self, userInfo: nil )
        navigationController?.popViewController(animated: true)
    }
    func saveToCoreData(){
        //fetch a local user in HD
        do {
            //let fetchRequestPersonPublic = NSFetchRequest(entityName: "PersonsPublic")
            let fetchRequestPersonPublic: NSFetchRequest<PersonsPublic> = PersonsPublic.fetchRequest() as! NSFetchRequest<PersonsPublic>
            //let fetchRequestDoctor = NSFetchRequest(entityName: "Doctors")
            let fetchRequestDoctor: NSFetchRequest<Doctors> = Doctors.fetchRequest() as! NSFetchRequest<Doctors>
            let PersonPublicresults =  try moc.fetch(fetchRequestPersonPublic)
            
            let personPublic = PersonPublicresults //as! [PersonPublicresults]
            personPublic[0].setValue(firstNameField.text!, forKey: "firstname")
            personPublic[0].setValue(lastNameField.text!, forKey: "lastname")
            signInUserPublic?.firstname = firstNameField.text!
            signInUserPublic?.lastname = lastNameField.text!
            if tempGender != nil{
                personPublic[0].setValue(tempGender!, forKey: "gender")
                signInUserPublic?.gender = tempGender!
            }
            personPublic[0].setValue(tempLongitude!, forKey: "locationlongitude")
            personPublic[0].setValue(tempLatitude!, forKey: "locationLatitude")
            //use string formate to store NSdate for signInUser?.birthday
            dateFormatter.dateFormat = "MM-dd-yyyy"
            signInUserPublic?.birthday = Date(dateString: dateFormatter.string(from: datePicker.date))
            personPublic[0].setValue(Date(dateString: dateFormatter.string(from: signInUserPublic!.birthday!)), forKey: "birthday")
            if tempEthnicity != nil{
                signInUserPublic?.ethnicity = tempEthnicity
                personPublic[0].setValue(tempEthnicity!, forKey: "ethnicity")
            }
            if (tempHeight != nil) && (tempWeight != nil){
                personPublic[0].setValue(tempHeight!, forKey: "height")
                personPublic[0].setValue(tempWeight!, forKey: "weight")
            }
            
            // if user applied doctor status, they can update their doctor name before they are become a doctor.
            if signInDoctor != nil{
                let Doctorresults =  try moc.fetch(fetchRequestDoctor)
                let doctor = Doctorresults //as! [NSManagedObject]
                doctor[0].setValue(firstNameField.text!, forKey: "doctorFirstName")
                doctor[0].setValue(lastNameField.text!, forKey: "doctorLastName")
                signInDoctor?.doctorFirstName = firstNameField.text!
                signInDoctor?.doctorLastName = lastNameField.text!
            }
            try moc.save()
            //need to save to global too
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
    }
    
    //save back to CoreData if click back
    //we want to update
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if  isDoctorSet{
            //if it is doctor, set below row unselectable and not set again
            var index = IndexPath(row: 0, section: 0)
            var cell = tableView.cellForRow(at: index)
            cell?.selectionStyle = .none
            index = IndexPath(row: 0, section: 1)
            cell = tableView.cellForRow(at: index)
            cell?.selectionStyle = .none
            index = IndexPath(row: 0, section: 3)
            cell = tableView.cellForRow(at: index)
            cell?.selectionStyle = .none
            isDoctorSet = false
        }
    }
    
    //updateUI on viewDidLoad and viewWillLayoutSubviews
    fileprivate func updateUI(){
        //name initialization
        if signInUser!.isdoctor!.boolValue{
            namePancelImage.isHidden = true
            genderPencilImage.isHidden = true
            virthdayPencilImage.isHidden = true
        }
        //firstname and lastname is checked in setting, so we can unwrap them here
        nameLabel?.text = printNameOrder(signInUserPublic!.firstname!, lastName: signInUserPublic!.lastname!)
        firstNameField?.placeholder = "First Name"
        firstNameField?.text = signInUserPublic!.firstname!
        lastNameField?.placeholder = "Last Name"
        lastNameField?.text = signInUserPublic!.lastname!
        
        //gender initialization
        //gender is setted so it can unwrap here
        genderLabel?.text = signInUserPublic!.gender!.boolValue ? Storyboard.female : Storyboard.male
        if signInUserPublic!.gender! == true {
            genderSegmentController?.selectedSegmentIndex = 1
        }else{
            genderSegmentController?.selectedSegmentIndex = 0
        }
        genderSegmentController.setTitle(Storyboard.male, forSegmentAt: 0)
        genderSegmentController.setTitle(Storyboard.female, forSegmentAt: 1)
        //location is initialized in printLocation
        //birthday initialization
        invalidBirthday.isHidden = true
        //set datePicker
        datePicker?.maximumDate = Date()
        // set dateFormate
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthdayLabel?.text = dateFormatter.string(from: (signInUserPublic?.birthday)!)
        datePicker.date = signInUserPublic!.birthday!
        
        //ethnicity update
        if signInUserPublic?.ethnicity != nil {
            if signInUserPublic!.ethnicity! != "" {
                ethnicityLabel?.text = printEthnicity(signInUserPublic!.ethnicity!, array: Ethnicity.ethnicity)
                ethnicityLabel?.font = UIFont.systemFont(ofSize: 17)
            }else{
                let navbarFont = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
                ethnicityLabel?.font = navbarFont
                ethnicityLabel?.text = MVC.notSet
            
            }
        }else{
            //initialized signInUser?.ethnicity
            signInUserPublic?.ethnicity = ""
        }
        tempEthnicity = signInUserPublic?.ethnicity
    }
    
    fileprivate func printNameOrder(_ firstName: String, lastName: String) -> String{
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
    
    //from index to print string
    fileprivate func printEthnicity(_ signInUserethnicity: String, array: [String]) -> String{
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return nameSection
        }else if section == 1{
            return genderSection
        }else if section == 2{
            return locationSection
        }else if section == 3{
            return birthdaySection
        }else if section == 5{
            return bmiSection
        }else
        {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        invalidName.isHidden = true
        if !validateName(textField.text!) {
            nameLabel?.text = printNameOrder(firstNameField.text!, lastName: lastNameField.text!)
        }
        else{
            invalidName.isHidden = false
        }
        
        textField.resignFirstResponder()
        return true
    }
}
