//
//  DoctorAbOnlineWaitlistTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/9/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit
import CoreData

class DoctorAbOnlineWaitlistTableViewController: UITableViewController , UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorImageView: UIImageView!
    
    //description follow top to down order
    @IBOutlet weak var doctorSpecialty: UILabel!
    @IBOutlet weak var doctorGraduateSchool: UILabel!
    @IBOutlet weak var doctorCurrentHospital: UILabel!
    @IBOutlet weak var doctorLanguage: UILabel!
    //right board certificated image
    @IBOutlet weak var doctorIsBoardCertificated: UIImageView!
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var onlineSwitch: UISwitch!
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    weak var PersonsPublicEntity : NSEntityDescription?
    var waitlist = [PersonsPublic]()
    
//    @IBOutlet weak var timerForTwentyMinutes: UILabel!
//    var timer = NSTimer()
//    var now = NSDate()
    
    private struct MVC{
        static let cellIdentifier = "Patient"
    }
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation title
        doctorUpdateUI(doctorNameLabel, doctorGraduateSchool: doctorGraduateSchool,doctorCurrentHospital: doctorCurrentHospital,doctorLanguage: doctorLanguage, doctorSpecialty: doctorSpecialty, doctorImageView:doctorImageView, doctorIsBoardCertificated: doctorIsBoardCertificated, doctor:signInDoctor, starA: starOne, starB: starTwo, starC: starThree, starD: starFour, starE: starFive)
        self.navigationItem.title = doctorNameLabel.text
        onlineLabel.text = Storyboard.onLine
        PersonsPublicEntity = NSEntityDescription.entityForName("PersonsPublic", inManagedObjectContext: moc)
        refresh()
        
        //timer
//        
//        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
//            target: self,
//            selector: #selector(self.tick),
//            userInfo: nil,
//            repeats: true)
    }
    
