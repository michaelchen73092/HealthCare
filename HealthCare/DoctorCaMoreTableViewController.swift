//
//  DoctorCaMoreTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/17/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import testKit

@available(iOS 10.0, *)
class DoctorCaMoreTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    // MARK: - Variables
    @IBOutlet weak var selfieImageContainer: UIView!
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var editLabel: UIButton!
    @IBOutlet weak var userName: UILabel!
    // for save photoUrl to local CoreData
    var moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate struct MVC{
        static let accountIdentifier = "show Doctor Cb"
        static let logOutIdentifier = "show Login"
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    fileprivate func updateUI(){
        //setup selfie image container border
        selfieImageContainer.layer.borderWidth = 1
        selfieImageContainer.layer.borderColor = UIColor(netHex: 0xE6E6E6).cgColor
        updateImage()
    }

    func updateImage() {
        //setup Name
        let printName = printNameOrder(signInDoctor!.doctorFirstName!, lastName: signInDoctor!.doctorLastName!)
        userName.text = printName
        self.navigationItem.title = printName
        //setup Default Image
        if let imagedata = signInUser!.imageLocal {
            if let image = UIImage(data: imagedata){
                //let qos = Int(DispatchQoS.QoSClass.userInitiated.rawValue)
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
                    print("updateImage() Load User self image")
                    DispatchQueue.main.async {
                        self?.selfieImage.image = image
                    }
                }
            }
        }else{
            if signInUserPublic!.gender!.boolValue {
                selfieImage.image = UIImage(named:"FemaleImage.png")
            }else{
                selfieImage.image = UIImage(named:"MaleImage.png")
            }
        }
    }
    
    func printNameOrder(_ firstName: String, lastName: String) -> String{
        var returnName = ""
        let englishFormat = "(?=.*[A-Za-z]).*$"
        let englishPredicate = NSPredicate(format:"SELF MATCHES %@", englishFormat)
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        if langId.range(of: "en") != nil || englishPredicate.evaluate(with: firstName) || englishPredicate.evaluate(with: lastName) {
            returnName = Storyboard.doctorTitle+" "+firstName+" "+lastName
        }else if langId.range(of: "zh") != nil{
            returnName = lastName+firstName+" "+Storyboard.doctorTitle
        }else{
            returnName = Storyboard.doctorTitle+" "+firstName+" "+lastName
        }
        return returnName
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Image
    @IBAction func editSelfie() {
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
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.delegate = self //need UINavigationControllerDelegate
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
        }
        alertController.addAction(NewPicAction)
        //set Select From Library action
        let profileAction = UIAlertAction(title: Storyboard.FromPhotoLibraryAlert, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                print("In library")
                let picker = UIImagePickerController()
                //Set navigation back to default color
                let navbarDefaultFont = UIFont(name: "HelveticaNeue", size: 17) ?? UIFont.systemFont(ofSize: 17)
                UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarDefaultFont ,NSForegroundColorAttributeName: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor(netHex: 0x007AFF)
                picker.sourceType = .photoLibrary // default value is UIImagePickerControllerSourceTypePhotoLibrary.
                //                // if we were looking for video, we'd check availableMediaTypes
                picker.mediaTypes = [kUTTypeImage as String] //need import MobileCoreServices
                picker.allowsEditing = true
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
            popoverController.sourceView = editLabel
            //set popover from bonds rather than editLabel's view's original point
            popoverController.sourceRect = editLabel.bounds
            
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //image have to be editedImage
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        let compressionRate : CGFloat = 0.1
        //transfer to local disc first
        var imageSized : UIImage?
        imageSized =  resize.relfieSingleton(image!,remote: true)
        selfieImage.image = imageSized
        if let imageData = UIImageJPEGRepresentation(imageSized!, compressionRate) {
            print("after resize image size %f KB:", imageData.count / 1024)
            signInUser?.imageLocal = imageData
            savetoLocalCoredata(imageData)
            // also need to update to url
        }
        imageSized = nil
        image = nil
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func savetoLocalCoredata(_ imageData: Data){
        //let fetchRequestPerson = NSFetchRequest(entityName: "Persons")
        let fetchRequestPerson: NSFetchRequest<Persons> = Persons.fetchRequest() as! NSFetchRequest<Persons>
        //fetch a local user in HD
        
        do {
            let Personresults =  try moc.fetch(fetchRequestPerson)
            let person = Personresults //as! [NSManagedObject]
            person[0].setValue(imageData, forKey: "imageLocal")
            try moc.save()
            
        } catch let error as NSError {
            print("Could not fetch or Save \(error), \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 5
        }else{
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            let logOutTitle = NSLocalizedString("Log Out", comment: "In PersonsCaMore, alert title for log out.")
            let logOutDetail = NSLocalizedString("Are you sure you want to log out?", comment: "In PersonsCaMore, alert detail for log out.")
            let alert = UIAlertController(title: logOutTitle, message: logOutDetail, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Storyboard.ConfirmAlert, style: .default, handler: { [weak self] (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                signInUser = nil
                signInUserPublic = nil
                signInDoctor = nil
                self!.performSegue(withIdentifier: MVC.logOutIdentifier, sender: nil)
                }))
            
            alert.addAction(UIAlertAction(title: Storyboard.CancelAlert, style: .cancel, handler: { (action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == MVC.accountIdentifier{
                if let _ = segue.destination as? DoctorCbAccountTableViewController{
                    let backItem = UIBarButtonItem()
                    backItem.title = ""
                    self.navigationItem.backBarButtonItem = backItem
                }
            }
        }
    }

}
