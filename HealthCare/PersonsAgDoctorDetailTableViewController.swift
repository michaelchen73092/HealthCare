//
//  PersonsAgDoctorDetailTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/27/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import testKit
import CoreData

class PersonsAgDoctorDetailTableViewController: UITableViewController {

    // MARK: - Variables
    var Doctor : Doctors?
    //Doctor settings
    //description follow top to down order
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorImageView: UIImageView!
    //right board certificated image
    @IBOutlet weak var doctorSpecialty: UILabel!
    @IBOutlet weak var doctorGraduateSchool: UILabel!
    @IBOutlet weak var doctorCurrentHospital: UILabel!
    @IBOutlet weak var doctorLanguage: UILabel!
    
    @IBOutlet weak var doctorIsBoardCertificated: UIImageView!
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    ///////////////////////////
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var makeAReservation: UIButton!
    
    //Evaluation//
    @IBOutlet weak var doctorEvalutationLabel: UILabel!
    @IBOutlet weak var subStarOne: UIImageView!
    @IBOutlet weak var subStarTwo: UIImageView!
    @IBOutlet weak var subStarThree: UIImageView!
    @IBOutlet weak var subStarFour: UIImageView!
    @IBOutlet weak var subStarFive: UIImageView!
    
    @IBOutlet weak var evaluationTotalNumber: UILabel!
    @IBOutlet weak var scoreOutOfFiveStarsLabel: UILabel!
    
    @IBOutlet weak var fiveStarLabel: UILabel!
    @IBOutlet weak var fourStarLabel: UILabel!
    @IBOutlet weak var threeStarLabel: UILabel!
    @IBOutlet weak var twoStarLabel: UILabel!
    @IBOutlet weak var oneStarLabel: UILabel!
    
    @IBOutlet weak var fiveStarPercent: UILabel!
    @IBOutlet weak var fourStarPercent: UILabel!
    @IBOutlet weak var threeStarPercent: UILabel!
    @IBOutlet weak var twoStarPercent: UILabel!
    @IBOutlet weak var oneStarPercent: UILabel!
    
    @IBOutlet weak var fiveGraphView: UIView!
    @IBOutlet weak var fourGraphView: UIView!
    @IBOutlet weak var threeGraphView: UIView!
    @IBOutlet weak var twoGraphView: UIView!
    @IBOutlet weak var oneGraphView: UIView!

    //graph data part
    @IBOutlet weak var fiveYellowGraphView: UIView!
    @IBOutlet weak var fourYellowGraphView: UIView!
    @IBOutlet weak var threeYellowGraphView: UIView!
    @IBOutlet weak var twoYellowGraphView: UIView!
    @IBOutlet weak var oneYellowGraphView: UIView!
    
    @IBOutlet weak var fiveWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var threeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var twoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var oneWidthConstraint: NSLayoutConstraint!

    
    /////////
    var reviews = [DoctorReviews]()
    weak var reviewEntity : NSEntityDescription?
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //Comments Label//
    @IBOutlet weak var commentsLabel: UILabel!
    
