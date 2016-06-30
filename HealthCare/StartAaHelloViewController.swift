//
//  StartAaHelloViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/23/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

// set a temporal Persons in memory
var signInUser: Persons?

class StartAaHelloViewController: UIViewController {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //setting delay one second for startup.
        //Initial environment in this MVC later in viewDidLoad
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            //if account is Users, go to to user Main MVC(Aa)
            //if account is Doctors, go to to doctor Main MVC(??)
            //if no account to go login page(StartAb)
           self.searchDefaultUserOrDoctor()
        }
    }
    
    func searchDefaultUserOrDoctor(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        let fetchRequestDoctor = NSFetchRequest(entityName: "Doctors")
        let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        do {
            //fetch a local user in HD
            let Personresults =  try managedContext.executeFetchRequest(fetchRequestPerson)
            let person = Personresults as! [NSManagedObject]
            //fetch a local doctor in HD
            let Doctorresults =  try managedContext.executeFetchRequest(fetchRequestDoctor)
            let doctor = Doctorresults as! [NSManagedObject]
            
            if person.count != 0{
                //if account is Persons, go to to user Main MVC(Aa)
                signInUser = person[0] as? Persons //make sure person[0] always can downcasting to Person
            }else if doctor.count != 0 {
                //if account is Doctors, go to to doctor Main MVC(??)
                signInUser = doctor[0] as! Doctors //make sure doctor[0] always can downcasting to Doctors
            }else {
                //if no account to go login page(StartAb)
                performSegueWithIdentifier("StartAb", sender: nil)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
