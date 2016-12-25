//
//  CategoryPickerViewController.swift
//  Location Journal
//
//  Created by David Wang on 12/15/16.
//  Copyright © 2016 David Wang. All rights reserved.
//

import UIKit
class CategoryPickerViewController: UITableViewController {
    
    //using a UserDefaults object to store the data array for categories
    let categoryDefaults = UserDefaults.standard
    
    //default categories, will be able to change/edit later
    var categories = [
        "No Category",
        "Come Back Later",
        "Friends",
        "Photography Spot",
        "Resturant",
        "Shop",
        "To Do"]
  
    @IBAction func addCategory(_ sender: Any) {
        let alert = UIAlertController(title: "Add Category", message: "Enter a category", preferredStyle: .alert)
        //Add the text input field
        alert.addTextField { (textField) in textField.text = "" }
        
        //Grab the value from the text field
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            //add value to categories array
            print("Text field: \(textField?.text)")
        }))
        
        //add cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
         // ...
         })
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //default category
    var selectedCategoryName = ""

    var selectedIndexPath = IndexPath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryDefaults.set(categories, forKey: "CategoriesArray")
        self.navigationController!.setToolbarHidden(false, animated: true)
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell", for: indexPath)
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
// MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
    //implementing swipe to delete function
    /*override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }*/
}