    fileprivate struct MVC {
        static let makeAReservationString = NSLocalizedString("Make A Reservation", comment: "In PersonsAgDoctorDetail, button for make a reservation")
        static let ratingString = NSLocalizedString("Doctor Ratings", comment: "In PersonsAgDoctorDetail, Label for doctor Rating")
        static let outOfFiveStarsString = NSLocalizedString("out of 5 stars", comment: "In PersonsAgDoctorDetail, can use (out of 5 stars) to translate")
        static let starsString = NSLocalizedString("star", comment: "In PersonsAgDoctorDetail, label for 1~5 star under doctor ratings")
        static let patientReviewString = NSLocalizedString("Patient Reviews", comment: "In PersonsAgDoctorDetail, Label for Patient Reviews")
        static let noReviewString = NSLocalizedString("No Reviews", comment: "In PersonsAgDoctorDetail, Label for No Reviews")
        static let cellIdentifier = "doctor Reviews"
        static let nextIdentifier = "show payment view"
    }
    
    
    fileprivate func updateUI(){
        onLineDoctorUpdateUI(doctorNameLabel, doctorGraduateSchool: doctorGraduateSchool,doctorCurrentHospital: doctorCurrentHospital,doctorLanguage: doctorLanguage, doctorSpecialty: doctorSpecialty, doctorImageView:doctorImageView, doctorIsBoardCertificated: doctorIsBoardCertificated, doctor:Doctor, starA: starOne, starB: starTwo, starC: starThree, starD: starFour, starE: starFive)
        onlineLabel.textColor = UIColor(netHex: 0x42D451)
        onlineLabel.text = Storyboard.onLine
        makeAReservation.setTitle(MVC.makeAReservationString, for: UIControlState())
        fiveGraphView.layer.borderWidth = 1.0
        fiveGraphView.layer.borderColor = UIColor.lightGray.cgColor
        fourGraphView.layer.borderWidth = 1.0
        fourGraphView.layer.borderColor = UIColor.lightGray.cgColor
        threeGraphView.layer.borderWidth = 1.0
        threeGraphView.layer.borderColor = UIColor.lightGray.cgColor
        twoGraphView.layer.borderWidth = 1.0
        twoGraphView.layer.borderColor = UIColor.lightGray.cgColor
        oneGraphView.layer.borderWidth = 1.0
        oneGraphView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func onLineDoctorUpdateUI(_ nameLabel: UILabel, doctorGraduateSchool: UILabel, doctorCurrentHospital: UILabel, doctorLanguage: UILabel, doctorSpecialty: UILabel,doctorImageView: UIImageView, doctorIsBoardCertificated: UIImageView, doctor: Doctors?, starA: UIImageView, starB: UIImageView, starC: UIImageView, starD: UIImageView, starE: UIImageView)  {
        let englishFormat = "(?=.*[A-Za-z]).*$"
        let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
        if doctor!.doctorLastName != nil && doctor!.doctorFirstName != nil{
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            if langId.range(of: "en") != nil || englishPredicate.evaluate(with: doctor!.doctorFirstName!) || englishPredicate.evaluate(with: doctor!.doctorLastName!) {
                nameLabel.text = "Dr. "+doctor!.doctorFirstName!+" "+doctor!.doctorLastName!
            }else if langId.range(of: "zh") != nil{
                nameLabel.text = doctor!.doctorLastName!+doctor!.doctorFirstName!+" "+Storyboard.doctorTitle
            }else{
                nameLabel.text = Storyboard.doctorTitle+" "+doctor!.doctorFirstName!+" "+doctor!.doctorLastName!
            }
        }
        let school = NSLocalizedString("Edu: ", comment: "translate for school")
        let hospital = NSLocalizedString("Serve at ", comment: "translate where is doctor employed")
        let language = NSLocalizedString("Language: ", comment: "translate language")
        if doctor!.doctorGraduateSchool != nil && doctor!.doctorHospital != nil && doctor!.doctorLanguage != nil{
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            if langId.range(of: "en") != nil{
                doctorGraduateSchool.text = school+School.school[Int(doctor!.doctorGraduateSchool!)!][1]
            }else{
                doctorGraduateSchool.text = school+School.school[Int(doctor!.doctorGraduateSchool!)!][0]
            }
            doctorCurrentHospital.text = hospital+doctor!.doctorHospital!
            if doctor!.doctorLanguage != nil && doctor!.doctorLanguage != ""{
                doctorLanguage.text = language+printLanguage(doctor!.doctorLanguage!)
            }
        }
        //show doctorIsBoardCertificated or not
        doctorIsBoardCertificated.isHidden = true
        if doctor!.doctorCertificated!.boolValue {
            doctorIsBoardCertificated.isHidden = false
        }
        //no matter there is doctorImageSpecialistLicense or not, we alway show doctorProfession
        if doctor!.doctorProfession != nil{
            if doctor!.doctorProfessionTitle != nil {
                if Int(doctor!.doctorProfessionTitle!) != nil && Int(doctor!.doctorProfession!) != nil{
                    doctorSpecialty.text = specialty.allSpecialty[Int(doctor!.doctorProfession!)!] +  " " + specialty.title[Int(doctor!.doctorProfessionTitle!)!]
                }
            }else{
                if doctor!.doctorProfession! == "Internist"{
                    doctorSpecialty.text = Storyboard.internist
                }else{
                    doctorSpecialty.text = Storyboard.pgy
                }
            }
        }
        //doctorImage
        if doctor!.doctorImageRemoteURL != nil && doctor!.doctorImageRemoteURL! != ""{
            if let profileImageURL = doctor!.doctorImageRemoteURL{
                //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                if let imageData = try? Data(contentsOf: URL(string:profileImageURL)!) {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                        DispatchQueue.main.async {
                            self!.doctorImageView?.image = UIImage(data: imageData)
                        }
                    }
                }else{
                    print("Wrong imageURL for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
                    defaultImage()
                }
            }else{
                print("No image for doctor :\(doctor!.doctorFirstName!) \(doctor!.doctorLastName)")
                defaultImage()
            }
        }else{
            defaultImage()
        }
        //star image
        let startotal = Double(doctor!.doctorOneStarNumber!) + Double(doctor!.doctorTwoStarNumber!) + Double(doctor!.doctorThreeStarNumber!) + Double(doctor!.doctorFourStarNumber!) + Double(doctor!.doctorFiveStarNumber!)
        var starEverage = Double(doctor!.doctorOneStarNumber!) * 1
        starEverage += Double(doctor!.doctorTwoStarNumber!) * 2
        starEverage += Double(doctor!.doctorThreeStarNumber!) * 3
        starEverage += Double(doctor!.doctorFourStarNumber!) * 4
        starEverage += Double(doctor!.doctorFiveStarNumber!) * 5
        starEverage = (startotal == 0) ? 0 : starEverage * 100 / startotal
        switch Int(starEverage) {
        case 0:
            starA.image = UIImage(named: "starEmpty")
            starB.image = UIImage(named: "starEmpty")
            starC.image = UIImage(named: "starEmpty")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 1...49:
            starA.image = UIImage(named: "starHalfFull")
            starB.image = UIImage(named: "starEmpty")
            starC.image = UIImage(named: "starEmpty")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 50...100:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starEmpty")
            starC.image = UIImage(named: "starEmpty")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 101...149:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starHalfFull")
            starC.image = UIImage(named: "starEmpty")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 150...200:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starEmpty")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 201...249:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starHalfFull")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 250...300:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starFull")
            starD.image = UIImage(named: "starEmpty")
            starE.image = UIImage(named: "starEmpty")
        case 301...349:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starFull")
            starD.image = UIImage(named: "starHalfFull")
            starE.image = UIImage(named: "starEmpty")
        case 350...400:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starFull")
            starD.image = UIImage(named: "starFull")
            starE.image = UIImage(named: "starEmpty")
        case 401...449:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starFull")
            starD.image = UIImage(named: "starFull")
            starE.image = UIImage(named: "starHalfFull")
        default:
            starA.image = UIImage(named: "starFull")
            starB.image = UIImage(named: "starFull")
            starC.image = UIImage(named: "starFull")
            starD.image = UIImage(named: "starFull")
            starE.image = UIImage(named: "starFull")
        }
    }
    
    func defaultImage(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            DispatchQueue.main.async {
                self!.doctorImageView?.image = UIImage(named:"doctor")
            }
        }
    }
    
    @IBAction func makeAReservationButton() {
        performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        self.navigationItem.title = doctorNameLabel.text
        let backNavigationButton = UIBarButtonItem(title: Storyboard.backNavigationItemLeftButton , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem = backNavigationButton
        evaluationUpdate()
        reviewEntity = NSEntityDescription.entity(forEntityName: "DoctorReviews", in: moc)
        if Doctor != nil{
            reviews = fetchDoctorReview(Doctor!.email!)!
        }
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }

    func backButtonClicked(){
        dismiss(animated: true, completion: nil)
    }
    
    func evaluationUpdate(){
        doctorEvalutationLabel.text = MVC.ratingString
        
        //star image
        let startotal = Double(Doctor!.doctorOneStarNumber!) + Double(Doctor!.doctorTwoStarNumber!) + Double(Doctor!.doctorThreeStarNumber!) + Double(Doctor!.doctorFourStarNumber!) + Double(Doctor!.doctorFiveStarNumber!)
        evaluationTotalNumber.text = "\(String(Int(startotal)))"
        var starEverage = Double(Doctor!.doctorOneStarNumber!) * 1
        starEverage += Double(Doctor!.doctorTwoStarNumber!) * 2
        starEverage += Double(Doctor!.doctorThreeStarNumber!) * 3
        starEverage += Double(Doctor!.doctorFourStarNumber!) * 4
        starEverage += Double(Doctor!.doctorFiveStarNumber!) * 5
        starEverage = (startotal == 0) ? 0 : starEverage * 100 / startotal
        switch Int(starEverage) {
        case 0:
            subStarOne.image = UIImage(named: "starEmpty")
            subStarTwo.image = UIImage(named: "starEmpty")
            subStarThree.image = UIImage(named: "starEmpty")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 1...49:
            subStarOne.image = UIImage(named: "starHalfFull")
            subStarTwo.image = UIImage(named: "starEmpty")
            subStarThree.image = UIImage(named: "starEmpty")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 50...100:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starEmpty")
            subStarThree.image = UIImage(named: "starEmpty")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 101...149:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starHalfFull")
            subStarThree.image = UIImage(named: "starEmpty")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 150...200:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starEmpty")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 201...249:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starHalfFull")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 250...300:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starFull")
            subStarFour.image = UIImage(named: "starEmpty")
            subStarFive.image = UIImage(named: "starEmpty")
        case 301...349:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starFull")
            subStarFour.image = UIImage(named: "starHalfFull")
            subStarFive.image = UIImage(named: "starEmpty")
        case 350...400:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starFull")
            subStarFour.image = UIImage(named: "starFull")
            subStarFive.image = UIImage(named: "starEmpty")
        case 401...449:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starFull")
            subStarFour.image = UIImage(named: "starFull")
            subStarFive.image = UIImage(named: "starHalfFull")
        default:
            subStarOne.image = UIImage(named: "starFull")
            subStarTwo.image = UIImage(named: "starFull")
            subStarThree.image = UIImage(named: "starFull")
            subStarFour.image = UIImage(named: "starFull")
            subStarFive.image = UIImage(named: "starFull")
        }
        scoreOutOfFiveStarsLabel.text = "\(String(format: "%.1f", starEverage/100)) " + MVC.outOfFiveStarsString
        fiveStarLabel.text = "5 "+MVC.starsString
        fourStarLabel.text = "4 "+MVC.starsString
        threeStarLabel.text = "3 "+MVC.starsString
        twoStarLabel.text = "2 "+MVC.starsString
        oneStarLabel.text = "1 "+MVC.starsString
        
        var temp = (Int(startotal) == 0) ? Int(0) : Int(Double(Doctor!.doctorFiveStarNumber!)*100/startotal)
        fiveStarPercent.text = "\(temp)%"
        fiveWidthConstraint.constant = CGFloat(fiveGraphView.layer.frame.width * CGFloat(temp) / 100)
        temp = (Int(startotal) == 0) ? Int(0) : Int(Double(Doctor!.doctorFourStarNumber!)*100/startotal)
        fourStarPercent.text = "\(temp)%"
        fourWidthConstraint.constant = CGFloat(fourGraphView.layer.frame.width * CGFloat(temp) / 100)
        temp = (Int(startotal) == 0) ? Int(0) : Int(Double(Doctor!.doctorThreeStarNumber!)*100/startotal)
        threeStarPercent.text = "\(temp)%"
        threeWidthConstraint.constant = CGFloat(threeGraphView.layer.frame.width * CGFloat(temp) / 100)
        temp = (Int(startotal) == 0) ? Int(0) : Int(Double(Doctor!.doctorTwoStarNumber!)*100/startotal)
        twoStarPercent.text = "\(temp)%"
        twoWidthConstraint.constant = CGFloat(twoGraphView.layer.frame.width * CGFloat(temp) / 100)
        temp = (Int(startotal) == 0) ? Int(0) : Int(Double(Doctor!.doctorOneStarNumber!)*100/startotal)
        oneStarPercent.text = "\(temp)%"
        oneWidthConstraint.constant = CGFloat(oneGraphView.layer.frame.width * CGFloat(temp) / 100)
        
        commentsLabel.text = MVC.patientReviewString
    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MVC.cellIdentifier, for: indexPath) as! PersonsAhDoctorReviewsTableViewCell
        cell.reviews = reviews[(indexPath as NSIndexPath).row]
        return cell
    }

    fileprivate func fetchDoctorReview(_ doctorEmail: String) ->[DoctorReviews]? {
        var testAll = [DoctorReviews]()
        let dateFormatter = DateFormatter()
        var dateAsString = "24-08-2016 23:59"
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        if doctorEmail == "doctor@berbi.com"{
            let testOne = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            testOne.time = dateFormatter.date(from: dateAsString)
            testOne.patientName = "陳威志"
            testOne.stars = 5
            testOne.review = "陳醫師醫術好，人又漂亮超級推薦"
            testAll.insert(testOne, at: testAll.count)
            let testTwo = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "24-07-2016 21:59"
            testTwo.time = dateFormatter.date(from: dateAsString)
            testTwo.patientName = "黃淑敏"
            testTwo.stars = 5
            testTwo.review = "我膝蓋有點問題，聽醫師的建議處理之後，過了幾個月膝蓋的狀況就改善，而且醫師都有定期在線上，不會很難預約，很讚的醫師！超級推薦！！"
            testAll.insert(testTwo, at: testAll.count)
            let testThree = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "08-04-2016 09:34"
            testThree.time = dateFormatter.date(from: dateAsString)
            testThree.patientName = "陳耀琳"
            testThree.stars = 5
            testThree.review = "醫師人好，心地又善良，看完病後病很快就好了"
            testAll.insert(testThree, at: testAll.count)
            let testFour = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "08-11-2015 19:25"
            testFour.time = dateFormatter.date(from: dateAsString)
            testFour.patientName = "劉玉婷"
            testFour.stars = 5
            testFour.review = "非常推薦這位醫生"
            testAll.insert(testFour, at: testAll.count)
        }else if doctorEmail == "doctor3@berbi.com"{
            let testOne = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "04-02-2016 11:52"
            testOne.time = dateFormatter.date(from: dateAsString)
            testOne.patientName = "陳建霖"
            testOne.stars = 5
            testOne.review = "醫生好美"
            testAll.insert(testOne, at: testAll.count)
            let testTwo = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "24-01-2016 21:59"
            testTwo.time = dateFormatter.date(from: dateAsString)
            testTwo.patientName = "黃惠霞"
            testTwo.stars = 5
            testTwo.review = "醫師蠻專業的"
            testAll.insert(testTwo, at: testAll.count)
        }else if doctorEmail == "doctor5@berbi.com"{
            let testOne = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "04-02-2016 11:52"
            testOne.time = dateFormatter.date(from: dateAsString)
            testOne.patientName = "胡瓜"
            testOne.stars = 5
            testOne.review = "這位醫生說話很幽默，所有疑難雜症都可問他"
            testAll.insert(testOne, at: testAll.count)
        }else if doctorEmail == "doctor6@berbi.com"{
            let testOne = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            dateAsString = "04-02-2016 11:52"
            testOne.time = dateFormatter.date(from: dateAsString)
            testOne.patientName = "陳朝琴"
            testOne.stars = 5
            testOne.review = "之前感冒問張醫師，雖然沒有吃藥，但是聽張醫師的建議後就改善很多！"
            testAll.insert(testOne, at: testAll.count)
        }
        if testAll.count == 0{
            let testOne = DoctorReviews(entity: reviewEntity!, insertInto: moc)
            testOne.review = MVC.noReviewString
            testAll.insert(testOne, at: testAll.count)
        }
        return testAll
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ai = segue.destination as? PersonsAiPaymentTableViewController{
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            ai.Doctor = Doctor
        }
        
    }
    
}
