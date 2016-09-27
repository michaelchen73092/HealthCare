//
//  PersonsAaSearchDoctorTableViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 7/4/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class PersonsAeSearchDoctorTableViewController: UITableViewController {
        
    // MARK: - Variables
    fileprivate struct MVC{
        static let cellIdentifier = "doctors"
        static let nextIdentifier = "show doctor Details"
    }
    
    
//    func open(duration: NSTimeInterval){
//        UIView.animateWithDuration(duration,
//                                   delay: 0.0,
//                                   options: UIViewAnimationOptions.CurveEaseInOut,
//                                   animations: {
//                                    self.navigationController?.navigationBar.transform = CGAffineTransformMakeTranslation((self.navigationController?.navigationBar.frame.size.width)!, 0)},
//                                   completion: nil)
//    }
//    
//    func close(duration: NSTimeInterval){
//        UIView.animateWithDuration(duration,
//                                   delay: 0.0,
//                                   options: UIViewAnimationOptions.CurveEaseInOut,
//                                   animations: {
//                                    self.navigationController?.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0)},
//                                   completion: nil)
//    }
    
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
//    //set portrait view only
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.Portrait
//    }
//    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
    
    func refresh(){
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl?) {
        // no update for testing
        tableView.reloadData()
        sender?.endRefreshing()
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if onLineDoctor != nil{
            return onLineDoctor!.count
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 164
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MVC.cellIdentifier, for: indexPath) as! PersonsAfDoctorDetailTableViewCell
        if onLineDoctor != nil {
            cell.Doctor = onLineDoctor![(indexPath as NSIndexPath).row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let ag = destination as? PersonsAgDoctorDetailTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
            let cell = sender as! PersonsAfDoctorDetailTableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                ag.Doctor = onLineDoctor![(indexPath as NSIndexPath).row]
            }
        }

//            if identifier == MVC.nextIdentifier{
//                if let ag = segue.destinationViewController as? PersonsAgDoctorDetailTableViewController{
//                    let backItem = UIBarButtonItem()
//                    backItem.title = ""
//                    self.navigationItem.backBarButtonItem = backItem
//                    
//                    let cell = sender as! PersonsAfDoctorDetailTableViewCell
//                    if let indexPath = tableView.indexPathForCell(cell){
//                        ag.Doctor = onLineDoctor![indexPath.row]
//                    }
//                }
//            }
    }

}
