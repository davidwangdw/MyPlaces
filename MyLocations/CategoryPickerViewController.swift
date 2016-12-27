import UIKit
class CategoryPickerViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    //using a UserDefaults object to store the data array for categories
    
    //default categories, will be able to change/edit later
    
    var categoriesList: [String] = [
    "No Category"]
    
  
    @IBAction func addCategory(_ sender: Any) {
        self.tableView.reloadData()
        let alert = UIAlertController(title: "Add Category", message: "Enter a category", preferredStyle: .alert)
        //Add the text input field
        alert.addTextField { (textField) in textField.text = "" }
        
        //Grab the value from the text field
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            
            
            let textField = alert?.textFields![0]
            
            let itemsObject = UserDefaults.standard.object(forKey: "categoriesList")
            
            var items:[String]
            
            if let tempItems = itemsObject as? [String] {
                
                items = tempItems
                
                items.append((textField?.text!)!)
                
            } else {
                
                items = ["No Category"]
                items.append((textField?.text!)!)
                
            }
            
            UserDefaults.standard.set(items, forKey: "categoriesList")
            
            self.table.reloadData()
            
            self.categoriesList.append((textField?.text!)!)

            print(self.categoriesList)
            self.table.reloadData()
            
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
        
        table.reloadData()
        
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        for i in 0..<categoriesList.count {
            if categoriesList[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
         }
        

    }
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        /*let myArray = UserDefaults.standard.object(forKey: "categoriesList") as? [String]
        return myArray!.count*/
        
        return categoriesList.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let itemsObject = UserDefaults.standard.object(forKey: "categoriesList")
        
        
        if let tempItems = itemsObject as? [String] {
            
            categoriesList = tempItems
            
        }
        
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let myArray = UserDefaults.standard.object(forKey: "categoriesList") as? [String]
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath)
        //let categoryName = myArray?[indexPath.row]
        let categoryName = categoriesList[indexPath.row]
        cell.textLabel!.text = categoryName
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        //print(myArray)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let myArray = UserDefaults.standard.object(forKey: "categoriesList") as? [String]
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                //selectedCategoryName = (myArray?[indexPath.row])!
                selectedCategoryName = categoriesList[indexPath.row]
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == UITableViewCellEditingStyle.delete {
    
        categoriesList.remove(at: indexPath.row)
    
        table.reloadData()
    
        UserDefaults.standard.set(categoriesList, forKey: "categoriesList")
    
        }
    
    }

}
