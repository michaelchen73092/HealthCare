//
//  DoctorStartAjSpecialtyTitleTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/4/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices

class DoctorStartAjSpecialtyTitleTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleOne: UILabel!
    @IBOutlet weak var titleTwo: UILabel!
    @IBOutlet weak var titleThree: UILabel!
    @IBOutlet weak var certificationImage: UIImageView!
    
    
    @IBOutlet weak var specialtyTitleDescription: UILabel!
    @IBOutlet weak var boardCertificationDescription: UIButton!
    @IBOutlet weak var boardCertificationCamera: UIButton!

    
    var lastIndex : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        //initial setup
        if signInUser?.doctorImageSpecialistLicense != nil{
            labelToUpload(boardCertificationDescription)
        }else{
            labelnotSet(boardCertificationDescription)
        }
        //for description initailiaztion
        bcDescriptionLabel.layer.borderWidth = 1.0
        bcDescriptionLabel.layer.borderColor = UIColor.red.cgColor
        bcDescriptionLabel.text = Storyboard.PhotoPrintForVerify
        titleOne.text = specialty.title[0]
        titleTwo.text = specialty.title[1]
        titleThree.text = specialty.title[2]
        certificationImage.isHidden = true
        //setup navigation
        let titleTitle = NSLocalizedString("Specialty Title", comment: "In DoctorStartAjSpecialtyTitle's title")
        self.navigationItem.title = titleTitle
        let backNavigationButton = UIBarButtonItem(title: Storyboard.backNavigationItemLeftButton , style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        self.navigationItem.leftBarButtonItem = backNavigationButton
        
        let description = NSLocalizedString("Please select your status(title). If you have obtained board certified, please upload your license for verifying. You will get an license logo in your introduction when user searches you.", comment: "In DoctorStartAjSpecialtyTitle's, descript for doctor to select their title and upload license if they have.")
        specialtyTitleDescription.text = description
        // deal with previous checkmark
        if tempDoctor?.doctorProfessionTitle != nil {
            switch(Int(tempDoctor!.doctorProfessionTitle!)!){
            case 0 :
                lastIndex = IndexPath(row: 0, section: 0)
            case 1 :
                lastIndex = IndexPath(row: 1, section: 0)
            default :
                lastIndex = IndexPath(row: 2, section: 0)
            }
            let cell = tableView.cellForRow(at: lastIndex!)
            cell?.accessoryType = .checkmark
        }
        //setup image
        imageSpecialtyLicense()
        if signInUser?.doctorImageSpecialistLicense !=  nil{
            labelToUpload(boardCertificationDescription)
            certificationImage.isHidden = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if lastIndex != nil{
            let cell = tableView.cellForRow(at: lastIndex!)
            cell?.accessoryType = .checkmark
            lastIndex = nil
        }
    }
    
    fileprivate func imageSpecialtyLicense(){
        if let imagedata = signInUser?.doctorImageSpecialistLicense {
            //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                var image = UIImage(data: imagedata)
                DispatchQueue.main.async {
                    self!.bcPresentImage.image = image
                    self!.bcHeight = self!.bcPresentImage.frame.width / image!.aspectRatio
                    image = nil
                }
            }
        }
    }
    
    @objc
    fileprivate func backButtonClicked(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SpecialtyTitleBack"), object: self, userInfo: nil )
        navigationController?.popViewController(animated: true)
        bcPresentImage.image = nil
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
    
    // MARK: - Board Certification
    var boardCertificationSection = 1
    var bcHeight = CGFloat(60)
    
    @IBOutlet weak var bcPresentImage: UIImageView!
    @IBOutlet weak var bcDescriptionLabel: UILabel!
    
    @IBAction func tapBoardCertification() {
        if signInUser?.doctorImageSpecialistLicense == nil{
            getPhoto()
        }else{
            if boardCertificationSection == 1{
                boardCertificationSection = 2
            }else{
                boardCertificationSection = 1
            }
            tableView.reloadData()
        }
        if boardCertificationSection == 2 {
            let indexPath = IndexPath(row: 1, section: 1)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @IBAction func bcCameraButton() {
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
            popoverController.sourceView = boardCertificationCamera
            popoverController.sourceRect = boardCertificationCamera.bounds
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //since under table view its deal with data, so it may not deal with it in main queue,
        //we should dispatch back to main queue for add image update here
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        image = resize.singleton(image! , container: bcPresentImage.image!)
        bcPresentImage.image = image
        bcHeight = bcPresentImage.frame.width / image!.aspectRatio
        labelToUpload(boardCertificationDescription)
        if let imageData = UIImageJPEGRepresentation(image!, 0.5) {
            //print("image size %f KB:", imageData.length / 1024)
            signInUser?.doctorImageSpecialistLicense = imageData
            image = nil
        }
        boardCertificationSection = 2
        certificationImage.isHidden = false
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        signInUser?.doctorImageSpecialistLicense = nil
        labelnotSet(boardCertificationDescription)
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 3
        }else{
            return boardCertificationSection
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            return bcHeight
        }
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0{
            var index = IndexPath(row: 0, section: 0)
            var cell = tableView.cellForRow(at: index)
            for i in 0...2 {
                index = IndexPath(row: i, section: 0)
                cell = tableView.cellForRow(at: index)
                cell!.accessoryType = .none
            }
            index = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
            cell = tableView.cellForRow(at: index)
            cell!.accessoryType = .checkmark
            tempDoctor?.doctorProfessionTitle = String((indexPath as NSIndexPath).row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
