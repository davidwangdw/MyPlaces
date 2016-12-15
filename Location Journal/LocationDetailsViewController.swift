//
//  LocationDetailsViewController.swift
//  Location Journal
//
//  Created by David Wang on 12/15/16.
//  Copyright © 2016 David Wang. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var categoryName = "No Category"
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var date = Date()
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    @IBAction func done() {
        // 1
        let location = Location(context: managedObjectContext)
        // 2
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        // 3
        do {
            try managedObjectContext.save()
            print("Data Saved")
        } catch {
            fatalError("Error: \(error)")
        }
    }
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        dateLabel.text = format(date: date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0
            && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue)
    {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }

    // MARK: - Navigation

     override func tableView(_ tableView: UITableView,
     willSelectRowAt indexPath: IndexPath) -> IndexPath? {
     if indexPath.section == 0 || indexPath.section == 1 {
     return indexPath
     } else {
     return nil
     }
     }
     override func tableView(_ tableView: UITableView,
     didSelectRowAt indexPath: IndexPath) {
     if indexPath.section == 0 && indexPath.row == 0 {
     descriptionTextView.becomeFirstResponder()
     }
     
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
