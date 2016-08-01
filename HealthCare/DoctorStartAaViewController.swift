//
//  DoctorStartAaViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/20/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

var tempDoctor: Doctors?
class DoctorStartAaViewController: UIViewController {

    @IBOutlet weak var welcomeDescription: UILabel!
    @IBOutlet weak var documentsDescription: UILabel!

    weak var DoctorsEntity : NSEntityDescription?
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeDescription.text = NSLocalizedString("Welcome to join Berbi as a licensed medical doctor. In this stage, we only accept for Taiwan licensed medical doctor. We will open other area soon, and sorry for any inconvenient.", comment: "In DoctorStartAaViewController, upper welcome description")
        documentsDescription.text = NSLocalizedString("Please prepare below at least two documents: \n1) Your Medical License \n2) Your ID card or your Medicine Diploma \n3) Medical Specialties License, if you have.", comment: "In DoctorStartAaViewController, lower prepare document description")
        // initialized tempDoctor
        DoctorsEntity = NSEntityDescription.entityForName("Doctors", inManagedObjectContext: moc)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        if tempDoctor != nil{
            tempDoctor = nil
        }
        dismissViewControllerAnimated(true) {}
    }

    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ab = segue.destinationViewController as? DoctorStartAbLanguageTableViewController{
            //pass current moc to next controller which use for create Persons object
            tempDoctor = Doctors(entity: DoctorsEntity!, insertIntoManagedObjectContext: moc)
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ab.moc = self.moc
        }
    }
}
