//
//  StartAcEmailViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/26/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

class StartAcEmailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var invalidEmail: UILabel!
    @IBOutlet weak var emailField: UITextField! { didSet{ emailField.delegate = self}}
    private struct MVC {
        static let nextIdentifier = "StartAd"
        static let lastIdentifier = "StartAb"
        //static var KBisON = false // set for recording KB is ON/OFF
    }
    var moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    //1
    let tapRec = UITapGestureRecognizer()
    
    // MARK: - Viewcontroller Cycle
    override func viewDidLoad() {
        //initialize
        super.viewDidLoad()
        updateUI()
        //2
        Storyboard.KBisON = false
        
        //tap gesture setting
        tapRec.addTarget(self, action: #selector(self.tappedView))
        self.view.addGestureRecognizer(tapRec)
        
        //swipe right gesture setting
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    private func updateUI(){
        //label setting
        invalidEmail.hidden = true
        
        //disable autocorrection
        emailField.autocorrectionType = .No
        
        //show email if it's set
        emailField.text = signInUser?.email
    }
    //3
    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(emailField, textField2: nil, vc: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        KBNotification()
    }
    
    var etshow: NSObjectProtocol?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func KBNotification(){
        //set notification for keyboard appear and hide
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    /////////3
    // MARK: - Continue func
    @IBAction func Continue() {
        checkForNextPage()
    }
    
    private func checkForNextPage(){
        invalidEmail.hidden = true
        if emailField.text == "" {
            //wiggle if there is no data
            wiggle(emailField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if !validateEmail(emailField.text!){
            invalidEmail.hidden = false
            wiggle(emailField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            signInUser?.email = emailField.text
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
    }
    //4
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
    /////////4

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
                //5
                tappedView()
                performSegueWithIdentifier(MVC.lastIdentifier, sender: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - prepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let ad = destination as? StartAdNameViewController{
            //pass current moc to next controller which use for create Persons object
            ad.moc = self.moc
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
