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
    
    fileprivate struct MVC {
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
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    fileprivate func updateUI(){
        //label setting
        invalidPassword.isHidden = true
        //disable autocorrection
        passwordField.autocorrectionType = .no
        //show textField if it's set
        passwordField.text = signInUser?.password
        
    }

    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(passwordField, textField2: nil, vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KBNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func KBNotification(){
        //set notification for keyboard appear and hide
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Continue func
    
    @IBAction func Continue() {
        checkForNextPage()
    }
    
    fileprivate func checkForNextPage(){
        invalidPassword.isHidden = true
        if passwordField.text == "" {
            //wiggle if there is no data
            wiggle(passwordField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if !validatePassword(passwordField.text!){
            invalidPassword.isHidden = false
            wiggle(passwordField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            signInUser?.password = passwordField.text
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(_ notification: Notification) {
        if !Storyboard.KBisON { //if NO KB, view move up
            self.view.frame.origin.y -= Storyboard.moveheight
            Storyboard.KBisON = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if Storyboard.KBisON {
            self.view.frame.origin.y += Storyboard.moveheight
            Storyboard.KBisON = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        checkForNextPage()
        return true
    }
    
    // MARK: - gesture
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                tappedView()
                performSegue(withIdentifier: MVC.lastIdentifier, sender: nil)
            default:
                break
            }
        }
    }
    
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let af = segue.destination as? StartAfBirthdayViewController{
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
