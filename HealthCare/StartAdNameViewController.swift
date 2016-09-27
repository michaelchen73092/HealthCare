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
    
    fileprivate struct MVC {
        static let nextIdentifier = "StartAe"
        static let lastIdentifier = "StartAc"
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
        //disable autocorrection
        invalidName.isHidden = true
        firstnameField.autocorrectionType = .no
        lastnameField.autocorrectionType = .no
        //show textField if it's set
        firstnameField.text = signInUserPublic?.firstname
        lastnameField.text = signInUserPublic?.lastname
    }
    
    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(firstnameField, textField2: lastnameField, vc: self)
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
        invalidName.isHidden = true
        if firstnameField.text == "" {
            //wiggle if there is no data
            wiggle(firstnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if lastnameField.text == "" {
            //wiggle if there is no data
            wiggle(lastnameField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if validateName(firstnameField.text!) || validateName(lastnameField.text!) {
            invalidName.isHidden = false
        }else{
            //Go to next page
            signInUserPublic?.firstname = firstnameField.text
            signInUserPublic?.lastname = lastnameField.text
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
        invalidName.isHidden = true
        if validateName(textField.text!) {
            invalidName.isHidden = false
        }else{
            checkForNextPage()
        }
        textField.resignFirstResponder()
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
        if let ae = segue.destination as? StartAePasswordViewController{
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
