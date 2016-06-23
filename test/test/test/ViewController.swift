//
//  ViewController.swift
//  test
//
//  Created by CHENWEI CHIH on 6/18/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation //need to add CoreLoaction.framework in project setting
import MapKit // need to add MapKit.framework in project setting

class ViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var image: UIImageView!
    
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func save() {
        let ed = NSEntityDescription.entityForName("Person", inManagedObjectContext: moc)
        let person = Person(entity: ed!, insertIntoManagedObjectContext: moc)
        person.firstname = firstName.text
        person.lastname = lastName.text
        person.password = password.text
        person.email = email.text
        let img = UIImage(named: "1.png")
        let imgData = UIImageJPEGRepresentation(img!,  1)
        person.image = imgData
        
        //store data and throw exception error
        do{
            try moc.save()
            firstName.text = ""
            lastName.text = ""
            password.text = ""
            email.text = ""
            self.hideKB(self)
            Alert.show("Success", message: "Your Record is Saved", vc: self)
            
        } catch _ as NSError
        {
            Alert.show("Failed", message: "Tour Record is NOT Saved", vc: self)
        }
        
        
    }
    @IBAction func search() {
        let ed = NSEntityDescription.entityForName("Person", inManagedObjectContext: moc)
        let req = NSFetchRequest()
        req.entity = ed
        let cond = NSPredicate(format: "email = %@", email.text!) //condition
        req.predicate = cond
        do{
            //if result is fail go to down catch part, if success go to line below result
            let result = try moc.executeFetchRequest(req)
            if result.count > 0{
                let person = result[0] as! Person
                firstName.text = person.firstname 
                lastName.text = person.lastname
                email.text = person.email
                image.image = UIImage(data: person.image!)
                
            }else {
                Alert.show("Failed", message: "No Record is Found", vc: self)
            }
        
        }catch let error as NSError
        {
            Alert.show("Failed", message: error.localizedDescription, vc: self)
        }
    }

    
    @IBAction func hideKB(sender: AnyObject) {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        password.resignFirstResponder()
        email.resignFirstResponder()
        
    }
    
    
}

