//
//  StartAePasswordViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/27/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData

class StartAePasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    
    @IBOutlet weak var passwordField: UITextField!  { didSet{ passwordField.delegate = self}}
    @IBOutlet weak var invalidPassword: UILabel!
    
    private struct MVC {
        static let nextIdentifier = "StartAf"
        static let lastIdentifier = "StartAd"
    }
    weak var moc : NSManagedObjectContext?
    let tapRec = UITapGestureRecognizer()
    
    // MARK: - Viewcontroller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        Storyboard.KBisON = false
        
        //tap gesture setting
        tapRec.addTarget(self, action: #selector(self.tappedView))
        self.view.addGestureRecognizer(tapRec)
        
        //swipe left gesture setting
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    private func updateUI(){
        //label setting
        invalidPassword.hidden = true
        //disable autocorrection
        passwordField.autocorrectionType = .No
        //show textField if it's set
        passwordField.text = signInUser?.password
        
    }

    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(passwordField, textField2: nil, vc: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        KBNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func KBNotification(){
        //set notification for keyboard appear and hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - Continue func
    
    @IBAction func Continue() {
        checkForNextPage()
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
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if !Storyboard.KBisON { //if NO KB, view move up
            self.view.frame.origin.y -= Storyboard.moveheight
            Storyboard.KBisON = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if Storyboard.KBisON {
            self.view.frame.origin.y += Storyboard.moveheight
            Storyboard.KBisON = false
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
                tappedView()
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
