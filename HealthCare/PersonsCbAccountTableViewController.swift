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

class PersonsCbAccountTableViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    // MARK: - Setting for each attribute
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var ethnicityLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!

    
    private struct MVC {
        static let manuallySearchCityIdentifier = "SearchCity"
        static let notSet =  NSLocalizedString("Not Set", comment: "In PersonsCbAccount for Not set constant")
    }

    
    // for updateUserInfo to local CoreData
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Edit for Name
    //each time change section number, we need to reloadData
    //We set tap gesture on every row to controller tap situation
    @IBOutlet weak var firstNameField: UITextField!{ didSet{ firstNameField.delegate = self}}
    @IBOutlet weak var lastNameField: UITextField!{ didSet{ lastNameField.delegate = self}}
    @IBOutlet weak var invalidName: UILabel!
    
    var nameSection = 1
    @IBAction func tapName(sender: UITapGestureRecognizer) {
        invalidName.hidden = true
        if !validateName(firstNameField.text!) && !validateName(lastNameField.text!) {
            if nameSection == 1{
                nameSection = 2
            }else{
                nameSection = 1
            }
            signInUser?.firstname = firstNameField.text
            signInUser?.lastname = lastNameField.text
            //close other
            genderSection = 1
            locationSection = 1
            birthdaySection = 1
            bmiSection = 1
            nameLabel?.text = "\(signInUser!.firstname!) \(signInUser!.lastname!)"
        }
        else{
            invalidName.hidden = false
        }
        tableView.reloadData()
    }
    @IBAction func tapEditName(sender: UITapGestureRecognizer) {
        tapAll()
    }

    // MARK: - Edit for Gender
    var genderSection = 1
    @IBOutlet weak var genderSegmentController: UISegmentedControl!
    @IBAction func genderSegmentAction() {
        if genderSegmentController.selectedSegmentIndex == 0{
            signInUser?.gender = "Male"
        }else{
            signInUser?.gender = "Female"
        }
        genderLabel?.text = signInUser!.gender!
    }
    
    @IBAction func tapGender(sender: UITapGestureRecognizer) {
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
    
    @IBAction func tapEditGender(sender: UITapGestureRecognizer) {
        tapAll()
    }
    
    // MARK: - Edit for location
    var locationSection = 1
    
    @IBAction func tapLocation(sender: UITapGestureRecognizer) {
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
    
    

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("in didUpdateLocations")
        //print location
        if manager.location != nil{
            let userLocation = CLLocation(latitude: manager.location!.coordinate.latitude, longitude: manager.location!.coordinate.longitude)
            print("manager.location!.coordinate.latitude:\(manager.location!.coordinate.latitude)")
            print("manager.location!.coordinate.longitude:\(manager.location!.coordinate.longitude)")
            GeoLocation(userLocation)
            locationLabel.font = UIFont.systemFontOfSize(17)
        }
    }
    
    func printLocation(){
        print("In printLocation, signInUser!.locationLatitude!: \(signInUser!.locationLatitude!)")
        print("In printLocation, signInUser!.locationlongitude!: \(signInUser!.locationlongitude!)")
        if (signInUser!.locationLatitude! != 0) || (signInUser!.locationlongitude! != 0) {
            locationLabel.font = UIFont.systemFontOfSize(17)
            let userLocation = CLLocation(latitude: Double(signInUser!.locationLatitude!), longitude: Double(signInUser!.locationlongitude!))
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
    
    func GeoLocation(location: CLLocation?){
        CLGeocoder().reverseGeocodeLocation(location!) { (placemarks, error) in
            if error != nil {
                let noInternet = NSLocalizedString("No Internet Connection", comment: "Title for error message that no internet in PersonCb's LocationLabel")
                let noInternetMessage =  NSLocalizedString("Please Use Wi-Fi to Access Data", comment: "Message for error message that no internet in PersonCb's LocationLabel")
                let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
                Alert.show(noInternet, message: noInternetMessage, ok: okstring,vc: self)
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks?.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                //store latitude and longitude for user info
                signInUser?.locationLatitude = location!.coordinate.latitude
                signInUser?.locationlongitude = location!.coordinate.longitude
                self.displayLocationInfo(pm)
                print("location!.coordinate.latitude:\(location!.coordinate.latitude)")
                print("location!.coordinate.longitude:\(location!.coordinate.longitude)")
                //wait finish update then tableView reload
                self.locationSection = 1
                self.tableView.reloadData()
                self.locationManager.stopUpdatingLocation()
            }else{
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark){
        let city = (placemark.locality != nil) ? placemark.locality! : ""
        let state = (placemark.administrativeArea != nil) ? placemark.administrativeArea! : ""
        let country = (placemark.country != nil) ? placemark.country! : ""
        locationLabel.text = "\(city), \(state) in \(country)"
        print("locationLabel.text:\(locationLabel.text!)")
        print("displayLocationInfo")
        
    }
    
    
    @IBAction func tapEditLocation(sender: UITapGestureRecognizer) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 1000.0 // Will notify the LocationManager every 1000 meters, not aler all the time
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Birthday
    var birthdaySection = 1
    @IBOutlet weak var datePicker: UIDatePicker!
    let dateFormatter = NSDateFormatter()
    @IBOutlet weak var invalidBirthday: UILabel!

    
    @IBAction func tapBirthday(sender: UITapGestureRecognizer) {
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
            let indexPath = NSIndexPath(forRow: 1, inSection: 3)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    

    
    private func tapAll(){
        nameSection = 1
        genderSection = 1
        locationSection = 1
        birthdaySection = 1
        bmiSection = 1
        //no ethnicity section
        tableView.reloadData()
    }

    func datePickerChanged(datePicker:UIDatePicker) {
        invalidBirthday?.hidden = true
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        if strDate == dateFormatter.stringFromDate(NSDate()){
            invalidBirthday?.hidden = false
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
    
    
    @IBAction func tapBMI(sender: UITapGestureRecognizer) {
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
            let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    private func bmiCalculate(){
        if (signInUser?.height != nil) && (signInUser?.weight != nil){
            let height = Float(signInUser!.height!) / 100
            let bmi = Float(signInUser!.weight!) / (height * height)
            if (height != 0) && (Float(signInUser!.weight!) != 0){
                bmiValue.text = String(format: "%.1f", bmi)
                
                let Underweight =  NSLocalizedString("Underweight", comment: "In PersonsCbAccount for bmi Meaning")
                let Normal =  NSLocalizedString("Normal", comment: "In PersonsCbAccount for bmi Meaning")
                let Overweight =  NSLocalizedString("Overweight", comment: "In PersonsCbAccount for bmi Meaning")
                let Obese =  NSLocalizedString("Obese", comment: "In PersonsCbAccount for bmi Meaning")
                
                if bmi < 18.5 { bmiMeaning.text = Underweight}
                else if bmi >= 18.5 && bmi < 24.9 {bmiMeaning.text = Normal}
                else if bmi >= 24.9 && bmi < 29.9 {bmiMeaning.text = Overweight}
                else {bmiMeaning.text = Obese}
                
                bmiLabel.font = UIFont.systemFontOfSize(17)
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
    
    private func bmiInit(){
        if (signInUser?.height != nil) {
            heightSliderValue.value = Float(signInUser!.height!)
            heightCalculate()
        }
        if (signInUser?.weight != nil){
            weightSliderValue.minimumValue = 0.0
            weightSliderValue.maximumValue = 140.0
            weightSliderValue.value = Float(signInUser!.weight!)
            weightCalculate()
        }
        bmiCalculate()
    }
    
    @IBAction func heightSlider(sender: UISlider) {
        heightCalculate()
        signInUser?.height = heightSliderValue.value
        bmiCalculate()
    }
    
    @IBAction func weightSlider(sender: UISlider) {
        weightCalculate()
        signInUser?.weight = weightSliderValue.value
        bmiCalculate()
    }

    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation bar, set back button title in PersonsCa's prepareForSeque
        let accountTitle = NSLocalizedString("Basic Info", comment: "In PersonsCbAccount, the title for Account setting")
        self.navigationItem.title = accountTitle
        let saveTitle = NSLocalizedString("Save", comment: "In PersonsCbAccount, the title for save update")
        let rightSaveNavigationButton = UIBarButtonItem(title: saveTitle , style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.saveButtonClicked))
        self.navigationItem.rightBarButtonItem = rightSaveNavigationButton
        
        //setup UI
        invalidName.hidden = true
        updateUI()
        //location initialization
        printLocation()
        //BMI initialization
        bmiInit()
        
        //add datePicker event
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //add ethnicity back notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.ethnicityBackUpdate), name: "ethnicityBack", object: nil)
        //add location back notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.searchCityBackUpdate), name: "searchCityBack", object: nil)
        
        print("In viewDidLoad")
        
    }

    func ethnicityBackUpdate(){
        //if Ethnicity is changed it will show in here
        if signInUser!.ethnicity! != "" {
            ethnicityLabel?.text = signInUser!.ethnicity!
            ethnicityLabel?.font = UIFont.systemFontOfSize(17)
        }else{
            let navbarFont = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
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
        saveToCoreData()
        // After saving go back to previous page
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ethnicityBack", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "searchCityBack", object: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    func saveToCoreData(){
        let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        //fetch a local user in HD
        do {
            let Personresults =  try moc.executeFetchRequest(fetchRequestPerson)
            
            let person = Personresults as! [NSManagedObject]
            person[0].setValue(signInUser!.firstname!, forKey: "firstname")
            person[0].setValue(signInUser!.lastname!, forKey: "lastname")
            person[0].setValue(signInUser!.gender!, forKey: "gender")
            person[0].setValue(signInUser!.locationlongitude!, forKey: "locationlongitude")
            person[0].setValue(signInUser!.locationLatitude!, forKey: "locationLatitude")
            //use string formate to store NSdate for signInUser?.birthday
            dateFormatter.dateFormat = "MM-dd-yyyy"
            signInUser?.birthday = NSDate(dateString: dateFormatter.stringFromDate(datePicker.date))
            person[0].setValue(NSDate(dateString: dateFormatter.stringFromDate(signInUser!.birthday!)), forKey: "birthday")
            person[0].setValue(signInUser!.ethnicity!, forKey: "ethnicity")
            if (signInUser?.height != nil) && (signInUser?.weight != nil){
                person[0].setValue(signInUser!.height!, forKey: "height")
                person[0].setValue(signInUser!.weight!, forKey: "weight")
            }
            try moc.save()
            //need to save to global too
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "ethnicityBack", object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: "searchCityBack", object: nil)
        saveToCoreData()
        print("viewWillDisappear")
    }
    
    //save back to CoreData if click back
    //we want to update
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    //updateUI on viewDidLoad and viewWillLayoutSubviews
    private func updateUI(){
        //name initialization
        //firstname and lastname is checked in setting, so we can unwrap them here
        nameLabel?.text = "\(signInUser!.firstname!) \(signInUser!.lastname!)"
        firstNameField?.placeholder = "First Name"
        firstNameField?.text = signInUser!.firstname!
        lastNameField?.placeholder = "Last Name"
        lastNameField?.text = signInUser!.lastname!
        
        //gender initialization
        //gender is setted so it can unwrap here
        genderLabel?.text = signInUser!.gender!
        if signInUser!.gender! == "Female"{
            genderSegmentController?.selectedSegmentIndex = 1
        }else{
            genderSegmentController?.selectedSegmentIndex = 0
        }
        
        //location is initialized in printLocation
        //birthday initialization
        invalidBirthday.hidden = true
        //set datePicker
        datePicker?.maximumDate = NSDate()
        // set dateFormate
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        birthdayLabel?.text = dateFormatter.stringFromDate((signInUser?.birthday)!)
        datePicker.date = signInUser!.birthday!
        
        //ethnicity update
        if signInUser?.ethnicity != nil {
            if signInUser!.ethnicity! != "" {
                ethnicityLabel?.text = signInUser!.ethnicity!
                ethnicityLabel?.font = UIFont.systemFontOfSize(17)
            }else{
                let navbarFont = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
                ethnicityLabel?.font = navbarFont
                ethnicityLabel?.text = MVC.notSet
            
            }
        }else{
            //initialized signInUser?.ethnicity
            signInUser?.ethnicity = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        invalidName.hidden = true
        if !validateName(textField.text!) {
            signInUser?.firstname = firstNameField.text
            signInUser?.lastname = lastNameField.text
            nameLabel?.text = "\(signInUser!.firstname!) \(signInUser!.lastname!)"
        }
        else{
            invalidName.hidden = false
        }
        
        textField.resignFirstResponder()
        return true
    }
    
//    // MARK: - prepareForSegue
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        var destination = segue.destinationViewController as UIViewController
//        if let navCon = destination as? UINavigationController {
//            destination = navCon.visibleViewController!
//        }
//        if destination is PersonsCdEthnicityTableViewController{
//            //pass current moc to next controller which use for create Persons object
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            self.navigationItem.backBarButtonItem = backItem
//        }
//    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
