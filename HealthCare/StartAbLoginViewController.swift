//
//  StartAbLoginViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/23/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

class StartAbLoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var invelidLabel: UILabel!
    @IBOutlet weak var emailField: UITextField! { didSet{ emailField.delegate = self}}
    @IBOutlet weak var passwordField: UITextField! { didSet{ passwordField.delegate = self}}
    private struct MVC {
        static let nextIdentifier = "StartAc"
        static var KBisON = false // set for recording KB is ON/OFF
        static var secure: Bool = true
    }
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        //set notification for keyboard appear and hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    private func updateUI(){
        //label setting
        emailField.clearsOnBeginEditing = true
        passwordField.secureTextEntry = MVC.secure
        passwordField.clearsOnBeginEditing = true
        invelidLabel.hidden = true
        
        //disable autocorrection
        emailField.autocorrectionType = .No
        passwordField.autocorrectionType = .No
    }
    
    // MARK: - login or signup
    @IBAction func login() {
        invelidLabel.hidden = true
        if emailField.text == "" {
            //wiggle if there is no data
            wiggle(emailField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }
        else if passwordField.text == "" {
            //wiggle if there is no data
            wiggle(passwordField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }
        else if !validateEmail(emailField.text!){
            invelidLabel.hidden = false
            wiggle(emailField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
        else {
            //querry Doctor account on AWS if no data
            //querry Persons account on AWS
            //if success
            if signInUser != nil {
                //go to User page if signInUser is Persons type
                //else go to Doctors page
                
            }
            else{
                //alert that there is no this user
                let invalidemail = NSLocalizedString("Invalid Email", comment: "Title for no email record found")
                let invalidemaildetail = NSLocalizedString("The email you entered doesn't appear to belong to an account. Please check your email address and try again.", comment: "Detail for no email record found")
                let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
                Alert.show(invalidemail, message: invalidemaildetail, ok: okstring,vc: self)
            }//end else
        }//end all else
    }//end login
    
    @IBAction func signup() {
        //initialize signInUser by moc
        let PersonsEntity = NSEntityDescription.entityForName("Persons", inManagedObjectContext: moc)
        signInUser = Persons(entity: PersonsEntity!, insertIntoManagedObjectContext: moc)
        performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if !MVC.KBisON { //if NO KB, view move up
            self.view.frame.origin.y -= Storyboard.moveheight
            MVC.KBisON = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if MVC.KBisON {
            self.view.frame.origin.y += Storyboard.moveheight
            MVC.KBisON = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ac = segue.destinationViewController as? StartAcEmailViewController{
            //pass current moc to next controller which use for create Persons object
            ac.moc = self.moc
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
