//
//  DoctorCcLanguageTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/20/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class DoctorCcLanguageTableViewController: UITableViewController {

    var checked = [Bool]()
    @IBOutlet weak var languageDescription: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageDescription.text = NSLocalizedString("Choose language(s) that you are comfortable to communicate with patient.", comment: "In DoctorStartAbLanguage, description for this page")
        for _ in 0...(Language.allLanguage.count - 1) {
            checked.append(false)
        }
        //put checkmark for previous chocice
        checkPreviousLanguage()

        //setup navigation
        //title for Language
        let languageTitle = NSLocalizedString("Language", comment: "In DoctorCcLanguage's title")
        self.navigationItem.title = languageTitle
        let leftSaveNavigationButton = UIBarButtonItem(title: Storyboard.backNavigationItemLeftButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.leftButtonClicked))
        self.navigationItem.leftBarButtonItem = leftSaveNavigationButton
    }

    func leftButtonClicked(){
        // make sure user at least select one language
        if signInDoctor!.doctorLanguage! == "" {
            //alert that there is no this user
            let selectLanguage = NSLocalizedString("Select Language", comment: "In DoctorStartAc, warning for at least select one language")
            let selectLanguagedetail = NSLocalizedString("Please select at least one language.", comment: "In DoctorStartAc, detail for warning for at least select one language")
            let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            Alert.show(selectLanguage, message: selectLanguagedetail, ok: okstring, dismissBoth: false,vc: self)
        }else{
            //notification for update language in previous page
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DoctorAccountLanguageBack"), object: self, userInfo: nil )
            navigationController?.popViewController(animated: true)
        }
    }
    
    func checkPreviousLanguage(){
        var tempDoctorLanguage = signInDoctor!.doctorLanguage!
        while(tempDoctorLanguage != ""){
            var temp = ""
            if let decimalRange = tempDoctorLanguage.range(of: " ,"){
                temp = tempDoctorLanguage[tempDoctorLanguage.startIndex..<decimalRange.lowerBound]
                // it's possible there are two blank
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                tempDoctorLanguage.removeSubrange(tempDoctorLanguage.startIndex..<decimalRange.upperBound)
            }
            else if tempDoctorLanguage != ""{
                temp = tempDoctorLanguage
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                if let blank = temp.range(of: " "){
                    temp.remove(at: blank.lowerBound)
                }
                tempDoctorLanguage = ""
            }
            // write to languageStirng
            checked[Int(temp)!] = true
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
                var languageString = signInDoctor!.doctorLanguage!
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
                signInDoctor?.doctorLanguage! = languageString
            } else {
                //this part select a language
                cell.accessoryType = .checkmark
                checked[(indexPath as NSIndexPath).row] = true
                if signInDoctor!.doctorLanguage! != "" {
                    signInDoctor?.doctorLanguage! = signInDoctor!.doctorLanguage! + ", " + String((indexPath as NSIndexPath).row) + " "
                }else{
                    signInDoctor?.doctorLanguage! = " " + String((indexPath as NSIndexPath).row) + " "
                }
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
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
