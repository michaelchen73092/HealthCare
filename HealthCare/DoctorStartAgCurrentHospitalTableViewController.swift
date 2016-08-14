//
//  DoctorStartAgCurrentHospitalTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/26/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class DoctorStartAgCurrentHospitalTableViewController: UITableViewController, UITextViewDelegate {
    
    // MARK: - Variables
    let MIN_SIZE = CGFloat(11.0)
    @IBOutlet weak var invalidLabel: UILabel!
    weak var moc : NSManagedObjectContext?
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAh"
        static let addressIdentifier = "Show DoctorStartAk"
    }

    @IBOutlet weak var currentHospitalDescription: UILabel!
    @IBOutlet weak var HospitalAddress: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description
        currentHospitalDescription.text = NSLocalizedString("Please type your current employed hospital or clinic AND its address. You can also provide past experience in second section.", comment: "In DoctorStartAgCurrentHospital, description for this page")
        printLocation()
        //add location back notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.HospitalAddressBackUpdate), name: "HospitalAddress", object: nil)
        
        //setup navigation
        let currentHospitalTitle = NSLocalizedString("Current Hospital", comment: "In DoctorStartAgCurrentHospital's title")
        self.navigationItem.title = currentHospitalTitle
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        invalidLabel.hidden = true
        
        if tempDoctor?.doctorHospital != nil{
            currentHospital.text = tempDoctor!.doctorHospital!
        }
        currentHospital.becomeFirstResponder()
    
        if tempDoctor?.doctorExperienceOne != nil{
            experienceSection = 1
            firstExperience.text = tempDoctor!.doctorExperienceOne!
            if tempDoctor?.doctorExperienceTwo != nil{
                experienceSection = 2
                secondExperience.text = tempDoctor!.doctorExperienceTwo!
                if tempDoctor?.doctorExperienceThree != nil{
                    experienceSection = 3
                    thirdExperience.text = tempDoctor!.doctorExperienceThree!
                    if tempDoctor?.doctorExperienceFour != nil{
                        experienceSection = 4
                        fourthExperience.text = tempDoctor!.doctorExperienceFour!
                        if tempDoctor?.doctorExperienceFive != nil{
                            experienceSection = 5
                            fifthExperience.text = tempDoctor!.doctorExperienceFive!
                        }
                    }
                }
            }
        }
        
    }
    
    func nextButtonClicked(){
        if currentHospital.text == "" || (tempDoctor!.doctorHospitalLatitude! == 0) && (tempDoctor!.doctorHospitalLongitude! == 0) {
            invalidLabel.hidden = false
            wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else if (experienceSection == 2 && (firstExperience.text == "")) || (experienceSection == 3 && (firstExperience.text == "" || secondExperience.text == "")) || (experienceSection == 4 && (firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "")) || (experienceSection == 5 && (firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "" || fourthExperience.text == "")){
            invalidLabel.hidden = false
            wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            tempDoctor?.doctorHospital = (currentHospital.text != "") ? currentHospital.text : nil
            tempDoctor?.doctorExperienceOne = (firstExperience.text != "") ? firstExperience.text : nil
            tempDoctor?.doctorExperienceTwo = (secondExperience.text != "") ? secondExperience.text : nil
            tempDoctor?.doctorExperienceThree = (thirdExperience.text != "") ? thirdExperience.text : nil
            tempDoctor?.doctorExperienceFour = (fourthExperience.text != "") ? fourthExperience.text : nil
            tempDoctor?.doctorExperienceFive = (fifthExperience.text != "") ? fifthExperience.text : nil
            //go to next
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
    }
    
    func HospitalAddressBackUpdate(){
        printLocation()
        print("get SearchCityBack notice")
    }
    
    // MARK: - Current Hospital
    
    @IBOutlet weak var currentHospital: UITextView!{didSet{currentHospital.delegate = self}}
    
    @IBAction func currentHospitalEditButton() {
        currentHospital.becomeFirstResponder()
    }
    
    @IBAction func tapAddress(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier(MVC.addressIdentifier, sender: nil)
    }
    
    func printLocation(){
        if (tempDoctor!.doctorHospitalLatitude! != 0) || (tempDoctor!.doctorHospitalLongitude! != 0) {
            HospitalAddress.font = UIFont(name: "HelveticaNeue-Light", size: 17) ?? UIFont.systemFontOfSize(17)
            let userLocation = CLLocation(latitude: Double(tempDoctor!.doctorHospitalLatitude!), longitude: Double(tempDoctor!.doctorHospitalLongitude!))
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
    
    func displayLocationInfo(placemark: CLPlacemark){
        // put a space between "4" and "Melrose Place"
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? ""
        )
        let country = (placemark.country != nil) ? placemark.country! : ""
        HospitalAddress.text = addressLine + ", \(country)"
        print("locationLabel.text:\(HospitalAddress.text!)")
        
    }
    
    
    // MARK: - Past Experience
    
    var experienceSection = 1
    @IBOutlet weak var firstExperience: UITextView!{didSet{firstExperience.delegate = self}}
    
    @IBAction func firstExperienceAdd() {
        invalidLabel.hidden = true
        if firstExperience.text == ""{
            invalidLabel.hidden = false
        }else{
            experienceSection = 2
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var secondExperience: UITextView!{didSet{secondExperience.delegate = self}}
    
    @IBAction func secondExperienceSub() {
        if experienceSection == 2{
            experienceSection = 1
            secondExperience.text = ""
            tempDoctor?.doctorExperienceTwo = nil
            tableView.reloadData()
        }
    }
    
    @IBAction func secondExperienceAdd() {
        invalidLabel.hidden = true
        if firstExperience.text == "" || secondExperience.text == ""{
            invalidLabel.hidden = false
        }else{
            experienceSection = 3
            tableView.reloadData()
        }
    }

    @IBOutlet weak var thirdExperience: UITextView!{didSet{thirdExperience.delegate = self}}

    @IBAction func thirdExperienceSub() {
        if experienceSection == 3{
            experienceSection = 2
            thirdExperience.text = ""
            tempDoctor?.doctorExperienceThree = nil // for come back from next page
            tableView.reloadData()
        }
    }
    
    @IBAction func thirdExperienceAdd() {
        invalidLabel.hidden = true
        if firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == ""{
            invalidLabel.hidden = false
        }else{
            experienceSection = 4
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var fourthExperience: UITextView!{didSet{fourthExperience.delegate = self}}

    @IBAction func fourthExperienceSub() {
        if experienceSection == 4{
            experienceSection = 3
            fourthExperience.text = ""
            tempDoctor?.doctorExperienceFour = nil
            tableView.reloadData()
        }
    }
    
    @IBAction func fourthExperienceAdd() {
        invalidLabel.hidden = true
        if firstExperience.text == "" || secondExperience.text == "" || thirdExperience.text == "" || fourthExperience.text == ""{
            invalidLabel.hidden = false
        }else{
            experienceSection = 5
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var fifthExperience: UITextView!{didSet{fifthExperience.delegate = self}}
    
    @IBAction func fifthExperienceSub() {
        if experienceSection == 5{
            experienceSection = 4
            fifthExperience.text = ""
            tempDoctor?.doctorExperienceFive = nil
            tableView.reloadData()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return experienceSection
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Keyboard
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        invalidLabel.hidden = true
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let pos = textView.endOfDocument
        let currentRect = textView.caretRectForPosition(pos)
        if textView.bounds.size.width - 20 <= currentRect.origin.x{
            if textView.font?.pointSize >= MIN_SIZE{
                textView.font = UIFont.systemFontOfSize(textView.font!.pointSize - 1)
            }
        }
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ah = segue.destinationViewController as? DoctorStartAhSummaryTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ah.moc = self.moc!
        }
        if let _ = segue.destinationViewController as? DoctorStarAkSearchAddressTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
        }
    }


}
