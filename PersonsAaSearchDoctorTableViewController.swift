//
//  PersonsAaSearchDoctorTableViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 7/4/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class PersonsAaSearchDoctorTableViewController: UITableViewController {
    
    
    @IBAction func filterButton(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName("filterButtonTap", object: self, userInfo: nil)
        }

    @IBOutlet weak var filterView: UIView!
    
//    func setpanGesture(){
//        let gesture = UIPanGestureRecognizer()
//        addGestureRecognizer(gesture)
//        let translation = gesture.translationInView(self.view)
//        let naviBarheight = (self.navigationController?.navigationBar.frame.size.height)!
//        switch gesture.state{
//        case .Ended:
//            if (self.navigationController?.navigationBar.frame.origin.y < -(naviBarheight / 2)){
//                close(0.1)
//            }else{
//                open(0.1)
//            }
//        case .Changed:
//            if (translation.y < -(naviBarheight / 2) ) && (self.navigationController?.navigationBar.frame.origin.y > -naviBarheight) {
//                self.navigationController?.navigationBar.transform = CGAffineTransformMakeTranslation(translation.y, 0)
//            }
//            print("translation.y: \(translation.y)")
//            print("naviBarheight: \(naviBarheight)")
//        default: break
//        }
//    }
    
    
    func open(duration: NSTimeInterval){
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.navigationController?.navigationBar.transform = CGAffineTransformMakeTranslation((self.navigationController?.navigationBar.frame.size.width)!, 0)},
                                   completion: nil)
    }
    
    func close(duration: NSTimeInterval){
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    self.navigationController?.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0)},
                                   completion: nil)
    }
    
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    //set portrait view only
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let naviheight = (self.navigationController?.navigationBar.frame.size.height)!
        filterView.transform = CGAffineTransformMakeTranslation(0, naviheight + scrollView.contentOffset.y)
        scrollView.bringSubviewToFront(filterView)
        print("scrollView.contentOffset.y: \(scrollView.contentOffset.y)")
        print("ffilterView.frame.origin.y: \(filterView.frame.origin.y)")
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
