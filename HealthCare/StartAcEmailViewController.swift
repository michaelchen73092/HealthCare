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
    fileprivate struct MVC {
        static let nextIdentifier = "StartAd"
        static let lastIdentifier = "StartAb"
        //static var KBisON = false // set for recording KB is ON/OFF
    }
    weak var moc : NSManagedObjectContext?
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
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    fileprivate func updateUI(){
        //label setting
        invalidEmail.isHidden = true
        
        //disable autocorrection
        emailField.autocorrectionType = .no
        
        //show email if it's set
        emailField.text = signInUser?.email
    }
    //3
    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(emailField, textField2: nil, vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KBNotification()
    }
    
    var etshow: NSObjectProtocol?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func KBNotification(){
        //set notification for keyboard appear and hide
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    /////////3
    // MARK: - Continue func
    @IBAction func Continue() {
        checkForNextPage()
    }
    
    fileprivate func checkForNextPage(){
        invalidEmail.isHidden = true
        if emailField.text == "" {
            //wiggle if there is no data
            wiggle(emailField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }else if !validateEmail(emailField.text!){
            invalidEmail.isHidden = false
            wiggle(emailField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }else{
            signInUser?.email = emailField.text
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }
    }
    //4
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
    /////////4

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
                //5
                tappedView()
                performSegue(withIdentifier: MVC.lastIdentifier, sender: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination as UIViewController
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
