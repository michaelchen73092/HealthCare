//
//  StartAgGenderViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/29/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

class StartAgGenderViewController: UIViewController{
    
    // MARK: - Variables
    var ButtonSelect = false

    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var maleButtonLabel: UIButton!
    @IBOutlet weak var femaleButtonLabel: UIButton!

    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var maleView: UIView!
    
    // MARK: - Viewcontroller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup male and female view
        maleView.layer.borderWidth = 1.0
        maleView.layer.borderColor = Storyboard.color.CGColor
        
        femaleView.layer.borderWidth = 1.0
        femaleView.layer.borderColor = Storyboard.color.CGColor
    }
    
    // MARK: - Male, Female function
    @IBAction func maleButton() {
        ButtonSelect = true
        signInUser?.gender = "Male"
        // set button color when it's clicked
        buttonHighlight(maleButtonLabel, View: maleView)
        buttonDehighlight(femaleButtonLabel, View: femaleView)
        //save user info to local CoreDate
        saveLocal()
        performSegueWithIdentifier("MainPersons", sender: nil)
    }
    
    
    @IBAction func femaleButton() {
        ButtonSelect = true
        signInUser?.gender = "Female"
        // set button color when it's clicked
        buttonHighlight(femaleButtonLabel, View: femaleView)
        buttonDehighlight(maleButtonLabel, View: maleView)
        //save user info to local CoreDate
        saveLocal()
        performSegueWithIdentifier("MainPersons", sender: nil)
    }
    
    private func buttonHighlight(Button: UIButton!, View: UIView!){
        Button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        Button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        View.backgroundColor = UIColor(netHex: 0x003366)
    }

    private func buttonDehighlight(Button: UIButton!, View: UIView!){
        Button.setTitleColor(UIColor(netHex: 0x003366), forState: UIControlState.Normal)
        View.backgroundColor = UIColor(netHex: 0xD7DCE4)
    }
    

    
    //save to local CoreData
    private func saveLocal(){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let ed = NSEntityDescription.entityForName("Persons", inManagedObjectContext: moc)
        let person = Persons(entity: ed!, insertIntoManagedObjectContext: moc)
        person.firstname = signInUser?.firstname
        person.lastname = signInUser?.lastname
        person.email = signInUser?.email
        person.password = signInUser?.password
        person.birthday = NSDate(dateString: dateFormatter.stringFromDate((signInUser?.birthday)!))
        person.gender = signInUser?.gender
        do{
         try moc.save()
            //alert that there is no this user
            //let success = NSLocalizedString("Success", comment: "Title for success open an account")
            //let details = NSLocalizedString("Your Account is creaded", comment: "detail of Success")
            //let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            //Alert.show(success, message: details, ok: okstring,vc: self)
        } catch _ as NSError
        {
            //alert that there is no this user
            let fail = NSLocalizedString("Fail", comment: "Title for fail open an account")
            let details = NSLocalizedString("Your Account is NOT created", comment: "detail of fail")
            let okstring = NSLocalizedString("back", comment: "Confrim for exit alert")
            Alert.show(fail, message: details, ok: okstring,vc: self)
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
