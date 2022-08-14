//
//  ViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/5/22.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import FirebaseFirestore


class ViewController: UIViewController {

    // initialize variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noAvailableRestroomsLabel: UILabel!
    
    // initialize Firebase
    let db = Firestore.firestore()
    
    // Store bathrooms from firebase
    var bathrooms: [Bathroom] = []
    
    // get index of bathroom selected from TableView
    var indexOfBathroom: Int = 2
    
    // create cancel button when setting a pin
    let button = UIButton(frame: CGRect(x: 305, y: 150, width: 75, height: 31))
    let imageView = UIImageView(image: UIImage(named: "Unknown-1.png")!)
    
    // get current location of a User
    var setPinLatitude: CLLocationDegrees?
    var setPinLongitude: CLLocationDegrees?

    // display current location of user and display map
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 30000
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationItem.hidesBackButton = true
        // request user permssion for location
        checkLocationServices()
        
        title = "Potty Finder"
        tableView.register(UINib(nibName: "BathroomCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
    }
    
    // retreive bathrooms from firebase and display put into Bathroom array
    func loadTableBathrooms() {

        db.collection("bathrooms")
            .order(by: "averageRating", descending: true)
            .limit(to: 10)
            .addSnapshotListener { querySnapshot, error in

            self.bathrooms = []

            // if there is an error retrieving from firebase
            if let e = error {
                print("There was an issue retrieveing data from Firestore, \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    var position = 1
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        // if bathroom from database has all these requirements
                        if let lat = data["latitude"] as? CLLocationDegrees, let long = data["longitude"] as? CLLocationDegrees, let rating = data["averageRating"] as? String, let key = data["keyEntry"] as? [String], let baby = data["babyStation"] as? [String], let name = data["name"] as? String , let cleanliness = data["averageCleanliness"] as? String, let stock = data["averageStockLevels"] as? String, let gender = data["allGender"] as? [String] {
                            

                            // get average baby station
                            var babyCounts: [String: Int] = [:]
                            baby.forEach { babyCounts[String($0), default: 0] += 1 }
                            var babySign = "No"
                            if let _ = babyCounts["Yes"], let _ = babyCounts["No"] {
                                if babyCounts["Yes"]! > babyCounts["No"]! {
                                    babySign = "Yes"
                                }
                            } else {
                                babySign = babyCounts.first!.key
                            }

                            // get average keys
                            var keyCounts: [String: Int] = [:]
                            key.forEach { keyCounts[String($0), default: 0] += 1 }
                            var keySign = "No"
                            if let _ = keyCounts["Yes"], let _ = keyCounts["No"] {
                                if keyCounts["Yes"]! > keyCounts["No"]! {
                                    keySign = "Yes"
                                }
                            } else {
                                keySign = keyCounts.first!.key
                            }
                            
                            // get average gender
                            var genderCounts: [String: Int] = [:]
                            gender.forEach { genderCounts[String($0), default: 0] += 1 }
                            var genderSign = "No"
                            if let _ = genderCounts["Yes"], let _ = genderCounts["No"] {
                                if genderCounts["Yes"]! > genderCounts["No"]! {
                                    genderSign = "Yes"
                                }
                            } else {
                                genderSign = genderCounts.first!.key
                            }
                            
                        
                            // add new bathroom
                            let newBathroom = Bathroom(name: name, rating: rating, id: position, key: keySign, baby: babySign, lat: String(lat), long: String(long), stock: stock, cleanliness: cleanliness, gender: genderSign)
                            position += 1
                            self.bathrooms.append(newBathroom)


                            DispatchQueue.main.async {
                                // listen and reload data for table View and map annotations
                                self.tableView.reloadData()
                                self.loadMapView()

                            }

                        }
                    }
                }
                // if there are no rated bathrooms nearby, display message
                if self.bathrooms.isEmpty {
                    self.noAvailableRestroomsLabel.text = "No Available Restrooms Nearby"
                }
            }
        }
    }
    
    
    // function to load map annotations of bathrooms
    func loadMapView() {
     
        for (_, bathroom) in self.bathrooms.enumerated() {
            
            self.noAvailableRestroomsLabel.text = ""
            
            // retrieve latitude and longitude from each bathroom
            let bath_longitude = Double(bathroom.long)!
            let bath_latitude = Double(bathroom.lat)!
            let annotation = MKPointAnnotation()
            
            // create annotation of bathroom coordinates
            annotation.coordinate = CLLocationCoordinate2D(latitude: bath_latitude, longitude: bath_longitude)

            // add annotation to map
            mapView.addAnnotation(annotation)
            
            
        }
        
    }
    
