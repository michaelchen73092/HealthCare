//
//  StartAbLoginViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/23/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

@available(iOS 10.0, *)
class StartAbLoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var invelidLabel: UILabel!
    @IBOutlet weak var emailField: UITextField! { didSet{ emailField.delegate = self}}
    @IBOutlet weak var passwordField: UITextField! { didSet{ passwordField.delegate = self}}
    fileprivate struct MVC {
        static let nextIdentifier = "StartAc"
        static var secure: Bool = true
        static let gotoUserIdentifier = "MainPersons"
        static let goToDoctorIdentifier = "Show DoctorAa"
    }
    var tempUser : Persons?
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    let tapRec = UITapGestureRecognizer()
    // MARK: - ViewController cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        Storyboard.KBisON = false
        searchDefaultUserOrDoctor()
        //tap gesture setting
        tapRec.addTarget(self, action: #selector(self.tappedView))
        self.view.addGestureRecognizer(tapRec)
        
    }
    fileprivate func updateUI(){
        //label setting
        passwordField.isSecureTextEntry = MVC.secure
        invelidLabel.isHidden = true
        
        //disable autocorrection
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
    }
    
    
    func searchDefaultUserOrDoctor(){
        //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
        do {
            //fetch a local user in HD
            let Personresults =  try moc.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]

            if person.count != 0{
                //if account is Persons, go to to user Main MVC(Aa)
                
                tempUser = person[0] //as? Persons
                
                if tempUser != nil {
                    //make sure person[0] always can downcasting to Person
                    emailField.text = tempUser!.email!
                    //passwordField.text = tempUser!.password!
                }
                
                // assign personsPublic data
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    func tappedView(){
        //dismissKB in AppDelegate
        dismissKB(emailField, textField2: passwordField, vc: self)
        
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

    
    // MARK: - login or signup
    @IBAction func login() {
        invelidLabel.isHidden = true
        if emailField.text == "" {
            //wiggle if there is no data
            wiggle(emailField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }
        else if passwordField.text == "" {
            //wiggle if there is no data
            wiggle(passwordField, Duration: 0.07, RepeatCount: 4, Offset: 10)
        }
        else if !validateEmail(emailField.text!){
            invelidLabel.isHidden = false
            wiggle(emailField, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
        else {
            //querry account on AWS and tell isDoctor is true or false to go 
            //User page or Doctor page
            //developing for login to mimic AWS
            if emailField.text == "user@berbi.com" && passwordField.text == "user70@berbi.com"{
                if  tempUser != nil{
                    if tempUser!.email! != "user@berbi.com"{
                        clearPreviousData()
                        (signInUser, signInUserPublic, signInDoctor) = developtingUserInAWS()
                        savelocal()
                    }else{
                        //if developer keyin id by himself, tempUser!.email! != "user@berbi.com" can happen
                        //if previous user is the same as coredata, use coredata account
                        coredataUser()
                    }
                }else{
                    (signInUser, signInUserPublic, signInDoctor) = developtingUserInAWS()
                    savelocal()
                }
                emailField.resignFirstResponder()
                passwordField.resignFirstResponder()
                performSegue(withIdentifier: MVC.gotoUserIdentifier, sender: nil)
            }
            if emailField.text == "doctor@berbi.com" && passwordField.text == "doctor70@berbi.com"{
                if tempUser != nil{
                    if tempUser!.email! != "doctor@berbi.com"{
                        clearPreviousData()
                        (signInUser, signInUserPublic, signInDoctor) = developtingDoctorInAWS()
                        savelocal()
                    }else{
                        //if developer keyin id by himself, tempUser!.email! != "doctor@berbi.com" can happen
                        //if previous user is the same as coredata, use coredata account
                        coredataUser()
                    }
                }else{
                    (signInUser, signInUserPublic, signInDoctor) = developtingDoctorInAWS()
                    savelocal()
                }
                emailField.resignFirstResponder()
                passwordField.resignFirstResponder()
                performSegue(withIdentifier: MVC.goToDoctorIdentifier, sender: nil)
            }
            
            //if success
            if signInUser != nil {
                //go to User page if signInUser is Persons type
                //else go to Doctors page
                performSegue(withIdentifier: MVC.gotoUserIdentifier, sender: nil)
            }
            else{
                //alert that there is no this user
                let invalidemail = NSLocalizedString("Invalid Email", comment: "Title for no email record found")
                let invalidemaildetail = NSLocalizedString("The email you entered doesn't appear to belong to an account. Please check your email address and try again.", comment: "Detail for no email record found")
                let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
                Alert.show(invalidemail, message: invalidemaildetail, ok: okstring, dismissBoth: false, vc: self)
            }//end else
        }//end all else
    }//end login

    @available(iOS 10.0, *)
    func coredataUser(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //let fetchRequestDoctor = NSFetchRequest(entityName: "Doctors")
        let fetchRequestDoctor: NSFetchRequest<Doctors> = Doctors.fetchRequest() as! NSFetchRequest<Doctors>
        //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
        //let fetchRequestPersonPublic = NSFetchRequest(entityName: "PersonsPublic")
        let fetchRequestPersonPublic: NSFetchRequest<PersonsPublic> = PersonsPublic.fetchRequest() as! NSFetchRequest<PersonsPublic>
        do {
            //fetch a local user in HD
            let Personresults =  try managedContext.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            //fetch a local user Public in HD
            let PersonPublicresults =  try managedContext.fetch(fetchRequestPersonPublic)
            let personPublic = PersonPublicresults //as! [NSManagedObject]
            //fetch a local doctor in HD
            let Doctorresults =  try managedContext.fetch(fetchRequestDoctor)
            let doctor = Doctorresults //as! [NSManagedObject]
            //doctor first and user second
            if doctor.count != 0 {
                signInDoctor = doctor[0] //as? Doctors
                //if account is Doctors, go to to doctor Main MVC
            }
            if person.count != 0{
                //if account is Persons, go to to user Main MVC(Aa)
                signInUser = person[0] //as? Persons //make sure person[0] always can downcasting to Person
                // assign personsPublic data
                if personPublic.count != 0{
                    signInUserPublic = personPublic[0] //as? PersonsPublic
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    
    func clearPreviousData(){
        do{
            //let fetchRequestDoctor = NSFetchRequest(entityName: "Doctors")
            let fetchRequestDoctor: NSFetchRequest<Doctors> = Doctors.fetchRequest() as! NSFetchRequest<Doctors>
            //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
            let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
            //let fetchRequestPersonPublic = NSFetchRequest(entityName: "PersonsPublic")
            let fetchRequestPersonPublic: NSFetchRequest<PersonsPublic> = PersonsPublic.fetchRequest() as! NSFetchRequest<PersonsPublic>
            let Personresults =  try moc.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            print("in clearPreviousData")
            print("person count before:\(person.count)")
            for entity in person{
                self.moc.delete(entity)
            }
            print("person count after:\(person.count)")
            //fetch a local user Public in HD
            let PersonPublicresults =  try moc.fetch(fetchRequestPersonPublic)
            let personPublic = PersonPublicresults //as! [NSManagedObject]
            for entity in personPublic{
                moc.deletedObjects
                self.moc.delete(entity)
            }
            //fetch a local doctor in HD
            let Doctorresults =  try moc.fetch(fetchRequestDoctor)
            let doctor = Doctorresults //as! [NSManagedObject]
            for entity in doctor{
                moc.deletedObjects
                self.moc.delete(entity)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        do {
            try moc.save()
        }catch{
            print("Could not save")
        }
    }
    
    func savelocal(){
        do{
            try moc.save()
            //alert that there is no this user
            //let success = NSLocalizedString("Success", comment: "Title for success open an account")
            //let details = NSLocalizedString("Your Account is creaded", comment: "detail of Success")
            //let okstring = NSLocalizedString("OK", comment: "Confrim for exit alert")
            //Alert.show(success, message: details, ok: okstring,vc: self)
        } catch _ as NSError
        {
            //alert that there is no this user
            let fail = NSLocalizedString("Fail", comment: "Title for fail open an account")
            let details = NSLocalizedString("Your Account is NOT created", comment: "detail of fail")
            let okstring = NSLocalizedString("back", comment: "Confrim for exit alert")
            Alert.show(fail, message: details, ok: okstring, dismissBoth: false,vc: self)
        }
    }
    
    @IBAction func signup() {
        //initialize signInUser by moc
        let PersonsEntity = NSEntityDescription.entity(forEntityName: "Persons", in: moc)
        signInUser = Persons(entity: PersonsEntity!, insertInto: moc)
        let PersonsPublicEntity = NSEntityDescription.entity(forEntityName: "PersonsPublic", in: moc)
        signInUserPublic = PersonsPublic(entity: PersonsPublicEntity!, insertInto: moc)
        performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
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
        return true
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ac = segue.destination as? StartAcEmailViewController{
            //pass current moc to next controller which use for create Persons object
            ac.moc = self.moc
        }
    }

    // MARK: - Create Developing User and Doctor
    fileprivate func developtingUserInAWS() ->(person: Persons?, personpublic: PersonsPublic?, doctor: Doctors?){
        
        let PersonsEntity = NSEntityDescription.entity(forEntityName: "Persons", in: moc)
        let User = Persons(entity: PersonsEntity!, insertInto: moc)
        User.email = "user@berbi.com"
        User.applicationStatus = Status.userModeNotApply
        User.isdoctor = false
        User.password = "user70@berbi.com"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let PersonsPublicEntity = NSEntityDescription.entity(forEntityName: "PersonsPublic", in: moc)
        let UserPublic = PersonsPublic(entity: PersonsPublicEntity!, insertInto: moc)
        UserPublic.firstname = "Wei-Chih"
        UserPublic.lastname = "Chen"
        UserPublic.birthday = Date(dateString: "09-24-1984")
        UserPublic.email = "user@berbi.com"
        UserPublic.height = 174.0
        UserPublic.weight = 60.0
        UserPublic.ethnicity = " 2 "
        UserPublic.gender = false
        UserPublic.imageRemoteUrl = "https://scontent-sea1-1.xx.fbcdn.net/v/t1.0-1/c427.3.533.533/s160x160/1231546_10152098475632345_1368421124_n.jpg?oh=54089e8c829f9f933f9eb155b7a736e1&oe=581C6EF9"
        
        return(User, UserPublic, nil)
    }
    
    fileprivate func developtingDoctorInAWS() ->(person: Persons?, personpublic: PersonsPublic?, doctor: Doctors?){
        
        let PersonsEntity = NSEntityDescription.entity(forEntityName: "Persons", in: moc)
        let User = Persons(entity: PersonsEntity!, insertInto: moc)
        User.email = "doctor@berbi.com"
        User.applicationStatus = Status.underReview
        User.isdoctor = true
        User.password = "doctor70@berbi.com"
        User.doctorLicenseNumber = "56734236"
        User.cellPhone = "0932802107"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let PersonsPublicEntity = NSEntityDescription.entity(forEntityName: "PersonsPublic", in: moc)
        let UserPublic = PersonsPublic(entity: PersonsPublicEntity!, insertInto: moc)
        UserPublic.firstname = "欣湄"
        UserPublic.lastname = "陳"
        UserPublic.birthday = Date(dateString: "10-13-1985")
        UserPublic.email = "doctor@berbi.com"
        UserPublic.height = 174.0
        UserPublic.weight = 52.0
        UserPublic.ethnicity = " 2 "
        UserPublic.gender = true
        UserPublic.imageRemoteUrl = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p160x160/13692605_10153942476143285_2377423907395322295_n.jpg?oh=5e2dc23d72ffd91ee88aa2f4fd3eb1db&oe=5857F1EC"
        let DoctorsEntity = NSEntityDescription.entity(forEntityName: "Doctors", in: moc)
        let Doctor = Doctors(entity: DoctorsEntity!, insertInto: moc)
        Doctor.doctorCertificated = NSNumber(value: true as Bool)
        Doctor.doctorFirstName = "欣湄"
        Doctor.doctorLastName = "陳"
        Doctor.doctorFiveStarNumber = 50
        Doctor.doctorFourStarNumber = 2
        Doctor.doctorGraduateSchool = "9"
        Doctor.doctorHospital = "台北中山醫院"
        Doctor.doctorHospitalLatitude = 25.036647
        Doctor.doctorHospitalLongitude = 121.549984
        Doctor.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p160x160/13692605_10153942476143285_2377423907395322295_n.jpg?oh=5e2dc23d72ffd91ee88aa2f4fd3eb1db&oe=5857F1EC"
        Doctor.doctorLanguage = " 4 , 9 "
        Doctor.doctorProfession = "10"
        Doctor.doctorProfessionTitle = "2"
        Doctor.doctorStar = 4.96
        Doctor.email = "doctor@berbi.com"
        return(User, UserPublic, Doctor)
    }
    
    
    
}