//    func tick() {
//        
//        let calendar : NSCalendar = NSCalendar.currentCalendar()
//        let secondComponents = calendar.components(.Second,
//                                                fromDate: now,
//                                                toDate: NSDate(),
//                                                options: [])
//        let minutes = NSLocalizedString("Minutes", comment: "In DoctorAbOnlineWaitlist, for timer minutes.")
//        let seconds = NSLocalizedString("Seconds", comment: "In DoctorAbOnlineWaitlist, for timer seconds.")
//        let minutesInt = (secondComponents.second % 3600) / 60
//        let secondInt =  (secondComponents.second % 3600) % 60
//        timerForTwentyMinutes.text = "\(minutesInt) "+minutes+" \(secondInt) "+seconds
//    }

    func refresh(){
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        waitlist = fetchWaitlist()!
        if waitlist.count > 0{
            let tempCount = waitlist.count
            if tempCount < generalReservation.quota!{
                let blankperson = PersonsPublic(entity: PersonsPublicEntity!, insertIntoManagedObjectContext: moc)
                for _ in tempCount...(generalReservation.quota! - 1){
                    blankperson.firstname = ""
                    blankperson.lastname = ""
                    waitlist.insert(blankperson, atIndex: waitlist.count)
                }
            }
        }
        tableView.reloadData()
        sender?.endRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onOffSwitch(sender: UISwitch) {
        let offlineTitle = NSLocalizedString("Turn to Offline", comment: "In DoctorAbOnlineWaitlist, title for alert to change offline.")
        let offlinemessage = NSLocalizedString("System will stop arranging new appointment for you. You will turn into offline and user can't search you immediately.", comment: "In DoctorAbOnlineWaitlist, message for alert to change offline.")
        let onlineTitle = NSLocalizedString("Turn to Online", comment: "In DoctorAbOnlineWaitlist, title for alert to change online.")
        let onlinemessage = NSLocalizedString("System will start to arrange new appointments for you. You will turn into online and be searchable immediately if there is a vacancy on your waitlist.", comment: "In DoctorAbOnlineWaitlist, message for alert to change online.")
        
        if !onlineSwitch.on {
            onlineLabel.textColor = UIColor(netHex: 0x42D451)
            onlineLabel.text = Storyboard.onLine
            onlineSwitch.setOn(true, animated: true)
            alertForOnOffLine(offlineTitle, message: offlinemessage, onOffLine: true)
        }else{
            onlineLabel.textColor = UIColor.lightGrayColor()
            onlineLabel.text = Storyboard.offLine
            onlineSwitch.setOn(false, animated: true)
            alertForOnOffLine(onlineTitle, message: onlinemessage, onOffLine: false)
        }
    }
    
    
    func alertForOnOffLine(title:String, message: String, onOffLine: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: Storyboard.ConfirmAlert, style: .Default, handler: { [weak self] (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
            if onOffLine {
                self!.onlineLabel.textColor = UIColor.lightGrayColor()
                self!.onlineLabel.text = Storyboard.offLine
                self!.onlineSwitch.setOn(false, animated: true)
            }else{
                self!.onlineLabel.textColor = UIColor(netHex: 0x42D451)
                self!.onlineLabel.text = Storyboard.onLine
                self!.onlineSwitch.setOn(true, animated: true)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: Storyboard.CancelAlert, style: .Cancel, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return generalReservation.quota!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MVC.cellIdentifier, forIndexPath: indexPath) as! DoctorAbPatientTableViewCell
        cell.personspublic = waitlist[indexPath.row]
        cell.waitlistNumber = indexPath.row
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    @IBAction func tapEndSession(sender: UIBarButtonItem) {
        let endSessionsafeTitle = NSLocalizedString("End Session", comment: "In DoctorAbOnlineWaitlist, title for alert to end session safe.")
        let endSessionsafeDetail = NSLocalizedString("Congratulations! You have completed this section's jobs. Please tap confirm to leave.", comment: "In DoctorAbOnlineWaitlist, title for alert to end session safe.")
        
        let endSessionsNoSafeTitle = NSLocalizedString("Patients Left!", comment: "In DoctorAbOnlineWaitlist, title for alert to end session not safe.")
        let endSessionNoSafeDetail = NSLocalizedString("You still have patients on your wait list! If you still confirm to leave, those patients have permission to leave comment on you!", comment: "In DoctorAbOnlineWaitlist, title for alert to end session not safe.")
        var alert : UIAlertController?
        // tell whether there is patient
        var hasPatient = false
        if waitlist.count > 0 {
            for i in 0...(waitlist.count - 1){
                if waitlist[i].firstname != "" || waitlist[i].lastname != "" {
                    hasPatient = true
                }
            }
        }
        
        //need to find true number of waitlist
        if hasPatient{
            alert = UIAlertController(title: endSessionsNoSafeTitle, message: endSessionNoSafeDetail, preferredStyle: UIAlertControllerStyle.Alert)
        }else{
            alert = UIAlertController(title: endSessionsafeTitle, message: endSessionsafeDetail, preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        alert!.addAction(UIAlertAction(title: Storyboard.ConfirmAlert, style: .Default, handler: { [weak self] (action: UIAlertAction!) in
            alert!.dismissViewControllerAnimated(true, completion: nil)
            self!.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert!.addAction(UIAlertAction(title: Storyboard.CancelAlert, style: .Cancel, handler: { (action: UIAlertAction!) in
            alert!.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        presentViewController(alert!, animated: true, completion: nil)
    }
    
    //temp for update data
    private func fetchWaitlist() -> [PersonsPublic]? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var testAll = [PersonsPublic]()
        let testOne = PersonsPublic(entity: PersonsPublicEntity!, insertIntoManagedObjectContext: moc)
        testOne.firstname = "Wei-Chih"
        testOne.lastname = "Chen"
        testOne.birthday = NSDate(dateString: "09-24-1984")
        testOne.email = "a@g.com"
        testOne.height = 174.0
        testOne.weight = 60.0
        testOne.ethnicity = "1"
        testOne.gender = false
        testOne.imageRemoteUrl = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c427.3.533.533/s160x160/1231546_10152098475632345_1368421124_n.jpg?oh=54089e8c829f9f933f9eb155b7a736e1&oe=581C6EF9"
        // insert at 0 , fetch at end
        testAll.insert(testOne, atIndex: testAll.count)
        let testTwo = PersonsPublic(entity: PersonsPublicEntity!, insertIntoManagedObjectContext: moc)
        testTwo.firstname = "Chien-Lin"
        testTwo.lastname = "Chen"
        testTwo.birthday = NSDate(dateString: "05-13-1985")
        testTwo.email = "a@g.com"
        testTwo.height = 164.0
        testTwo.weight = 68.0
        testTwo.ethnicity = "1"
        testTwo.gender = false
        testTwo.imageRemoteUrl = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c40.0.160.160/p160x160/10154886_694303240612155_803087744422793784_n.jpg?oh=0fb1336f496fb96cb6bacbc1bfcad672&oe=581AB0C6"
        testAll.insert(testTwo, atIndex: testAll.count)
        return testAll
    }
    

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pop = segue.destinationViewController as? DoctorAcInfoPopoverViewController{
            if let ppc = pop.popoverPresentationController{
                ppc.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

}
