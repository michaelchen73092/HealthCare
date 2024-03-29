//
//  DoctorStarAkSearchAddressTableViewController.swift
//  BoBiHealth
//
//  Created by CHENWEI CHIH on 8/5/16.
//  Copyright © 2016 OnlineDoc.inc. All rights reserved.
//

import UIKit
import MapKit

class DoctorStarAkSearchAddressTableViewController: UITableViewController, UISearchResultsUpdating  {

    // MARK: - Variables
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView!
    var resultSearchController = UISearchController()
    
    // MARK: - Address for UISearchResultsUpdating
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    //confirm UISearchResultsUpdating protocal
    func updateSearchResults(for searchController: UISearchController) {
        let searchBarText = searchController.searchBar.text!
        if searchBarText != ""{
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBarText
            ////request.region = mapView.region  //we don't have mapView.region here
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    //print("in search.startWithCompletionHandler ")
                    return
                }
                self.matchingItems = response.mapItems
                //print("self.matchingItems count:\(self.matchingItems.count)")
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var searchAddressDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup navigation bar, set back button title in PersonsCb's manuallySearchCity()
        let searchAddressTitle = NSLocalizedString("Hospital Address", comment: "In DoctorStarAkSearchAddress, search hospital address")
        self.navigationItem.title = searchAddressTitle
        let description = NSLocalizedString("Please type address of your current hospital or clinic. This help user finds you on map.", comment: "In DoctorStarAkSearchAddress, search hospital address description")
        searchAddressDescription.text = description
        
        //setup search bar
        resultSearchController = UISearchController(searchResultsController: nil)
        //UISearchResultsUpdating needs confirm protocal
        resultSearchController.searchResultsUpdater = self
        
        //set SearchController UI
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        //set searchBar color as our App blue
        resultSearchController.searchBar.barTintColor = UIColor(netHex: 0x400080)
        //set "cancel" button to white color
        resultSearchController.searchBar.tintColor = UIColor.white
        //set searchbar on navigationbar
        resultSearchController.searchBar.placeholder = "Search Address"
        tableView.tableHeaderView = resultSearchController.searchBar
        
        tableView.reloadData()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("matchingItems.count: \(matchingItems.count)")
        return matchingItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[(indexPath as NSIndexPath).row].placemark
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(parseAddress(selectedItem)) { (placemarks, error) in
            if((error) != nil){
                print("Error:", error!)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                tempDoctor?.doctorHospitalLatitude = coordinates.latitude as NSNumber?
                tempDoctor?.doctorHospitalLongitude = coordinates.longitude as NSNumber?
                print("tempDoctor?.doctorHospitalLatitude:\(tempDoctor?.doctorHospitalLatitude)")
                print("tempDoctor?.doctorHospitalLongitude:\(tempDoctor?.doctorHospitalLongitude)")
                if signInDoctor?.doctorHospitalLatitude != nil && signInDoctor?.doctorHospitalLongitude != nil && !(signInDoctor!.doctorHospitalLatitude! == 0 && signInDoctor!.doctorHospitalLongitude! == 0){
                    signInDoctor?.doctorHospitalLatitude = coordinates.latitude as NSNumber?
                    signInDoctor?.doctorHospitalLongitude = coordinates.longitude as NSNumber?
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "HospitalAddress"), object: self, userInfo: nil )
                print("In Search City, viewController")
            }
        }
        
        resultSearchController.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
