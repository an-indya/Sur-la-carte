//
//  FirstViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/20/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit

final class MapModeViewController: UIViewController, SegueHandler {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var errorView: ErrorView!
    lazy var loginManager = LoginManager()
    let studentLocationManager = StudentLocationManager.shared
    enum SegueIdentifier: String {
        case editLocation = "editLocation"
        case addLocation = "addLocation"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
        mapView.region = worldRegion
        mapView.delegate = self
        LoginManager.initiateAuthentication()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateMap ()
    }

    func fetchStudentLocations (force: Bool, completion: @escaping ((StudentLocations)->Void)) {
        _ = studentLocationManager.fetchStudentLocations().success(successClosure: { (locations) in
            completion(locations)
        }).failure {
            self.displayError(errorMessage: "Failed to fetch student locations")
        }
    }

    func populateMap () {
        fetchStudentLocations (force: true) { [weak self] (studentLocations) in
            guard let weakself = self else { return }
            weakself.studentLocationManager.downloadedLocations = studentLocations
            DispatchQueue.main.async {
                weakself.mapView.removeAnnotations(weakself.mapView.annotations)
                weakself.addAnnotations(to: weakself.mapView, from: studentLocations)
            }
        }
    }

    @IBAction func didTapRefresh(_ sender: Any) {
        populateMap ()
    }

    func addAnnotations(to map: MKMapView, from locations: StudentLocations) {
        locations.studentLocations.forEach({ (location) in
            let point = MKParameteredAnnotation()
            point.coordinate = location.coordinates
            point.title = location.fullName
            point.subtitle = location.mediaURL
            point.studentLocation = location
            DispatchQueue.main.async {
                map.addAnnotation(point)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .editLocation:
            if let location = sender as? StudentLocation,
                let vc = segue.destination as? AddLocationViewController {
                vc.selectedLocation = location
            }
        case .addLocation:
            break
        }
    }

    func displayError(errorMessage: String) {
        MessageManager.display(type: .error, message: errorMessage, in: self, with: errorView)
    }

    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        LoginManager.logout()
    }
}

extension MapModeViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        guard let annotation = view.annotation else { return }
        if let ann = annotation as? MKParameteredAnnotation {
            let location = ann.studentLocation
            performSegue(withIdentifier: SegueIdentifier.editLocation.rawValue, sender: location)
        }
    }
}

class MKParameteredAnnotation: MKPointAnnotation {
    open var studentLocation: StudentLocation?
}

