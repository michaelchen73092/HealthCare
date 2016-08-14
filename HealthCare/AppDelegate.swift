//
//  AppDelegate.swift
//  HealthCare
//
//  Created by CHENWEI CHIH on 6/16/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//

import UIKit
import CoreData
import AWS_Kit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Setting Front color and size for All NavigationBar
        let navbarFont = UIFont(name: "HelveticaNeue-Light", size: 20) ?? UIFont.systemFontOfSize(17)
        registerForPushNotification(application)
        //UINavigationBar.appearance().barTintColor = UIColor(netHex: 0x003366)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navbarFont,NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Push Notification
    var token:String?
    func registerForPushNotification(application: UIApplication){
        print("Function: \(#function), line: \(#line)")
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert],categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print("Function: \(#function), line: \(#line)")
        if notificationSettings.types != .None {
            print("get permission for remoteNotifications")
            application.registerForRemoteNotifications()
        }
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Function: \(#function), line: \(#line)")
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        for i in 0..<deviceToken.length {
            tokenString +=  String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        token = tokenString
        print("Device Token:",tokenString)
        
        
        //update token
        /*let token2 = NSEntityDescription.insertNewObjectForEntityForName("APNs", inManagedObjectContext: managedObjectContext)
         var token_arry = [NSManagedObject]()
         token2.setValue("Chien-Lin", forKey: "firstname")
         token2.setValue("zero064@gmail.com", forKey: "email")
         token2.setValue("Chen", forKey: "lastname")
         token2.setValue(token, forKey: "token")
         token_arry.append(token2)
         
         let  obj_pari = ["APNs":token_arry]
         dynamoDBManger.dynamoDB.batchWriteItem(dynamoDBManger.transTowrite(obj_pari))*/
        
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Function: \(#function), line: \(#line)")
        print("Failed to register:",error)
    }
    func application(application: UIApplication,didReceiveRemoteNotification userInfo: [NSObject : AnyObject],fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        print("Function: \(#function), line: \(#line)")
        let aps = userInfo["aps"] as! [String:AnyObject]
        handleNotification(aps)
        completionHandler(.NewData)
        
        
    }
    func handleNotification(aps:[String:AnyObject]){
        let message = aps["alert"] as! String
        print(message)
    }
    
    
    
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "HealthCare.inc.HealthCare" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        //creat new framework bundle - Wei-Chih Chen
        let PersonsKitBundle = NSBundle(identifier: "BoBiHealth.testKit")
        assert(PersonsKitBundle != nil, "Not assign correct Bundle identifier. In function: \(#function),")
        let modelURL = PersonsKitBundle!.URLForResource("PersonsModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}



// MARK: - Public function
//Define Color by HEX type
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

//for exclude emoji in name
extension String {
    func containsEmoji() -> Bool {
        for i in self.characters {
            if i.isEmoji() {
                return true
            }
        }
        return false
    }
}

extension Character {
    func isEmoji() -> Bool {
        return Character(UnicodeScalar(0x1d000)) <= self && self <= Character(UnicodeScalar(0x1f77f))
            || Character(UnicodeScalar(0x1f900)) <= self && self <= Character(UnicodeScalar(0x1f9ff))
            || Character(UnicodeScalar(0x2100)) <= self && self <= Character(UnicodeScalar(0x26ff))
    }
}


//check email format
public func validateEmail(enteredEmail:String) -> Bool {
    let emailFormat = "[A-Z0-9a-z._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluateWithObject(enteredEmail)
    
}

//check name format
public func validateName(enteredName:String) -> Bool {
    // \\before execute simple turn execute simple as pure simple
    // use \\\\ to pure \ simple
    let nameFormat = "(?=.*[€£¥•~`!@#$%^&*()_+=,.:;<>?/{}\\[\\]|\\\\0123456789]).*$"
    let namePredicate = NSPredicate(format:"SELF MATCHES %@", nameFormat)
    
    return namePredicate.evaluateWithObject(enteredName) || enteredName.containsEmoji() || (enteredName.rangeOfString(" ") != nil)
}


//check password format
public func validatePassword(enteredPassword: String) -> Bool {
    // patten at least 6 characters : (?=^.{6,}$)
    // patten has at least a special words : (?=.*[!@#$%^&*]+)
    // patten has a number : (?=.*[0-9])
    // patten has a letter words : (?=.*[A-Za-z])
    let passwordFormat = "(?=^.{6,}$)(?=.*[!@#$%^&*()+])(?=.*[0-9])(?=.*[A-Za-z]).*$"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
    return emailPredicate.evaluateWithObject(enteredPassword)
}


//check password format
public func validateNumberOnly(entered: String) -> Bool {
    // patten at least 6 characters : (?=^.{6,}$)
    // patten has at least a special words : (?=.*[!@#$%^&*]+)
    // patten has a number : (?=.*[0-9])
    // patten has a letter words : (?=.*[A-Za-z])
    let numberFormat = "(?=.*[0-9]).*$"
    let numberPredicate = NSPredicate(format:"SELF MATCHES %@", numberFormat)
    return numberPredicate.evaluateWithObject(entered)
}

//check Resident Date format
public func validateResidentDate(enteredResidentDate:String) -> Bool {
    let ResidentDateFormat = "[0-9]{2,2}+/[0-9]{4,4}"
    let ResidentDatePredicate = NSPredicate(format:"SELF MATCHES %@", ResidentDateFormat)
    if let sliceNotation = enteredResidentDate.rangeOfString("/"){
        let month = Int(enteredResidentDate[enteredResidentDate.startIndex..<sliceNotation.startIndex])
        let year = Int(enteredResidentDate[sliceNotation.endIndex..<enteredResidentDate.endIndex])
        let currentdate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month , .Year], fromDate: currentdate)
        let currentyear =  Int(components.year)
        if month >= 1 && month <= 12 && year <= currentyear && year >= (currentyear - 15){
            return ResidentDatePredicate.evaluateWithObject(enteredResidentDate)
        }
    }
    return false
}

//check phone format
public func validatePhone(enteredPhone:String) -> Bool {
    let usaFormat = "^\\d{3}-\\d{3}-\\d{4}$"
    let usaPredicate = NSPredicate(format:"SELF MATCHES %@", usaFormat)
    let twFormat = "^09\\d{2}-\\d{3}-\\d{3}$"
    let twPredicate = NSPredicate(format:"SELF MATCHES %@", twFormat)
    let twHomeFormat = "^\\(\\d{2}\\)\\d{7,9}$"
    let twHomePredicate = NSPredicate(format:"SELF MATCHES %@", twHomeFormat)
    let allFormat = "^\\d{10}$"
    let allPredicate = NSPredicate(format:"SELF MATCHES %@", allFormat)
    return usaPredicate.evaluateWithObject(enteredPhone) || twPredicate.evaluateWithObject(enteredPhone) || twHomePredicate.evaluateWithObject(enteredPhone) || allPredicate.evaluateWithObject(enteredPhone)
}

//wiggle animation
public func wiggle(Field: UITextField, Duration: Double, RepeatCount: Float, Offset: CGFloat)
{
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = Duration
    animation.repeatCount = RepeatCount
    animation.autoreverses = true
    animation.fromValue = NSValue(CGPoint: CGPointMake(Field.center.x - Offset, Field.center.y))
    animation.toValue = NSValue(CGPoint: CGPointMake(Field.center.x + Offset, Field.center.y))
    Field.layer.addAnimation(animation, forKey: "position")
}

public func wiggleInvalidtext(Field: UILabel, Duration: Double, RepeatCount: Float, Offset: CGFloat)
{
    let animation = CABasicAnimation(keyPath: "position")
    animation.duration = Duration
    animation.repeatCount = RepeatCount
    animation.autoreverses = true
    animation.fromValue = NSValue(CGPoint: CGPointMake(Field.center.x - Offset, Field.center.y))
    animation.toValue = NSValue(CGPoint: CGPointMake(Field.center.x + Offset, Field.center.y))
    Field.layer.addAnimation(animation, forKey: "position")
}

//global variable
public struct Storyboard {
    static let moveheight = CGFloat(70) // how much height should move when KB is shown
    static var KBisON = false // set for recording KB is ON/OFF
    static let color: UIColor = UIColor(netHex: 0x003366)
    static let nextNavigationItemRightButton = NSLocalizedString("Next", comment: "All navigation item for right button")
    static let editNavigationItemRightButton = NSLocalizedString("Edit", comment: "Navigation item for right button")
    static let backNavigationItemLeftButton = NSLocalizedString("Back", comment: "All navigation item for left going back button")
    static let notSet = NSLocalizedString("Not Set", comment: "String for all person data is not set")
    static let uploaded = NSLocalizedString("Image Uploaded", comment: "String for doctor image is uploaded")
    static let CancelAlert = NSLocalizedString("Cancel", comment: "For all alert to access photo library")
    static let ConfirmAlert = NSLocalizedString("Confirm", comment: "In DoctorAbOnlineWaitlist, for confirm change doctor status.")
    static let TakeANewPictureAlert = NSLocalizedString("Take a New Picture", comment: "For all alert to access photo library")
    static let FromPhotoLibraryAlert = NSLocalizedString("From Photo Library", comment: "For all alert to access photo library")
    static let PhotoPrintForVerify = NSLocalizedString(" This document for Berbi verify doctor's identity only!", comment: "For all doctor's documentation, we need to print this line for safy issue")
    static let male = NSLocalizedString("Male", comment: "Male")
    static let female = NSLocalizedString("Female", comment: "Female")
    static let offLine = NSLocalizedString("Offline", comment: "In DoctorStartAfSpecialist's offline status")
    static let onLine = NSLocalizedString("Online", comment: "In DoctorStartAfSpecialist's online status")
    static let yearsOld = NSLocalizedString("Years Old", comment: "In patient waitlist, tell how old this patient is")
}

//dismiss KB no matter which textfield is hitted
public func dismissKB(textField: UITextField, textField2: UITextField?, vc: UIViewController){
    if Storyboard.KBisON {
        vc.view.frame.origin.y += Storyboard.moveheight
        Storyboard.KBisON = false
        textField.resignFirstResponder()
        textField2?.resignFirstResponder()
    }
}

//singleton for UIImagePickerController
public class imagePickerControllerSingleton{
    static var token: dispatch_once_t = 0 //for thread safe
    private static var picker: UIImagePickerController?
    static func singleton() -> UIImagePickerController{
        if picker == nil{
            dispatch_once(&token, {
                picker = UIImagePickerController()
                })
            
        }
        return picker!
    }
}

//singleton for resize
public class resize{
    static func singleton(image: UIImage, container: UIImage) -> UIImage{
        let scale = max(container.size.height / image.size.height, container.size.width / image.size.width)
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(scale, scale))
        let autoScale : CGFloat = 0.0
        UIGraphicsBeginImageContextWithOptions(size, true, autoScale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
//application status
public struct Status{
    static let underReview = "Under Review"
    static let userModeNotApply = "User Mode Not Apply"

}

public struct Language {
    static let languageChinese = NSLocalizedString("Chinese", comment: "Language category")
    static let languageCantonese = NSLocalizedString("Cantonese", comment: "Language category")
    static let languageTaiwanese = NSLocalizedString("Taiwanese", comment: "Language category")
    static let languageEnglish = NSLocalizedString("English", comment: "Language category")
    static let languageFrench = NSLocalizedString("French", comment: "Language category")
    static let languageGerman = NSLocalizedString("German", comment: "Language category")
    static let languageJapanese = NSLocalizedString("Japanese", comment: "Language category")
    static let languageDutch = NSLocalizedString("Dutch", comment: "Language category")
    static let languageItalian = NSLocalizedString("Italian", comment: "Language category")
    static let languageSpanish = NSLocalizedString("Spanish", comment: "Language category")
    static let languageKorean = NSLocalizedString("Korean", comment: "Language category")
    static let languagePortuguese = NSLocalizedString("Portuguese", comment: "Language category")
    static let languageDanish = NSLocalizedString("Danish", comment: "Language category")
    static let languageFinnish = NSLocalizedString("Finnish", comment: "Language category")
    static let languageNorwegian = NSLocalizedString("Norwegian", comment: "Language category")
    static let languageSwedish = NSLocalizedString("Swedish", comment: "Language category")
    static let languageRussian = NSLocalizedString("Russian", comment: "Language category")
    static let languagePolish = NSLocalizedString("Polish", comment: "Language category")
    static let languageTurkish = NSLocalizedString("Turkish", comment: "Language category")
    static let languageUkrainian = NSLocalizedString("Ukrainian", comment: "Language category")
    static let languageArabic = NSLocalizedString("Arabic", comment: "Language category")
    static let languageCroatian = NSLocalizedString("Croatian", comment: "Language category")
    static let languageCzech = NSLocalizedString("Czech", comment: "Language category")
    static let languageGreek = NSLocalizedString("Greek", comment: "Language category")
    static let languageHebrew = NSLocalizedString("Hebrew", comment: "Language category")
    static let languageRomanian = NSLocalizedString("Romanian", comment: "Language category")
    static let languageSlovak = NSLocalizedString("Slovak", comment: "Language category")
    static let languageThai = NSLocalizedString("Thai", comment: "Language category")
    static let languageIndonesian = NSLocalizedString("Indonesian", comment: "Language category")
    static let languageMalay = NSLocalizedString("Malay", comment: "Language category")
    static let languageCatalan = NSLocalizedString("Catalan", comment: "Language category")
    static let languageHungarian = NSLocalizedString("Hungarian", comment: "Language category")
    static let languageVietnamese = NSLocalizedString("Vietnamese", comment: "Language category")
    static let languageHindi = NSLocalizedString("Hindi", comment: "Language category")
    static let languageBengali = NSLocalizedString("Bengali", comment: "Language category")
    
    static let allLanguage = [Language.languageArabic, Language.languageBengali, Language.languageCantonese, Language.languageCatalan, Language.languageChinese, Language.languageCroatian, Language.languageCzech, Language.languageDanish, Language.languageDutch, Language.languageEnglish, Language.languageFinnish, Language.languageFrench, Language.languageGerman, Language.languageGreek, Language.languageHebrew, Language.languageHindi, Language.languageHungarian, Language.languageIndonesian, Language.languageItalian, Language.languageJapanese, Language.languageKorean, Language.languageMalay, Language.languageNorwegian, Language.languagePolish, Language.languagePortuguese, Language.languageRomanian, Language.languageRussian, Language.languageSlovak, Language.languageSpanish, Language.languageSwedish, Language.languageTaiwanese, Language.languageThai, Language.languageTurkish, Language.languageUkrainian, Language.languageVietnamese]
}



public struct School{
    static let school = [
            ["國立台灣大學醫學院醫學系", "National Taiwan University School of Medicine"],
            ["國立陽明大學醫學系", "National Yang Ming University School of Medicine"],
            ["國立成功大學醫學院醫學系", "National Cheng Kung University School of Medicine"],
            ["國防醫學院醫學系", "National Defense Medical Center School of Medicine"],
            ["台北醫學大學醫學系", "Taipei Medical University School of Medicine"],
            ["輔仁大學醫學院", "Fu Jen Catholic University School of Medicine"],
            ["長庚大學醫學院醫學系", "Chang Gung University School of Medicine"],
            ["中國醫藥大學醫學系", "China Medical University School of Medicine"],
            ["中國醫藥大學中醫學系","School of Chinese Medicine"],
            ["中山醫學大學醫學系", "Chung Shan Medical University School of Medicine"],
            ["高雄醫學大學醫學系", "Kaohsiung Medical University School of Medicine"],
            ["慈濟醫學院醫學系", "Tzu Chi University School of Medicine"],
            ["慈濟醫學院學士後中醫系", "Tzu Chi University School of Post-Baccalaureate Chinese Medicine"],
            ["馬偕醫學院醫學系","Mackay Medical College Department of Medicine"],
            ["國立台灣大學牙醫學系", "National Taiwan University School of Dentistry"],
            ["國立陽明大學牙醫學系", "National Yang Ming University School of Dentistry"],
            ["臺北醫學大學牙醫學系", "Taipei Medical University School of Dentistry"],
            ["中國醫藥大學牙醫學系", "China Medical University School of Dentistry"],
            ["中山醫學大學牙醫學系", "Chung Shan Medical University School of Dentistry"],
            ["高雄醫學大學牙醫學系", "Kaohsiung Medical University School of Dentistry"],
            ["義守大學學士後中醫學系","I-Shou University The School of Chinese Medicine for Post Baccalaureate"],
            ["其他","School of Medicine in other school"]
    ]
}

public struct specialty{
    static let AllergyandImmunology = NSLocalizedString("Allergy and Immunology", comment: "Specialty category")
    static let Anesthesiology = NSLocalizedString("Anesthesiology", comment: "Specialty category")
    static let Cardiologist = NSLocalizedString("Cardiologist", comment: "Specialty category")
    static let ChineseMedicine = NSLocalizedString("Chinese Medicine", comment: "Specialty category")
    static let ColonandRectalSurgery = NSLocalizedString("Colon and Rectal Surgery", comment: "Specialty category")
    static let CosmeticSurgery = NSLocalizedString("Cosmetic Surgery", comment: "Specialty category")
    static let Dentist = NSLocalizedString("Dentist", comment: "Specialty category")
    static let Dermatology = NSLocalizedString("Dermatology", comment: "Specialty category")
    static let EmergencyMedicine = NSLocalizedString("Emergency Medicine", comment: "Specialty category")
    static let Endocrinologist = NSLocalizedString("Endocrinologist", comment: "Specialty category")
    static let FamilyMedicine = NSLocalizedString("Family Medicine", comment: "Specialty category")
    static let Gastroenterologist = NSLocalizedString("Gastroenterologist", comment: "Specialty category")
    static let InternalMedicine = NSLocalizedString("Internal Medicine", comment: "Specialty category")
    static let InfectiousDiseasesSpecialist = NSLocalizedString("Infectious Diseases Specialist", comment: "Specialty category")
    static let MedicalGeneticsandGenomics = NSLocalizedString("Medical Genetics and Genomics", comment: "Specialty category")
    static let NeurologicalSurgery = NSLocalizedString("Neurological Surgery", comment: "Specialty category")
    static let Neurology = NSLocalizedString("Neurology", comment: "Specialty category")
    static let NuclearMedicine = NSLocalizedString("Nuclear Medicine", comment: "Specialty category")
    static let ObstetricsandGynecology = NSLocalizedString("Obstetrics and Gynecology", comment: "Specialty category")
    static let Oncologist = NSLocalizedString("Oncologist", comment: "Specialty category")
    static let Ophthalmology = NSLocalizedString("Ophthalmology", comment: "Specialty category")
    static let OrthopaedicSurgery = NSLocalizedString("Orthopaedic Surgery", comment: "Specialty category")
    static let Otolaryngology = NSLocalizedString("Otolaryngology", comment: "Specialty category")
    static let Pathology = NSLocalizedString("Pathology", comment: "Specialty category")
    static let Pediatrics = NSLocalizedString("Pediatrics", comment: "Specialty category")
    static let PhysicalMedicineandRehabilitation = NSLocalizedString("Physical Medicine and Rehabilitation", comment: "Specialty category")
    static let PlasticSurgery = NSLocalizedString("Plastic Surgery", comment: "Specialty category")
    static let PreventiveMedicine = NSLocalizedString("Preventive Medicine", comment: "Specialty category")
    static let Psychiatry = NSLocalizedString("Psychiatry", comment: "Specialty category")
    static let Radiology = NSLocalizedString("Radiology", comment: "Specialty category")
    static let SurgeryGeneralSurgery = NSLocalizedString("Surgery (General Surgery)", comment: "Specialty category")
    static let ThoracicSurgery = NSLocalizedString("Thoracic Surgery", comment: "Specialty category")
    static let Urology = NSLocalizedString("Urology", comment: "Specialty category")
    static let VascularSurgeon = NSLocalizedString("Vascular Surgeon", comment: "Specialty category")
    static let Other = NSLocalizedString("Other", comment: "Specialty category")
    
    static let allSpecialty = [AllergyandImmunology, Anesthesiology, Cardiologist, ChineseMedicine, ColonandRectalSurgery, CosmeticSurgery, Dentist, Dermatology, EmergencyMedicine, Endocrinologist, FamilyMedicine, Gastroenterologist, InfectiousDiseasesSpecialist, InternalMedicine, MedicalGeneticsandGenomics, NeurologicalSurgery, Neurology, NuclearMedicine, ObstetricsandGynecology, Oncologist, Ophthalmology, OrthopaedicSurgery, Otolaryngology, Pathology, Pediatrics, PhysicalMedicineandRehabilitation, PlasticSurgery, PreventiveMedicine, Psychiatry, Radiology, SurgeryGeneralSurgery, ThoracicSurgery, Urology, VascularSurgeon, Other]
    
    static let Residents = NSLocalizedString("Residents", comment: "Specialty category")
    static let Fellows = NSLocalizedString("Fellows", comment: "Specialty category")
    static let Attendings = NSLocalizedString("Attendings", comment: "Specialty category")
    static let title = [Residents, Fellows, Attendings]
}

public struct Ethnicity{
    static let AfricanAmerican = NSLocalizedString("African American", comment: "Ethnicity category")
    static let Chinese = NSLocalizedString("Chinese", comment: "Ethnicity category")
    static let EastAfrican = NSLocalizedString("East African", comment: "Ethnicity category")
    static let EastAsian = NSLocalizedString("East Asian", comment: "Ethnicity category")
    static let Fijian = NSLocalizedString("Fijian", comment: "Ethnicity category")
    static let HispanicorLatinAmerican = NSLocalizedString("Hispanic or Latin American", comment: "Ethnicity category")
    static let Indian = NSLocalizedString("Indian", comment: "Ethnicity category")
    static let Maori = NSLocalizedString("Maori", comment: "Ethnicity category")
    static let MiddleEastern = NSLocalizedString("Middle Eastern", comment: "Ethnicity category")
    static let NZEuropeanorPakeha = NSLocalizedString("NZ European or Pakeha", comment: "Ethnicity category")
    static let NativeAmericanorInuit = NSLocalizedString("Native American or Inuit", comment: "Ethnicity category")
    static let NativeHawaiian = NSLocalizedString("Native Hawaiian", comment: "Ethnicity category")
    static let Niuean = NSLocalizedString("Niuean", comment: "Ethnicity category")
    static let Other = NSLocalizedString("Other", comment: "Ethnicity category")
    static let OtherPacificPeoples = NSLocalizedString("Other Pacific Peoples", comment: "Ethnicity category")
    static let Samoan = NSLocalizedString("Samoan", comment: "Ethnicity category")
    static let SouthAsian = NSLocalizedString("South Asian", comment: "Ethnicity category")
    static let SouthEastAsian = NSLocalizedString("South East Asian", comment: "Ethnicity category")
    static let Tokelauan = NSLocalizedString("Tokelauan", comment: "Ethnicity category")
    static let Tongan = NSLocalizedString("Tongan", comment: "Ethnicity category")
    static let WhiteorCaucasian = NSLocalizedString("White or Caucasian", comment: "Ethnicity category")
    
    static let ethnicity = [AfricanAmerican, Chinese, EastAfrican, EastAsian, Fijian, HispanicorLatinAmerican, Indian, Maori, MiddleEastern, NZEuropeanorPakeha, NativeAmericanorInuit, NativeHawaiian, Niuean, Other, OtherPacificPeoples, Samoan, SouthAsian, SouthEastAsian, Tokelauan, Tongan, WhiteorCaucasian]
    
}


//from index to print string
public func printLanguage(tempDoctordoctorLanguage: String ) -> String{
    //need to check if tempDoctor?.doctorLanguage != nil && tempDoctor?.doctorLanguage != ""
    var languageString = ""
    var tempDoctorLanguage = tempDoctordoctorLanguage
    while(tempDoctorLanguage != ""){
        var temp = ""
        if let decimalRange = tempDoctorLanguage.rangeOfString(" ,"){
            temp = tempDoctorLanguage[tempDoctorLanguage.startIndex..<decimalRange.startIndex]
            // it's possible there are two blank
            if let blank = temp.rangeOfString(" "){
                temp.removeAtIndex(blank.startIndex)
            }
            if let blank = temp.rangeOfString(" "){
                temp.removeAtIndex(blank.startIndex)
            }
            tempDoctorLanguage.removeRange(tempDoctorLanguage.startIndex..<decimalRange.endIndex)
        }
        else if tempDoctorLanguage != ""{
            temp = tempDoctorLanguage
            if let blank = temp.rangeOfString(" "){
                temp.removeAtIndex(blank.startIndex)
            }
            if let blank = temp.rangeOfString(" "){
                temp.removeAtIndex(blank.startIndex)
            }
            tempDoctorLanguage = ""
        }
        // write to languageStirng
        if languageString == ""{
            languageString = Language.allLanguage[Int(temp)!]
        }else{
            languageString = languageString + ", " + Language.allLanguage[Int(temp)!]
        }
    }
    //            //use for loop, go though all language
    //            for i in 0...(Language.allLanguage.count - 1){
    //                if let _ = tempDoctor!.doctorLanguage!.rangeOfString(" " + String(i) + " "){
    //                    // for first string, no ", "
    //                    if languageString == ""{
    //                        languageString = Language.allLanguage[i]
    //                    }else{
    //                        languageString = languageString + ", " + Language.allLanguage[i]
    //                    }
    //                }
    //            }
    
    return languageString
}


//personal medical record
public struct medicalRecord{
    let time : NSDate?
    let duration : Int?
    let doctorFirstName : String?
    let doctorLastName : String?
    let doctorImageRemoteURL : String?
    let diseases : [String]?
    let medicines : [String]?
    let treatment : [String]?
    let referral : Bool?
}
