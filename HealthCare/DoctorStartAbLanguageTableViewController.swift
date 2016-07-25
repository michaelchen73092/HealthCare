//
//  DoctorStartAbLanguageTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/20/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit
import CoreData

var tempDoctor: Doctors?
class DoctorStartAbLanguageTableViewController: UITableViewController {
    // MARK: - Variables
    var language = [Language.languageArabic, Language.languageBengali, Language.languageCantonese, Language.languageCatalan, Language.languageChinese, Language.languageCroatian, Language.languageCzech, Language.languageDanish, Language.languageDutch, Language.languageEnglish, Language.languageFinnish, Language.languageFrench, Language.languageGerman, Language.languageGreek, Language.languageHebrew, Language.languageHindi, Language.languageHungarian, Language.languageIndonesian, Language.languageItalian, Language.languageJapanese, Language.languageKorean, Language.languageMalay, Language.languageNorwegian, Language.languagePolish, Language.languagePortuguese, Language.languageRomanian, Language.languageRussian, Language.languageSlovak, Language.languageSpanish, Language.languageSwedish, Language.languageTaiwanese, Language.languageThai, Language.languageTurkish, Language.languageUkrainian, Language.languageVietnamese]
    var checked = [Bool]()
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    private struct MVC {
        static let nextIdentifier = "Show DoctorStartAc"
    }
    
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...(language.count - 1) {
            checked.append(false)
        }
        // initialized tempDoctor
        let DoctorsEntity = NSEntityDescription.entityForName("Doctors", inManagedObjectContext: moc)
        tempDoctor = Doctors(entity: DoctorsEntity!, insertIntoManagedObjectContext: moc)
        tempDoctor?.doctorLanguage = ""
        
        //setup navigation
        //title for Language
        let languageTitle = NSLocalizedString("Language", comment: "In DoctorStartAbLanguage's title")
        self.navigationItem.title = languageTitle
        
        let rightSaveNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightSaveNavigationButton
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func nextButtonClicked(){
        //set back item's title to ""
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
        // make sure user at least select one language
        if tempDoctor!.doctorLanguage! == "" {
            //alert that there is no this user
            let selectLanguage = NSLocalizedString("Select Language", comment: "In DoctorStartAc, warning for at least select one language")
            let selectLanguagedetail = NSLocalizedString("Please select at least one language.", comment: "In DoctorStartAc, detail for warning for at least select one language")
            let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            Alert.show(selectLanguage, message: selectLanguagedetail, ok: okstring,vc: self)
        }else{
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return language.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = language[indexPath.row]
       
        //for reuse cell issue that view may display on wrong cell when user scroll fast 
        //check every time when cell is reused
        if checked[indexPath.row] == false {
            cell.accessoryType = .None
        }else{
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
                var languageString = tempDoctor!.doctorLanguage!
                
                //remove 3) ethnicity in last (if it is last selected ethnicity remove)
                if let range = languageString.rangeOfString(", " + language[indexPath.row]){
                    languageString.removeRange(range.startIndex..<range.endIndex)
                }
                
                //remove unCheckmark from ethnicityString String
                if let range = languageString.rangeOfString(language[indexPath.row]){
                    languageString.removeRange(range.startIndex..<range.endIndex)
                }
                
                //remove three possible: 1) ", " at first index which delete first ethnicity
                if let range = languageString.rangeOfString(", ") {
                    if range.startIndex == languageString.startIndex{
                        languageString.removeRange(range.startIndex..<range.endIndex)
                    }
                }
                tempDoctor?.doctorLanguage! = languageString
            } else {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
                if tempDoctor!.doctorLanguage! != "" {
                    tempDoctor?.doctorLanguage! = tempDoctor!.doctorLanguage! + ", " + language[indexPath.row]
                }else{
                    tempDoctor?.doctorLanguage! = language[indexPath.row]
                }
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ac = segue.destinationViewController as? DoctorStartAcLicenceViewController{
            //pass current moc to next controller which use for create Persons object
            ac.moc = self.moc
        }
    }
    
  

}
