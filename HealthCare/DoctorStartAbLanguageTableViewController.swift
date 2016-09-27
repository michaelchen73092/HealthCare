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


@available(iOS 10.0, *)
class DoctorStartAbLanguageTableViewController: UITableViewController {
    // MARK: - Variables
    var checked = [Bool]()
    weak var moc : NSManagedObjectContext?
    
    fileprivate struct MVC {
        static let nextIdentifier = "Show DoctorStartAc"
    }
    
    @IBOutlet weak var languageDescription: UILabel!
    
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        languageDescription.text = NSLocalizedString("Choose language(s) that you are comfortable to communicate with patient.", comment: "In DoctorStartAbLanguage, description for this page")
        for _ in 0...(Language.allLanguage.count - 1) {
            checked.append(false)
        }
        
        tempDoctor?.doctorLanguage = ""
        
        //setup navigation
        //title for Language
        let languageTitle = NSLocalizedString("Language", comment: "In DoctorStartAbLanguage's title")
        self.navigationItem.title = languageTitle
        
        let rightSaveNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.nextButtonClicked))
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
            Alert.show(selectLanguage, message: selectLanguagedetail, ok: okstring, dismissBoth: false,vc: self)
        }else{
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Language.allLanguage.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = Language.allLanguage[(indexPath as NSIndexPath).row]
       
        //for reuse cell issue that view may display on wrong cell when user scroll fast 
        //check every time when cell is reused
        if checked[(indexPath as NSIndexPath).row] == false {
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[(indexPath as NSIndexPath).row] = false
                var languageString = tempDoctor!.doctorLanguage!
                // use ", " and " " to closure a number
                //this part is remove exist language
                //remove 3) in last or between (if it is last selected language remove)
                if let range = languageString.range(of: ", " + String((indexPath as NSIndexPath).row) + " "){
                    languageString.removeSubrange(range.lowerBound..<range.upperBound)
                }
                
                //remove unCheckmark from in first
                if let range = languageString.range(of: " " + String((indexPath as NSIndexPath).row) + " "){
                    languageString.removeSubrange(range.lowerBound..<range.upperBound)
                }
                
                //remove  ", " at first index which delete first language
                if let range = languageString.range(of: ",") {
                    if range.lowerBound == languageString.startIndex{
                        languageString.removeSubrange(range.lowerBound..<range.upperBound)
                    }
                }
                tempDoctor?.doctorLanguage! = languageString
            } else {
                //this part select a language
                cell.accessoryType = .checkmark
                checked[(indexPath as NSIndexPath).row] = true
                if tempDoctor!.doctorLanguage! != "" {
                    tempDoctor?.doctorLanguage! = tempDoctor!.doctorLanguage! + ", " + String((indexPath as NSIndexPath).row) + " "
                }else{
                    tempDoctor?.doctorLanguage! = " " + String((indexPath as NSIndexPath).row) + " "
                }
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ac = segue.destination as? DoctorStartAcLicenceViewController{
            //pass current moc to next controller which use for create Persons object
            ac.moc = self.moc
        }
    }
    
  

}
