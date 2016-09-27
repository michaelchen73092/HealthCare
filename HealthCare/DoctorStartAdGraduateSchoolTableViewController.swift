//
//  DoctorStartAdGraduateSchoolTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 7/22/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData

@available(iOS 10.0, *)
class DoctorStartAdGraduateSchoolTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Variables
    @IBOutlet weak var graduatedLabel: UILabel!
    @IBOutlet weak var medicalDiplomaLabel: UIButton!
    @IBOutlet weak var descriptionForDiploma: UILabel!
    
    @IBOutlet weak var idCardLabel: UIButton!
    @IBOutlet weak var descriptionForIDCard: UILabel!
    
    @IBOutlet weak var invalidNotification: UILabel!
    
    var diplomaHeight = CGFloat(60)
    var idCardHeight = CGFloat(60)
    weak var moc : NSManagedObjectContext?
    fileprivate struct MVC {
        static let nextIdentifier = "Show DoctorStartAf"
    }
    @IBOutlet weak var graduatedDescription: UILabel!
    
    // MARK: - view cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup description 
        graduatedDescription.text = NSLocalizedString("Please choose the school where you graudated AND upload either Medical Diploma OR ID Card(Driver License) to verify your identity.", comment: "In DoctorStartAdGraduateSchool, description for this page")
        
        //for description initailiaztion
        descriptionForDiploma.layer.borderWidth = 1.0
        descriptionForDiploma.layer.borderColor = UIColor.red.cgColor
        descriptionForDiploma.text = Storyboard.PhotoPrintForVerify
        
        descriptionForIDCard.layer.borderWidth = 1.0
        descriptionForIDCard.layer.borderColor = UIColor.red.cgColor
        descriptionForIDCard.text = Storyboard.PhotoPrintForVerify
        //setup
        invalidNotification.isHidden = true
        //setup navigation
        let graudateSchoolTitle = NSLocalizedString("Professional Education", comment: "In DoctorStartAdGraduateSchool's title")
        self.navigationItem.title = graudateSchoolTitle
        
        let rightNextNavigationButton = UIBarButtonItem(title: Storyboard.nextNavigationItemRightButton, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.nextButtonClicked))
        self.navigationItem.rightBarButtonItem = rightNextNavigationButton
        
        //add graduate back notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.graduateSchoolUpdate), name: NSNotification.Name(rawValue: "graduateSchoolBack"), object: nil)
        //add Default graduate school
        graduateSchoolUpdate()
        //add image set
        //setup Default Image
        imageDiploma()
        if signInUser?.doctorImageDiploma != nil{
            labelToUpload(medicalDiplomaLabel)
        }
        imageID()
        if signInUser?.doctorImageID != nil{
            labelToUpload(idCardLabel)
        }
    }
    
    fileprivate func imageDiploma(){
        if let imagedata = signInUser?.doctorImageDiploma {
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                var image = UIImage(data: imagedata)
                DispatchQueue.main.async {
                    self!.diplomaPresentImage.image = image
                    self!.diplomaHeight = self!.diplomaPresentImage.frame.width / image!.aspectRatio
                    image = nil
                }
            }
        }
    }
    
    fileprivate func imageID(){
        if let imagedata = signInUser?.doctorImageID {
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                var image = UIImage(data: imagedata)
                DispatchQueue.main.async {
                    self!.idCardImage.image = image
                    self!.idCardHeight = self!.idCardImage.frame.width / image!.aspectRatio
                    image = nil
                }
            }
        }
    }
    // MARK: - Graudated School
    func graduateSchoolUpdate(){
        if tempDoctor?.doctorGraduateSchool != nil {
            let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
            if langId.range(of: "en") != nil{
                graduatedLabel.text = School.school[Int(tempDoctor!.doctorGraduateSchool!)!][1]
            }else{
                graduatedLabel.text = School.school[Int(tempDoctor!.doctorGraduateSchool!)!][0]
            }
            graduatedLabel.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    func nextButtonClicked(){
        invalidNotification.isHidden = true
        //set back item's title to ""
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        if (tempDoctor?.doctorGraduateSchool != nil) && (signInUser?.doctorImageID != nil || signInUser?.doctorImageDiploma != nil){
            performSegue(withIdentifier: MVC.nextIdentifier, sender: nil)
        }else{
            invalidNotification.isHidden = false
            wiggleInvalidtext(invalidNotification, Duration: 0.03, RepeatCount: 10, Offset: 2)
        }
        
        
    }

    // MARK: - Medical Diploma
    var diplomaOrIDCard = false //false is diploma, true is ID Card
    var diplomaSection = 1
    @IBOutlet weak var diplomaPresentImage: UIImageView!
    @IBOutlet weak var diplomaCameraLabel: UIButton!
    
    @IBAction func tapDiplomaLabel() {
        if signInUser?.doctorImageDiploma == nil {
            diplomaOrIDCard = false
            getPhoto()
        }else{
            if diplomaSection == 1 {
                imageDiploma()
                diplomaSection = 2
            }else{
                diplomaSection = 1
            }
            tableView.reloadData()
        }
        if diplomaSection == 2 {
            let indexPath = IndexPath(row: 1, section: 1)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @IBAction func diplomaCameraButton() {
        diplomaOrIDCard = false
        getPhoto()
    }

    // MARK: - ID Card
    var idCardSection = 1
    @IBOutlet weak var idCardImage: UIImageView!
    @IBOutlet weak var idCardCameraLabel: UIButton!
    
    @IBAction func tapIDCardLabel() {
        if signInUser?.doctorImageID == nil {
            diplomaOrIDCard = true
            getPhoto()
        }else{
            if idCardSection == 1 {
                imageID()
                idCardSection = 2
            }else{
                idCardSection = 1
            }
            tableView.reloadData()
        }
        if idCardSection == 2 {
            let indexPath = IndexPath(row: 1, section: 2)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }

    @IBAction func idCardCameraButton() {
        diplomaOrIDCard = true
        getPhoto()
    }

    
    // MARK: - Photo
    func getPhoto(){
        // alert for chosing where to get new selfie
        //set a new AlertController
        let alertController = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        //set cancel action
        let cancelAction = UIAlertAction(title: Storyboard.CancelAlert, style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        //set Take a New Picture action
        let NewPicAction = UIAlertAction(title: Storyboard.TakeANewPictureAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = imagePickerControllerSingleton.singleton()
                picker.sourceType = .camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                //picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                print("In library")
                let picker = imagePickerControllerSingleton.singleton()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFont(ofSize: 17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .photoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
                //                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                //picker.allowsEditing = true
                picker.delegate = self //need UINavigationControllerDelegate
                self.present(picker, animated: true, completion: {
                    //change back to defaul Navigation bar colour after setting image from Photo Library
                    let navbarFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFont(ofSize: 17)
                    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont,NSForegroundColorAttributeName: UIColor.white]
                    UINavigationBar.appearance().tintColor = UIColor.white
                    }
                )
            }
        }
        alertController.addAction(profileAction)
        
        //for ipad popover
        alertController.modalPresentationStyle = .popover
        if let popoverController = alertController.popoverPresentationController{
            if !diplomaOrIDCard {
                popoverController.sourceView = diplomaCameraLabel
                popoverController.sourceRect = diplomaCameraLabel.bounds
            }else{
                popoverController.sourceView = idCardCameraLabel
                popoverController.sourceRect = idCardCameraLabel.bounds
            }
            
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func closemedicalDiplomaImage(_ sender: UITapGestureRecognizer) {
        diplomaSection = 1
        tableView.reloadData()
    }
    
    @IBAction func closeIDCardImage(_ sender: UITapGestureRecognizer) {
        idCardSection = 1
        tableView.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if !diplomaOrIDCard {
            image = resize.singleton(image! , container: diplomaPresentImage.image!)
            diplomaPresentImage.image = image
            diplomaHeight = diplomaPresentImage.frame.width / image!.aspectRatio
            labelToUpload(medicalDiplomaLabel)
            if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                //print("image size %f KB:", imageData.length / 1024)
                signInUser?.doctorImageDiploma = imageData
                image = nil
            }
            diplomaSection = 2
        }else{
            image = resize.singleton(image! , container: idCardImage.image!)
            idCardImage.image = image
            idCardHeight = idCardImage.frame.width / image!.aspectRatio
            labelToUpload(idCardLabel)
            if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
                //print("image size %f KB:", imageData.length / 1024)
                signInUser?.doctorImageID = imageData
                image = nil
            }
            idCardSection = 2
        }
        
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
            
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if !diplomaOrIDCard {
            signInUser?.doctorImageDiploma = nil
            labelnotSet(medicalDiplomaLabel)
        }else{
            signInUser?.doctorImageID = nil
            labelnotSet(idCardLabel)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func labelToUpload(_ label: UIButton){
        label.setTitle(Storyboard.uploaded, for: UIControlState())
        label.titleLabel!.font = UIFont.systemFont(ofSize: 17)
    }
    
    func labelnotSet(_ label: UIButton){
        label.setTitle(Storyboard.notSet, for: UIControlState())
        label.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0{
            return 1
        }else if section == 1{
            return diplomaSection
        }else {
            return idCardSection
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            return diplomaHeight
        }else if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 1 {
            return idCardHeight
        }
        return 60
    }
    
    // MARK: - prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let af = segue.destination as? DoctorStartAfSpecialistTableViewController{
            //pass current moc to next controller which use for create Persons object
            af.moc = self.moc!
            diplomaPresentImage.image = nil
            idCardImage.image = nil
            diplomaSection = 1
            idCardSection = 1
            tableView.reloadData()
        }
    }

}
