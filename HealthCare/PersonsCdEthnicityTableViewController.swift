//
//  PersonsCdEthnicityTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/18/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class PersonsCdEthnicityTableViewController: UITableViewController {

    var checked = [Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...(Ethnicity.ethnicity.count - 1) {
            checked.append(false)
        }
        //title for Ethnicity
        let ethnicityTitle = NSLocalizedString("Ethnicity", comment: "In PersonsCd's title")
        self.navigationItem.title = ethnicityTitle
        let backNavigationButton = UIBarButtonItem(title: Storyboard.backNavigationItemLeftButton , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem = backNavigationButton
    }
    
    func backButtonClicked(){
        print("backButtonClicked()")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ethnicityBack"), object: self, userInfo: nil )
        navigationController?.popViewController(animated: true)
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
        return Ethnicity.ethnicity.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Ethnicity.ethnicity[(indexPath as NSIndexPath).row]

        if ((signInUserPublic!.ethnicity!.range(of: " " + String((indexPath as NSIndexPath).row) + " ")) != nil){
            cell.accessoryType = .checkmark
            checked[(indexPath as NSIndexPath).row] = true
        }
        
        
        // set uncheck for non-selected
        if checked[(indexPath as NSIndexPath).row] == false{
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[(indexPath as NSIndexPath).row] = false
                var ethnicityString = signInUserPublic!.ethnicity!
                // use ", " and " " to closure a number
                //this part is remove exist language
                //remove 3) in last or between (if it is last selected language remove)
                if let range = ethnicityString.range(of: ", " + String((indexPath as NSIndexPath).row) + " "){
                    ethnicityString.removeSubrange(range.lowerBound..<range.upperBound)
                }
                
                //remove unCheckmark from in first
                if let range = ethnicityString.range(of: " " + String((indexPath as NSIndexPath).row) + " "){
                    ethnicityString.removeSubrange(range.lowerBound..<range.upperBound)
                }
                
                //remove  ", " at first index which delete first language
                if let range = ethnicityString.range(of: ",") {
                    if range.lowerBound == ethnicityString.startIndex{
                        ethnicityString.removeSubrange(range.lowerBound..<range.upperBound)
                    }
                }
                signInUserPublic?.ethnicity = ethnicityString
            } else {
                //this part select a language
                cell.accessoryType = .checkmark
                checked[(indexPath as NSIndexPath).row] = true
                if signInUserPublic!.ethnicity! != "" {
                    signInUserPublic?.ethnicity = signInUserPublic!.ethnicity! + ", " + String((indexPath as NSIndexPath).row) + " "
                }else{
                    signInUserPublic?.ethnicity = " " + String((indexPath as NSIndexPath).row) + " "
                }
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
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
