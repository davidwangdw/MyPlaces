//
//  CurrentLocationViewController.swift
//  MyLocations
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var logoTop: UIImageView!
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
  
    let locationManager = CLLocationManager()
  
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?

    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?

    var timer: Timer?
  
    var managedObjectContext: NSManagedObjectContext!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
      
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // MARK: - Logo View
    func showLogoView() {
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            logoTop.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView() {
        
        
        /*logoVisible = false
        containerView.isHidden = false
        logoButton.removeFromSuperview()*/

        // to animate logo
        
        if !logoVisible { return }
        
        logoVisible = false
        containerView.isHidden = false
        logoTop.isHidden = false
        //containerView.center.x = view.bounds.size.width * 2
        //containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        //let centerX = view.bounds.midX
        
        /*let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = kCAFillModeForwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint:
            CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseOut)
        panelMover.delegate = self
        containerView.layer.add(panelMover, forKey: "panelMover")*/
        
        /*let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = kCAFillModeForwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint:
        CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(
        name: kCAMediaTimingFunctionEaseIn)
        logoButton.layer.add(logoMover, forKey: "logoMover")*/
        
        
        
        let logoFade = CABasicAnimation(keyPath: "opacity")
        logoFade.isRemovedOnCompletion = false
        logoFade.fromValue = 1
        logoFade.duration = 1
        logoFade.toValue = 0
        logoButton.layer.add(logoFade, forKey: "logoFade")
        
        logoButton.removeFromSuperview()
        
        let panelMover = CABasicAnimation(keyPath: "opacity")
        panelMover.isRemovedOnCompletion = false
        panelMover.fromValue = 0
        panelMover.duration = 1
        panelMover.toValue = 1
        containerView.layer.add(panelMover, forKey: "panelMover")
        logoTop.layer.add(panelMover, forKey: "panelMover")
        
        //containerView.layer.removeAllAnimations()

        
        /*logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(
            name: kCAMediaTimingFunctionEaseIn)*/
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
  
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
    
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
    
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
    
        if logoVisible {
            hideLogoView()
        }
    
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }

        updateLabels()
        configureGetButton()
    }
  
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
    
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
    
        present(alert, animated: true, completion: nil)
    }
    
    var logoVisible = false
    lazy var logoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(getLocation),
                         for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        return button
    }()
  
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.5f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.5f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
      
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
      
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
      
            let statusMessage: String
            if let error = lastLocationError as? NSError {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = ""
                showLogoView()
            }
      
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
        
            messageLabel.text = statusMessage
        }
    }
  
    func string(from placemark: CLPlacemark) -> String {
    
        var line1 = ""
    
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
    
        if let s = placemark.thoroughfare {
            line1 += s
        }
    
        var line2 = ""
    
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
    
        return line1 + "\n" + line2
    }
    
    
    //supposed to make spining wheel but not sure why it's not working
    func configureGetButton() {
        let spinnerTag = 1000
    
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(
                    activityIndicatorStyle: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height/2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
        }
    }
  
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
      
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                   selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
  
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
      
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
  
    func didTimeOut() {
        print("*** Time out")
    
        if location == nil {
            stopLocationManager()
      
            lastLocationError = NSError(domain: "MyLocationsErrorDomain",
                                        code: 1, userInfo: nil)
      
            updateLabels()
            configureGetButton()
        }
    }
  
  // MARK: - CLLocationManagerDelegate
  
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
    
        lastLocationError = error
    
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
    
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
    
        if newLocation.horizontalAccuracy < 0 {
            return
        }
    
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
    
        if location == nil ||
            location!.horizontalAccuracy > newLocation.horizontalAccuracy {
      
            lastLocationError = nil
            location = newLocation
            updateLabels()
      
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                configureGetButton()
        
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
      
            if !performingReverseGeocoding {
                print("*** Going to geocode")
        
                performingReverseGeocoding = true
        
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
          
                    print("*** Found placemarks: \(placemarks), error: \(error)")
          
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
          
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
}

