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
    let dateFormatter = NSDateFormatter()
    private struct MVC {
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
        datePicker.addTarget(self, action: #selector(self.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        //add swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    private func updateUI(){
        invalidBirthday.hidden = true
        //not allow to edit
        birthdayField.userInteractionEnabled = false
        //set datePicker 
        datePicker?.maximumDate = NSDate()
        // set dateFormate
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        if MVC.birthdaySet {
            birthdayField.text = dateFormatter.stringFromDate((signInUserPublic?.birthday)!)
        }else {
            birthdayField.text = dateFormatter.stringFromDate(NSDate())
        }
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        MVC.birthdaySet = true
        //use string formate to store NSdate for signInUser?.birthday
        dateFormatter.dateFormat = "MM-dd-yyyy"
        signInUserPublic?.birthday = NSDate(dateString: dateFormatter.stringFromDate(datePicker.date))
        // this formate is localized formate already
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        birthdayField.text = strDate
        
    }
    
    // MARK: - Continue func
    @IBAction func Continue() {
        invalidBirthday.hidden = true
        if birthdayField.text == dateFormatter.stringFromDate(NSDate()){
            invalidBirthday.hidden = false
        }else{
            performSegueWithIdentifier(MVC.nextIdentifier, sender: nil)
        }
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
        if let ag = segue.destinationViewController as? StartAgGenderViewController{
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
extension NSDate
{
    convenience
    init(dateString:String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let d = dateFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}

