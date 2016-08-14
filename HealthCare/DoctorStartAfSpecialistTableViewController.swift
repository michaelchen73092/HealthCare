//
//  DoctorStartAfSpecialistTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/25/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData

class DoctorStartAfSpecialistTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    // MARK: - variable
    weak var lastIndex : NSIndexPath?
    weak var moc : NSManagedObjectContext?
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAg"
    }
    @IBOutlet weak var invalidLabel: UILabel!
    @IBOutlet weak var specialtyDescription: UILabel!
    
    @IBOutlet weak var specialtyTitleLabel: UILabel!
    @IBOutlet weak var specialtyTitleImage: UIImageView!
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description textView
        specialtyDescription.text = NSLocalizedString("Please choose your status or your primary specialty. If you select primary specialty, please also select your current title.", comment: "In DoctorStartAfSpecialist, description for this page")
        
        invalidLabel.hidden = true
        //setup navigation
        let areaTitle = NSLocalizedString("Area of Practice", comment: "In DoctorStartAfSpecialist's title")
        self.navigationItem.title = areaTitle
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        //add graduate back notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.SpecialtyTitleUpdate), name: "SpecialtyTitleBack", object: nil)
        //add Default graduate school
        
        
        //set pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        specialtyLabel.hidden = true
        
        // deal with previous checkmark
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist"{
                lastIndex = NSIndexPath(forRow: 0, inSection: 0)
            }else if tempDoctor!.doctorProfession!.rangeOfString("PGY") != nil {
                lastIndex = NSIndexPath(forRow: 1, inSection: 0)
            }else{
                lastIndex = NSIndexPath(forRow: 2, inSection: 0)
                specialtyLabel.hidden = false
                if Int(tempDoctor!.doctorProfession!) != nil {
                    specialtyLabel.text = specialty.allSpecialty[Int(tempDoctor!.doctorProfession!)!]
                }
            }
        }
        
        //init for specialty title
        SpecialtyTitleUpdate()
    }
    
    @objc
    private func SpecialtyTitleUpdate(){
        if tempDoctor?.doctorProfessionTitle != nil{
            if Int(tempDoctor!.doctorProfessionTitle!) != nil{
                specialtyTitleLabel.text = specialty.title[Int(tempDoctor!.doctorProfessionTitle!)!]
                specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17) ?? UIFont.systemFontOfSize(17)
            }
        }
        if signInUser?.doctorImageSpecialistLicense != nil{
            specialtyTitleImage.image = UIImage(named:"certification")
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if lastIndex != nil{
            let cell = tableView.cellForRowAtIndexPath(lastIndex!)
            cell?.accessoryType = .Checkmark
            lastIndex = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextButtonClicked(){
        invalidLabel.hidden = true
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist" || tempDoctor!.doctorProfession!.rangeOfString("PGY") != nil{
                performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
            }else{
                if tempDoctor?.doctorProfessionTitle != nil{
                    performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
                }else{
                    invalidLabel.hidden = false
                    wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
                }
            }
        }else{
            invalidLabel.hidden = false
            wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
    }
    // MARK: - Internist
    @IBAction func tapInternist(sender: UITapGestureRecognizer) {
        //order of first define tempDoctor?.doctorProfession and then deselectOtherCheckmark() is matter
        tempDoctor?.doctorProfession = "Internist"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    private func deselectOtherCheckmark(){
        var index = NSIndexPath(forRow: 0, inSection: 0)
        var cell = tableView.cellForRowAtIndexPath(index)
        for i in 0...2{
            index = NSIndexPath(forRow: i, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .None
        }
        
        specialistSection = 3
        //remove specialty label
        specialtyLabel.hidden = true
        specialtyLabel.text = ""
        
        //remove specialty title
        specialtyTitleLabel.text = Storyboard.notSet
        specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFontOfSize(17)
        tempDoctor?.doctorProfessionTitle = nil
        
        //remove specialtyImage
        signInUser?.doctorImageSpecialistLicense = nil
        specialtyTitleImage.image = UIImage(named:"edit")
        tableView.reloadData()
    }
    
    // MARK: - PGY
    @IBAction func tapPGY(sender: UITapGestureRecognizer) {
        tempDoctor?.doctorProfession = "PGY(Taiwan medical system only)"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = NSIndexPath(forRow: 1, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index)
        cell!.accessoryType = .Checkmark
        tableView.reloadData()
    }
    
    // MARK: - Specialty
    var specialistSection = 3
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var specialtyLabel: UILabel!
    
    @IBAction func tapSpecialty(sender: UITapGestureRecognizer) {
        if specialistSection == 3 {
            // deselect others
            var index = NSIndexPath(forRow: 0, inSection: 0)
            var cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .None
            index = NSIndexPath(forRow: 1, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .None
            
            specialistSection = 5
            //checkmark
            index = NSIndexPath(forRow: 2, inSection: 0)
            cell = tableView.cellForRowAtIndexPath(index)
            cell!.accessoryType = .Checkmark
            tableView.reloadData()
            let indexPath = NSIndexPath(forRow: 4, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            //clear previous value if it is not specialty
            if tempDoctor?.doctorProfession != nil{
                if Int(tempDoctor!.doctorProfession!) == nil{
                    tempDoctor?.doctorProfession = nil
                }
            }
        }else {
            //it's been set true when specialistSection == 3
            if tempDoctor?.doctorProfession != nil {
                specialtyLabel.hidden = false
            }
            specialistSection = 3
            tableView.reloadData()
        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialty.allSpecialty.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialty.allSpecialty[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        specialtyLabel.text = specialty.allSpecialty[row]
        specialtyLabel.hidden = false
        tempDoctor?.doctorProfession = String(row)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return specialistSection
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 240
        }
        return 60
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ag = segue.destinationViewController as? DoctorStartAgCurrentHospitalTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ag.moc = self.moc!
        }
//        if let _ = segue.destinationViewController as? DoctorStartAjSpecialtyTitleTableViewController{
//            let backItem = UIBarButtonItem()
//            backItem.title = ""
//            self.navigationItem.backBarButtonItem = backItem
//        }
    }
    


}
