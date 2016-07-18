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

    private struct MVC {
        static let manuallySearchCityIdentifier = "SearchCity"
    }

    
    // for updateUserInfo to local CoreData
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Edit for Name
    //each time change section number, we need to reloadData
    //We set tap gesture on every row to controller tap situation
    @IBOutlet weak var firstNameField: UITextField!{ didSet{ firstNameField.delegate = self}}
    @IBOutlet weak var lastNameField: UITextField!{ didSet{ lastNameField.delegate = self}}
    var nameSection = 1
    @IBAction func tapName(sender: UITapGestureRecognizer) {
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
        updateUI()
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
        
        //store latitude and longitude for user info
        signInUser?.locationLatitude = manager.location!.coordinate.latitude
        signInUser?.locationlongitude = manager.location!.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
        //print location
        if (signInUser!.locationLatitude! == 0) && (signInUser!.locationlongitude! == 0) {
            locationLabel.font = UIFont.systemFontOfSize(17)
            let localText = NSLocalizedString("Not Set", comment: "In PersonCb's LocationLabel default value")
            locationLabel.text = localText
        }else{
            let userLocation = CLLocation(latitude: Double(signInUser!.locationLatitude!), longitude: Double(signInUser!.locationlongitude!))
            reverseGeoLocation(userLocation)
        }
    }
    
    func printLocation(){
        print("signInUser!.locationLatitude!: \(signInUser!.locationLatitude!)")
        print("signInUser!.locationlongitude!: \(signInUser!.locationlongitude!)")
        if (signInUser!.locationLatitude! == 0) && (signInUser!.locationlongitude! == 0) {
            locationLabel.font = UIFont.systemFontOfSize(17)
            let localText = NSLocalizedString("Not Set", comment: "In PersonCb's LocationLabel default value")
            locationLabel.text = localText
        }else{
            let userLocation = CLLocation(latitude: Double(signInUser!.locationLatitude!), longitude: Double(signInUser!.locationlongitude!))
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
    
    func reverseGeoLocation(location: CLLocation?){
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
                self.displayLocationInfo(pm)
            }else{
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark){
        let city = (placemark.locality != nil) ? placemark.locality! : ""
        let state = (placemark.administrativeArea != nil) ? placemark.administrativeArea! : ""
        let country = (placemark.country != nil) ? placemark.country! : ""
        let navbarFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFontOfSize(17)
        locationLabel.font = navbarFont
        locationLabel.text = "\(city), \(state) in \(country)"
        
    }
    
    
    @IBAction func tapEditLocation(sender: UITapGestureRecognizer) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 100.0 // Will notify the LocationManager every 100 meters, not aler all the time
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
        tableView.reloadData()
        
    }
    

    
    private func tapAll(){
        nameSection = 1
        genderSection = 1
        locationSection = 1
        birthdaySection = 1
        tableView.reloadData()
    }

    func datePickerChanged(datePicker:UIDatePicker) {
        invalidBirthday.hidden = true
        //use string formate to store NSdate for signInUser?.birthday
        dateFormatter.dateFormat = "MM-dd-yyyy"
        signInUser?.birthday = NSDate(dateString: dateFormatter.stringFromDate(datePicker.date))
        // this formate is localized formate already
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        if strDate == dateFormatter.stringFromDate(NSDate()){
            invalidBirthday.hidden = false
        }else{
            birthdayLabel.text = strDate
        }
    }
    
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation bar, set back button title in PersonsCa's prepareForSeque
        let accountTitle = NSLocalizedString("Basic Info", comment: "Under more in setting account , the title for Account setting")
        self.navigationItem.title = accountTitle

        updateUI()
        //location initialization
        printLocation()
        
        //add datePicker event
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI()
        printLocation()
    }
    
    //save back to CoreData if click back
    //we want to update
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //printLocation()
        //print("viewWillAppear")
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
            person[0].setValue(NSDate(dateString: dateFormatter.stringFromDate((signInUser?.birthday)!)), forKey: "birthday")
            try moc.save()
            //need to save to global too
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
        
        
    }
    
    //updateUI on viewDidLoad and viewWillLayoutSubviews
    private func updateUI(){
        //name initialization
        nameLabel?.text = "\(signInUser!.firstname!) \(signInUser!.lastname!)"
        firstNameField?.placeholder = "First Name"
        firstNameField?.text = signInUser!.firstname!
        lastNameField?.placeholder = "Last Name"
        lastNameField?.text = signInUser!.lastname!
        
        //gender initialization
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
        birthdayLabel.text = dateFormatter.stringFromDate((signInUser?.birthday)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 6
        {
            return 3
        }else if section == 0{
            return nameSection
        }else if section == 1{
            return genderSection
        }else if section == 2{
            return locationSection
        }else if section == 3{
            return birthdaySection
        }else
        {
            return 1
        }
    }

    
    // MARK: - Keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        signInUser?.firstname = firstNameField.text
        signInUser?.lastname = lastNameField.text
        updateUI()
        return true
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
