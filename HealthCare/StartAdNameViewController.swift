//
//  StartAdNameViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/27/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import PersonsKit

class StartAdNameViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    @IBOutlet weak var firstnameField: UITextField! { didSet{ firstnameField.delegate = self}}
    @IBOutlet weak var lastnameField: UITextField! { didSet{ lastnameField.delegate = self}}
    private struct MVC {
        static let nextIdentifier = "StartAe"
        static let lastIdentifier = "StartAc"
        static var KBisON = false // set for recording KB is ON/OFF
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
        firstnameField.clearsOnBeginEditing = true
        lastnameField.clearsOnBeginEditing = true
        //disable autocorrection
        firstnameField.autocorrectionType = .No
        lastnameField.autocorrectionType = .No
        //show textField if it's set
        firstnameField.text = signInUser?.firstname
        lastnameField.text = signInUser?.lastname
    }
    
    // MARK: - Continue func
    @IBAction func Continue() {
        checkForNextPage()
    }
    
    private func checkForNextPage(){
        if firstnameField.text == "" {
            //wiggle if there is no data
            wiggle(firstnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if lastnameField.text == "" {
            //wiggle if there is no data
            wiggle(lastnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else{
            //Go to next page
            signInUser?.firstname = firstnameField.text
            signInUser?.lastname = lastnameField.text
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
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
        if let ae = segue.destinationViewController as? StartAePasswordViewController{
            //pass current moc to next controller which use for create Persons object
            ae.moc = self.moc
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
