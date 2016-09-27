//
//  StartAaHelloViewController.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/23/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import testKit

// set a temporal Persons in memory
var signInUser: Persons?
var signInUserPublic: PersonsPublic?
var signInDoctor: Doctors?
var onLineDoctor : [Doctors]?

@available(iOS 10.0, *)
class StartAaHelloViewController: UIViewController {
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate struct MVC{
        static let MainPersonsIdentifier = "MainPersons"
        static let StartAbIdentifier = "StartAb"
        static let showDoctorAaIdentifier = "Show DoctorAa"
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //setting delay one second for startup.
        //Initial environment in this MVC later in viewDidLoad
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            //if account is Users, go to to user Main MVC(Aa)
            //if account is Doctors, go to to doctor Main MVC(??)
            //if no account to go login page(StartAb)
           self.searchDefaultUserOrDoctor()
        }
    }
    
    func searchDefaultUserOrDoctor(){
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
                
                //now for developing use////////////
//                if signInDoctor != nil{
//                    signInUser?.isdoctor = false
//                    signInDoctor?.doctorCertificated = NSNumber(bool: true)
//                }
                ////////////////////////////////////
                loadDevelopingOnlineDoctorList()
                if signInUser?.isdoctor == false{
                    performSegue(withIdentifier: MVC.MainPersonsIdentifier, sender: nil)
                }else{
                    performSegue(withIdentifier: MVC.showDoctorAaIdentifier, sender: nil)
                }
            }

            if person.count == 0 && doctor.count == 0{
                //if no account to go login page(StartAb)
                performSegue(withIdentifier: MVC.StartAbIdentifier, sender: nil)
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
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
    // MARK: - Create Online Doctor List
    fileprivate func loadDevelopingOnlineDoctorList() {
        onLineDoctor = [Doctors]()
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
        onLineDoctor?.insert(Doctor, at: onLineDoctor!.count)
        
        let DoctorTwo = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorTwo.doctorCertificated = NSNumber(value: true as Bool)
        DoctorTwo.doctorFirstName = "建志"
        DoctorTwo.doctorLastName = "潘"
        DoctorTwo.doctorFiveStarNumber = 31
        DoctorTwo.doctorFourStarNumber = 3
        DoctorTwo.doctorThreeStarNumber = 2
        DoctorTwo.doctorGraduateSchool = "0"
        DoctorTwo.doctorHospital = "台北市立萬芳醫學中心"
        DoctorTwo.doctorHospitalLatitude = 24.999889
        DoctorTwo.doctorHospitalLongitude = 121.558457
        DoctorTwo.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/p480x480/13495243_10153716756341964_828187480660825484_n.jpg?oh=8b16c0294268c066aff8428e1aeaa7db&oe=5849D016"
        DoctorTwo.doctorLanguage = " 4 , 9 "
        DoctorTwo.doctorProfession = "28"
        DoctorTwo.doctorProfessionTitle = "2"
        DoctorTwo.doctorStar = 4.81
        DoctorTwo.email = "doctor2@berbi.com"
        onLineDoctor?.insert(DoctorTwo, at: onLineDoctor!.count)
        
        let DoctorThree = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorThree.doctorCertificated = NSNumber(value: true as Bool)
        DoctorThree.doctorFirstName = "彥文"
        DoctorThree.doctorLastName = "王"
        DoctorThree.doctorFiveStarNumber = 12
        DoctorThree.doctorFourStarNumber = 9
        DoctorThree.doctorThreeStarNumber = 1
        DoctorThree.doctorGraduateSchool = "10"
        DoctorThree.doctorHospital = "晶鑽時尚診所(高雄據點)"
        DoctorThree.doctorHospitalLatitude = 22.631384
        DoctorThree.doctorHospitalLongitude = 120.304476
        DoctorThree.doctorImageRemoteURL = "https://scontent.fsnc1-1.fna.fbcdn.net/t31.0-1/c0.58.480.480/p480x480/10644666_922870424453834_2377411861492947829_o.jpg"
        DoctorThree.doctorLanguage = " 4 "
        DoctorThree.doctorProfession = "5"
        DoctorThree.doctorProfessionTitle = "2"
        DoctorThree.doctorStar = 4.50
        DoctorThree.email = "doctor3@berbi.com"
        onLineDoctor?.insert(DoctorThree, at: onLineDoctor!.count)
        
        let DoctorFour = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorFour.doctorCertificated = NSNumber(value: true as Bool)
        DoctorFour.doctorFirstName = "尚平"
        DoctorFour.doctorLastName = "洪"
        DoctorFour.doctorFiveStarNumber = 26
        DoctorFour.doctorFourStarNumber = 1
        DoctorFour.doctorThreeStarNumber = 1
        DoctorFour.doctorTwoStarNumber = 1
        DoctorFour.doctorGraduateSchool = "0"
        DoctorFour.doctorHospital = "柳營奇美醫院"
        DoctorFour.doctorHospitalLatitude = 23.288508
        DoctorFour.doctorHospitalLongitude = 120.325370
        DoctorFour.doctorImageRemoteURL = "https://scontent-sjc2-1.xx.fbcdn.net/v/t1.0-1/c0.0.160.160/p160x160/13707796_1117482481624265_4589455678116602371_n.jpg?oh=8ea311b496a217b3122637be7e42946f&oe=58538CB4"
        DoctorFour.doctorLanguage = " 4 "
        DoctorFour.doctorProfession = "9"
        DoctorFour.doctorProfessionTitle = "2"
        DoctorFour.doctorStar = 4.517
        DoctorFour.email = "doctor4@berbi.com"
        onLineDoctor?.insert(DoctorFour, at: onLineDoctor!.count)
        
        let DoctorFive = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorFive.doctorCertificated = NSNumber(value: true as Bool)
        DoctorFive.doctorFirstName = "浩雲"
        DoctorFive.doctorLastName = "洪"
        DoctorFive.doctorFiveStarNumber = 11
        DoctorFive.doctorFourStarNumber = 12
        DoctorFive.doctorThreeStarNumber = 1
        DoctorFive.doctorTwoStarNumber = 5
        DoctorFive.doctorGraduateSchool = "0"
        DoctorFive.doctorHospital = "新北市立聯合醫院三重院區"
        DoctorFive.doctorHospitalLatitude = 25.061122
        DoctorFive.doctorHospitalLongitude = 121.490836
        DoctorFive.doctorImageRemoteURL = "https://scontent.fsnc1-1.fna.fbcdn.net/v/t1.0-1/557405_505333079493723_2054023908_n.jpg?oh=4b3d0bfd9c47674547d4c76bec9e8ec8&oe=5858DD00"
        DoctorFive.doctorLanguage = " 4 "
        DoctorFive.doctorProfession = "30"
        DoctorFive.doctorProfessionTitle = "2"
        DoctorFive.doctorStar = 4.00
        DoctorFive.email = "doctor5@berbi.com"
        onLineDoctor?.insert(DoctorFive, at: onLineDoctor!.count)
        
        let DoctorSix = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorSix.doctorCertificated = NSNumber(value: true as Bool)
        DoctorSix.doctorFirstName = "肇烜"
        DoctorSix.doctorLastName = "張"
        DoctorSix.doctorFiveStarNumber = 29
        DoctorSix.doctorFourStarNumber = 8
        DoctorSix.doctorThreeStarNumber = 1
        DoctorSix.doctorGraduateSchool = "9"
        DoctorSix.doctorHospital = "台中中山醫院"
        DoctorSix.doctorHospitalLatitude = 24.121398
        DoctorSix.doctorHospitalLongitude = 120.650336
        DoctorSix.doctorImageRemoteURL = "https://scontent.fsnc1-1.fna.fbcdn.net/v/t1.0-1/c0.0.321.321/1451983_962878593790137_532496097089051090_n.jpg?oh=6cbdba958adc4ec3e8e30d8c79af81ce&oe=58100ECD"
        DoctorSix.doctorLanguage = " 4 "
        DoctorSix.doctorProfession = "9"
        DoctorSix.doctorProfessionTitle = "2"
        DoctorSix.doctorStar = 4.74
        DoctorSix.email = "doctor6@berbi.com"
        onLineDoctor?.insert(DoctorSix, at: onLineDoctor!.count)
        
        let DoctorSeven = Doctors(entity: DoctorsEntity!, insertInto: moc)
        DoctorSeven.doctorCertificated = NSNumber(value: true as Bool)
        DoctorSeven.doctorFirstName = "Willcox"
        DoctorSeven.doctorLastName = "Chen"
        DoctorSeven.doctorFiveStarNumber = 23
        DoctorSeven.doctorFourStarNumber = 10
        DoctorSeven.doctorThreeStarNumber = 3
        DoctorSeven.doctorGraduateSchool = "8"
        DoctorSeven.doctorHospital = "台南某診所"
        DoctorSeven.doctorHospitalLatitude = 22.999734
        DoctorSeven.doctorHospitalLongitude = 120.226726
        DoctorSeven.doctorImageRemoteURL = "https://scontent.fsnc1-1.fna.fbcdn.net/v/t1.0-1/c79.76.296.296/10363349_10152491177722467_3612441080492442487_n.jpg?oh=804d1535d4734d6df6f90d942f4758de&oe=584EE795"
        DoctorSeven.doctorLanguage = " 4 "
        DoctorSeven.doctorProfession = "3"
        DoctorSeven.doctorProfessionTitle = "1"
        DoctorSeven.doctorStar = 4.56
        DoctorSeven.email = "doctor7@berbi.com"
        onLineDoctor?.insert(DoctorSeven, at: onLineDoctor!.count)
        
    }
}
