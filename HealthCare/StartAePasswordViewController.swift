//
//  StartAePasswordViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/27/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit

class StartAePasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    
    @IBOutlet weak var passwordField: UITextField!  { didSet{ passwordField.delegate = self}}
    @IBOutlet weak var invalidPassword: UILabel!
    
    private struct MVC {
        static let nextIdentifier = "StartAf"
        static let lastIdentifier = "StartAd"
        static var KBisON = false // set for recording KB is ON/OFF
        static var secure: Bool = true
    }
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Viewcontroller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        //set notification for keyboard appear and hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //swipe left gesture setting
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    private func updateUI(){
        //label setting
        passwordField.clearsOnBeginEditing = true
        passwordField.secureTextEntry = MVC.secure
        invalidPassword.hidden = true
        //disable autocorrection
        passwordField.autocorrectionType = .No
        //show textField if it's set
        passwordField.text = signInUser?.password
        
    }

    private func checkForNextPage(){
        invalidPassword.hidden = true
        if passwordField.text == "" {
            //wiggle if there is no data
            wiggle(passwordField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if !validatePassword(passwordField.text!){
            invalidPassword.hidden = false
            wiggle(passwordField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            signInUser?.password = passwordField.text
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
    }
    
    // MARK: - Continue func
    
    @IBAction func Continue() {
        checkForNextPage()
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
        checkForNextPage()
        return true
    }
    
    // MARK: - gesture
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                performSegueWithIdentifier(MVC.lastIdentifier, sender: nil)
            default:
                break
            }
        }
    }
    
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let af = segue.destinationViewController as? StartAfBirthdayViewController{
            //pass current moc to next controller which use for create Persons object
            af.moc = self.moc
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
