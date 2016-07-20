//
//  PersonsCdEthnicityTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/18/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class PersonsCdEthnicityTableViewController: UITableViewController {

    var ethnicity = ["African American", "Chinese", "East African", "East Asian", "Fijian", "Hispanic or Latin American", "Indian", "Maori", "Middle Eastern", "NZ European or Pakeha", "Native American or Inuit", "Native Hawaiian", "Niuean", "Other", "Other Pacific Peoples", "Samoan", "South Asian", "South East Asian", "Tokelauan", "Tongan", "White or Caucasian"]
    var checked = [Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...20 {
            checked.append(false)
        }
        //title for Ethnicity
        let ethnicityTitle = NSLocalizedString("Ethnicity", comment: "In PersonsCd's title")
        self.navigationItem.title = ethnicityTitle
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
        return ethnicity.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = ethnicity[indexPath.row]

        if ((signInUser!.ethnicity?.rangeOfString(ethnicity[indexPath.row])) != nil){
            cell.accessoryType = .Checkmark
            checked[indexPath.row] = true
        }
        
        
//        // set uncheck for non-selected
//        if !checked[indexPath.row] {
//            cell.accessoryType = .None
//        } else if checked[indexPath.row] {
//            cell.accessoryType = .Checkmark
//        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
                var ethnicityString = signInUser!.ethnicity!
                
                //remove 3) ethnicity in last (if it is last selected ethnicity remove)
                if let range = ethnicityString.rangeOfString(", " + ethnicity[indexPath.row]){
                        ethnicityString.removeRange(range.startIndex..<range.endIndex)
                }
                
                //remove unCheckmark from ethnicityString String
                if let range = ethnicityString.rangeOfString(ethnicity[indexPath.row]){
                    ethnicityString.removeRange(range.startIndex..<range.endIndex)
                }
                
                //remove three possible: 1) ", " at first index which delete first ethnicity
                if let range = ethnicityString.rangeOfString(", ") {
                    if range.startIndex == ethnicityString.startIndex{
                        ethnicityString.removeRange(range.startIndex..<range.endIndex)
                    }
                }
   
                signInUser?.ethnicity = ethnicityString
            } else {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
                if signInUser!.ethnicity! != "" {
                    signInUser?.ethnicity = signInUser!.ethnicity! + ", " + ethnicity[indexPath.row]
                }else{
                    signInUser?.ethnicity = ethnicity[indexPath.row]
                }
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