    // if the add pin is pressed, display a pin and a cancel button
    @IBAction func addPinPressed(_ sender: UIButton) {
        
        if sender.currentTitle == "Set Pin" {
            
            // perform segue to the review page
            self.performSegue(withIdentifier: "ReviewPage", sender: self)
            button.removeFromSuperview()
            imageView.removeFromSuperview()
            addButton.setTitle("+ ADD", for: .normal)
            
        } else {

            // add cancel button just in case user doesnt mean to add pin
            imageView.frame = CGRect(x: mapView.center.x-18, y: mapView.center.y-30, width: 40, height: 40)
            view.addSubview(imageView)
            
            button.backgroundColor = UIColor.red
            button.setTitle("Cancel", for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.layer.cornerRadius = 5
            button.alpha = 0.8

            view.addSubview(button)
            addButton.setTitle("Set Pin", for: .normal)
            
        }
    }
    
    // if the cancel button is pressed
    @objc func buttonAction(sender: UIButton!) {

        // remove cancel button from view
        button.removeFromSuperview()
        imageView.removeFromSuperview()
        addButton.setTitle("+ ADD", for: .normal)
    }
    
    // if logout is pressed
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            // return to login page
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            // throw error
          print("Error signing out: %@", signOutError)
        }
        
    }
    
    // prepare for segue to different screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewPage" {
            // pass the latitude and longitude to the Review Page
            // so firebase can store it
            let destinationVC = segue.destination as! ReviewViewController
            destinationVC.pinLatitude = setPinLatitude
            destinationVC.pinLongitude = setPinLongitude
        }
        if segue.identifier == "ViewBathroom" {
            // pass the current bathroom being selected to Preview Page
            let destinationVC = segue.destination as! PreviewBathroomViewController
            destinationVC.name = bathrooms[indexOfBathroom].name
            destinationVC.currentBathroom = bathrooms[indexOfBathroom]
        }
    }
    
    // setup location manager for location services
    func setupLocationManger() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    // center the map view on the users location
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    // check to see if location service have been disabled, enabled
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManger()
            checkLocationAuthorization()
        } else {
            // Show alert to let user this needs to be turned on
        }
        
    }
    
    // check the authorization of the location services
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // track user location
            startTrackingUserLocation()
        case .denied:
            // display alert telling user to enable in preferences
            let uialert = UIAlertController(title: "Location Services Disabled", message: "Please go to settings and allow this app to use location services.", preferredStyle: UIAlertController.Style.alert)
            uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
            self.present(uialert, animated: true, completion: nil)
            // show alert instructing how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
//            break
        case .restricted:
            let uialert = UIAlertController(title: "Location Services Restricted", message: "Please go to settings and turn on location services. Consult with your business or family.", preferredStyle: UIAlertController.Style.alert)
            uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
            self.present(uialert, animated: true, completion: nil)
            // show alert letting them know they are rstricted
            break
        case .authorizedAlways:
            break
            
            
        }
        
    }
    
    // function to start tracking user location
    func startTrackingUserLocation() {
        
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        loadTableBathrooms()
        
    }
    
    // function to retrive the latitude and longitude from the center of the map
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//    }
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
       
        checkLocationAuthorization()
    }
    
}


extension ViewController: MKMapViewDelegate {
    
    // allows user to interact with map and will display latitude and longitude
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        // if previous location is 50 meters away from new location then change the center of the map
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                // show alert informin user
                return
            }
            
            guard let placemark = placemarks?.first else {
                // show alert informin user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let locationPlace = placemark.location!
            
            DispatchQueue.main.async {
                // store the values of the latitude and longitude
                self.setPinLatitude = locationPlace.coordinate.latitude
                self.setPinLongitude = locationPlace.coordinate.longitude
                print("\(streetNumber) \(streetName)")
                print("\(locationPlace.coordinate.latitude)")
            }
            
        }
    }
    
    // change the annotations on the map to be numbered and blue
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        guard annotation is MKPointAnnotation else { return nil }

        // retrive string version of longitude to compare to bathroom longitude
        let annotationLongitude = annotation.coordinate.longitude
        let strAnnotationLongitude = String(annotationLongitude)

        // create annotatiobView from annotations
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")

        // parse through bathrooms to get bathrooms id
        for bathroom in bathrooms {
            if strAnnotationLongitude == bathroom.long {
                annotationView.markerTintColor = UIColor.blue
                annotationView.glyphText = String(bathroom.id)
            }
        }
        
        return annotationView
        
        
    }

    // function when annotation is clicked
    // wanted to outline bathroom table cell when annotation is clicked
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        for bathroom in bathrooms {
            print(bathroom.id)
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return length of bathroom array
        return bathrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! BathroomCell

        var babySign = "❌"
        var keySign = "❌"
        // display features from bathrom onto the table cell
        cell.nameLabel.text = bathrooms[indexPath.row].name
        cell.numberLabel.text = String(indexPath.row+1) + "."
        cell.ratingLabel.text = bathrooms[indexPath.row].rating + "/5 ⭐️"

        if bathrooms[indexPath.row].key == "Yes" {
            keySign = "✅"
        }
        if bathrooms[indexPath.row].baby == "Yes" {
            babySign = "✅"
        }
        cell.feature1Label.text = keySign + "Key to Enter"
        cell.feature2Label.text = babySign + "Baby Changing"
        return cell
        
    }
    
}

extension ViewController: UITableViewDelegate {
    
    // function when a table cell is clicked, segue into preview page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexOfBathroom = indexPath.row
        self.performSegue(withIdentifier: "ViewBathroom", sender: self)
    }
    
}
