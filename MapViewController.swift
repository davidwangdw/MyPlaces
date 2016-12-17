//
//  MapViewController.swift
//  Location Journal
//
//  Created by David Wang on 12/17/16.
//  Copyright © 2016 David Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(
            mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    @IBAction func showLocations() {
    }
}
extension MapViewController: MKMapViewDelegate {
}
