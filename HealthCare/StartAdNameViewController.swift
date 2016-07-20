//
//  StartAdNameViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/27/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

class StartAdNameViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Variables
    @IBOutlet weak var firstnameField: UITextField! { didSet{ firstnameField.delegate = self}}
    @IBOutlet weak var lastnameField: UITextField! { didSet{ lastnameField.delegate = self}}
    @IBOutlet weak var invalidName: UILabel!
    
    private struct MVC {
        static let nextIdentifier = "StartAe"
        static let lastIdentifier = "StartAc"
    }
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
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
        //disable autocorrection
        invalidName.hidden = true
        firstnameField.autocorrectionType = .No
        lastnameField.autocorrectionType = .No
        //show textField if it's set
        firstnameField.text = signInUser?.firstname
        lastnameField.text = signInUser?.lastname
    }
    
    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(firstnameField, textField2: lastnameField, vc: self)
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
        invalidName.hidden = true
        if firstnameField.text == "" {
            //wiggle if there is no data
            wiggle(firstnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if lastnameField.text == "" {
            //wiggle if there is no data
            wiggle(lastnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if validateName(firstnameField.text!) || validateName(lastnameField.text!) {
            invalidName.hidden = false
        }else{
            //Go to next page
            signInUser?.firstname = firstnameField.text
            signInUser?.lastname = lastnameField.text
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
        invalidName.hidden = true
        if validateName(textField.text!) {
            invalidName.hidden = false
        }else{
            checkForNextPage()
        }
        textField.resignFirstResponder()
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
