import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet var table: UITableView!
    
    
    @IBAction func filterButton(_ sender: Any) {
        
        //let ac = UIAlertController(title: "Filter Categories", message: nil, preferredStyle: .actionSheet)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")

        fetchRequest.predicate = NSPredicate(format: "category == 'hello'")
        
        self.performFetch()
        
        self.table.reloadData()
        
        //code to try and filter the data
        
        /*ac.addAction(UIAlertAction(title: "Show hello category", style: .default) { [unowned self] _ in
            self.fetchedResultsController.predicate = NSPredicate(format: "category CONTAINS[c] 'hello'")
            self.performFetch()
        })
        // 2
        // 3
        // 4
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)*/
        
         
         /*let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
         
         let managedContext = appDelegate.managedObjectContext!
         let fetchRequest = NSFetchRequest(entityName:"Location")
         let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
 
         let filter = "Category"
         let predicate = NSPredicate(format: "hello", filter)
         fetchRequest.predicate = predicate*/
 
        
    }

    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>()
    
        let entity = Location.entity()
        fetchRequest.entity = entity
    
        let sortDescriptor1 = NSSortDescriptor(key: "category", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
    
        fetchRequest.fetchBatchSize = 20
        
        //trying to filter information
        
        let categoryName = "hello"
        
        //fetchRequest.predicate = NSPredicate(format: "category == %@", categoryName)
    
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: "Locations")

        
        
        fetchedResultsController.delegate = self
        

        
        //self.performFetch()
        
        
        /*let filter = "category"
        let predicate = NSPredicate(format: "hello", filter)*/
        
        //let searchPredicate = NSPredicate(format: "hello IN 'category'", Location as! CVarArg)

        
        //fetchRequest.predicate = searchPredicate
        
        return fetchedResultsController
    }()

    deinit {
        fetchedResultsController.delegate = nil
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
    
        performFetch()
    }
  
    func performFetch() {
        
        /*let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "category == %@", "hello")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Locations] {
            locations = fetchResults
        }*/
        
        do {
            
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
        //tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
      
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
  
    // MARK: - UITableViewDataSource
  
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
  
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationCell", for: indexPath) as! LocationCell
    
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
    
        return cell
    }
  
    override func tableView(_ tableView: UITableView,
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
    }
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
  
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
      
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
      
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
      
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
  
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
  
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
