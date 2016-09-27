//
//  DoctorStartAfSpecialistTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/25/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 10.0, *)
class DoctorStartAfSpecialistTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    // MARK: - variable
    
    @IBOutlet weak var internistLabel: UILabel!
    @IBOutlet weak var pgyLabel: UILabel!
    @IBOutlet weak var primarySpecialtyLabel: UILabel!
    @IBOutlet weak var specialtyTitleTitleOnly: UILabel!
    
    
    var lastIndex : IndexPath?
    weak var moc : NSManagedObjectContext?
    fileprivate struct MVC {
        static let nextIdentifier = "Show DoctorStartAg"
        static let primarySpecialty = NSLocalizedString("Primary Specialty:", comment: "DoctorStartAfSpecialist")
        static let specialtyTitle = NSLocalizedString("Specialty Title:", comment: "DoctorStartAfSpecialist")
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
        
        invalidLabel.isHidden = true
        //UI setup
        internistLabel.text = Storyboard.internist
        pgyLabel.text = Storyboard.pgy
        primarySpecialtyLabel.text = MVC.primarySpecialty
        specialtyTitleTitleOnly.text = MVC.specialtyTitle
        //setup navigation
        let areaTitle = NSLocalizedString("Area of Practice", comment: "In DoctorStartAfSpecialist's title")
        self.navigationItem.title = areaTitle
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        //add graduate back notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.SpecialtyTitleUpdate), name: NSNotification.Name(rawValue: "SpecialtyTitleBack"), object: nil)
        //add Default graduate school
        
        
        //set pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        specialtyLabel.isHidden = true
        
        // deal with previous checkmark
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist"{
                lastIndex = IndexPath(row: 0, section: 0)
            }else if tempDoctor!.doctorProfession!.range(of: "PGY") != nil {
                lastIndex = IndexPath(row: 1, section: 0)
            }else{
                lastIndex = IndexPath(row: 2, section: 0)
                specialtyLabel.isHidden = false
                if Int(tempDoctor!.doctorProfession!) != nil {
                    specialtyLabel.text = specialty.allSpecialty[Int(tempDoctor!.doctorProfession!)!]
                }
            }
        }
        
        //init for specialty title
        SpecialtyTitleUpdate()
    }
    
    @objc
    fileprivate func SpecialtyTitleUpdate(){
        if tempDoctor?.doctorProfessionTitle != nil{
            if Int(tempDoctor!.doctorProfessionTitle!) != nil{
                specialtyTitleLabel.text = specialty.title[Int(tempDoctor!.doctorProfessionTitle!)!]
                specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
        if signInUser?.doctorImageSpecialistLicense != nil{
            specialtyTitleImage.image = UIImage(named:"certification")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if lastIndex != nil{
            let cell = tableView.cellForRow(at: lastIndex!)
            cell?.accessoryType = .checkmark
            lastIndex = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nextButtonClicked(){
        invalidLabel.isHidden = true
        if tempDoctor?.doctorProfession != nil {
            if tempDoctor!.doctorProfession! == "Internist" || tempDoctor!.doctorProfession!.range(of: "PGY") != nil{
                performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
            }else{
                if tempDoctor?.doctorProfessionTitle != nil{
                    performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
                }else{
                    invalidLabel.isHidden = false
                    wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
                }
            }
        }else{
            invalidLabel.isHidden = false
            wiggleInvalidtext(invalidLabel, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
    }
    // MARK: - Internist
    @IBAction func tapInternist(_ sender: UITapGestureRecognizer) {
        //order of first define tempDoctor?.doctorProfession and then deselectOtherCheckmark() is matter
        tempDoctor?.doctorProfession = "Internist"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .checkmark
        tableView.reloadData()
    }
    
    fileprivate func deselectOtherCheckmark(){
        var index = IndexPath(row: 0, section: 0)
        var cell = tableView.cellForRow(at: index)
        for i in 0...2{
            index = IndexPath(row: i, section: 0)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .none
        }
        
        specialistSection = 3
        //remove specialty label
        specialtyLabel.isHidden = true
        specialtyLabel.text = ""
        
        //remove specialty title
        specialtyTitleLabel.text = Storyboard.notSet
        specialtyTitleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
        tempDoctor?.doctorProfessionTitle = nil
        
        //remove specialtyImage
        signInUser?.doctorImageSpecialistLicense = nil
        specialtyTitleImage.image = UIImage(named:"edit")
        tableView.reloadData()
    }
    
    // MARK: - PGY
    @IBAction func tapPGY(_ sender: UITapGestureRecognizer) {
        tempDoctor?.doctorProfession = "PGY(Taiwan medical system only)"
        // deselect others
        deselectOtherCheckmark()
        //checkmark
        let index = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: index)
        cell!.accessoryType = .checkmark
        tableView.reloadData()
    }
    
    // MARK: - Specialty
    var specialistSection = 3
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var specialtyLabel: UILabel!
    
    @IBAction func tapSpecialty(_ sender: UITapGestureRecognizer) {
        if specialistSection == 3 {
            // deselect others
            var index = IndexPath(row: 0, section: 0)
            var cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .none
            index = IndexPath(row: 1, section: 0)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .none
            
            specialistSection = 5
            //checkmark
            index = IndexPath(row: 2, section: 0)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .checkmark
            tableView.reloadData()
            let indexPath = IndexPath(row: 4, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
            //clear previous value if it is not specialty
            if tempDoctor?.doctorProfession != nil{
                if Int(tempDoctor!.doctorProfession!) == nil{
                    tempDoctor?.doctorProfession = nil
                }
            }
        }else {
            //it's been set true when specialistSection == 3
            if tempDoctor?.doctorProfession != nil {
                specialtyLabel.isHidden = false
            }
            specialistSection = 3
            tableView.reloadData()
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return specialty.allSpecialty.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return specialty.allSpecialty[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        specialtyLabel.text = specialty.allSpecialty[row]
        specialtyLabel.isHidden = false
        tempDoctor?.doctorProfession = String(row)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return specialistSection
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 3 {
            return 240
        }
        return 60
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ag = segue.destination as? DoctorStartAgCurrentHospitalTableViewController{
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
