//
//  DoctorStartAeSearchSchoolTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/22/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit

class DoctorStartAeSearchSchoolTableViewController: UITableViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        //recall previous select
        if tempDoctor?.doctorGraduateSchool != nil {
            if tempDoctor!.doctorGraduateSchool != nil{
                lastSelectedRow = IndexPath(row: Int(tempDoctor!.doctorGraduateSchool!)!, section: 0)
            }
        }
        
        //setup navigation
        let graudateSchoolTitle = NSLocalizedString("Graudated School", comment: "In DoctorStartAbLanguage's title")
        self.navigationItem.title = graudateSchoolTitle
        let backNavigationButton = UIBarButtonItem(title: Storyboard.backNavigationItemLeftButton , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem = backNavigationButton
    }

    func backButtonClicked(){
        print("backButtonClicked()")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "graduateSchoolBack"), object: self, userInfo: nil )
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
        return School.school.count
    }

    var lastSelectedRow: IndexPath?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //for show previous record
        cell.accessoryType = ((lastSelectedRow as NSIndexPath?)?.row == (indexPath as NSIndexPath).row) ? .checkmark : .none
        
        cell.textLabel?.text = School.school[(indexPath as NSIndexPath).row][0]
        cell.detailTextLabel?.text = School.school[(indexPath as NSIndexPath).row][1]
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).row != (lastSelectedRow as NSIndexPath?)?.row {
            if let last = lastSelectedRow {
                let oldCell = tableView.cellForRow(at: last)
                oldCell?.accessoryType = .none
            }
            
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            lastSelectedRow = indexPath
            tempDoctor?.doctorGraduateSchool = String((indexPath as NSIndexPath).row)
            print("tempDoctor?.doctorGraduateSchool:\(tempDoctor!.doctorGraduateSchool!)")
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
