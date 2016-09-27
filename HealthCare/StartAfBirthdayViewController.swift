//
//  StartAfBirthdayViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/27/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData

class StartAfBirthdayViewController: UIViewController{

    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var invalidBirthday: UILabel!
    let dateFormatter = DateFormatter()
    fileprivate struct MVC {
        static let nextIdentifier = "StartAg"
        static let lastIdentifier = "StartAe"
        static var birthdaySet = false
    }
    weak var moc : NSManagedObjectContext?
    
    
    // MARK: - Viewcontroller Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        //add datePicker event
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), for: UIControlEvents.valueChanged)
        //add swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    fileprivate func updateUI(){
        invalidBirthday.isHidden = true
        //not allow to edit
        birthdayField.isUserInteractionEnabled = false
        //set datePicker 
        datePicker?.maximumDate = Date()
        // set dateFormate
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        if MVC.birthdaySet {
            birthdayField.text = dateFormatter.string(from: (signInUserPublic?.birthday)!)
        }else {
            birthdayField.text = dateFormatter.string(from: Date())
        }
    }
    
    func datePickerChanged(_ datePicker:UIDatePicker) {
        MVC.birthdaySet = true
        //use string formate to store NSdate for signInUser?.birthday
        dateFormatter.dateFormat = "MM-dd-yyyy"
        signInUserPublic?.birthday = Date(dateString: dateFormatter.string(from: datePicker.date))
        // this formate is localized formate already
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        let strDate = dateFormatter.string(from: datePicker.date)
        birthdayField.text = strDate
        
    }
    
    // MARK: - Continue func
    @IBAction func Continue() {
        invalidBirthday.isHidden = true
        if birthdayField.text == dateFormatter.string(from: Date()){
            invalidBirthday.isHidden = false
        }else{
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }
    }
    
    
    
    // MARK: - gesture
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                performSegue(withIdentifier: MVC.lastIdentifier, sender: nil)
            default:
                break
            }
        }
    }
    
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ag = segue.destination as? StartAgGenderViewController{
            //pass current moc to next controller which use for create Persons object
            ag.moc = self.moc
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
// MARK: - NSDate Extension
// extension NSDate to init from String formate
extension Date
{
    
    init(dateString:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let d = dateFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
}

