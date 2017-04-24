//
//  AddLocationViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 4/13/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum ButtonMode: String {
    case submitMode = "Submit"
    case locateMode = "Locate"
    case updateMode = "Update"
}

final class AddLocationViewController: UIViewController {

    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var submissionContainerView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var addressTextFieldVertical: NSLayoutConstraint!
    @IBOutlet var errorView: ErrorView!

    var selectedLocation: StudentLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissal ()
        submitButton.setTitle(resolveButtonText(buttonMode: .locateMode), for: .normal)

        if selectedLocation != nil {
            executeTextFieldTransitions()
            addressTextField.isUserInteractionEnabled = true
            addressTextField.text = selectedLocation.mapString
            linkTextField.text = selectedLocation.mediaURL
            locateAddress(location: { (coordinates) in })
            submitButton.setTitle(resolveButtonText(buttonMode: .updateMode), for: .normal)
        }

        addressTextField.becomeFirstResponder()
    }

    func setupKeyboardDismissal () {
        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(AddLocationViewController.didTapView))
        view.addGestureRecognizer(tapGesture)
    }
    @IBAction func didTapCancel(_ sender: Any) {
        dismissView ()
    }

    func dismissView () {
        DispatchQueue.main.async {[weak self] in
            guard let weakself = self else { return }
            weakself.dismiss(animated: true, completion: nil)
        }
    }

    func didTapAddButton () {

    }

    @IBAction func didTapSubmitButton(_ sender: Any) {
        if let button = sender as? UIButton,
            let title = button.titleLabel?.text,
            let buttonMode = ButtonMode(rawValue: title) {
            locateAddress(location: { [weak self](coordinates) in
                guard let weakself = self else { return }
                guard let coordinates = coordinates else { return }
                switch buttonMode {
                case .submitMode:
                    weakself.submitStudentLocation(shouldUpdate:false, location: coordinates)
                    weakself.dismissView ()
                case .locateMode:
                    DispatchQueue.main.async {
                        weakself.executeTextFieldTransitions ()
                    }
                case .updateMode:
                    weakself.submitStudentLocation(shouldUpdate: true, location: coordinates)
                    weakself.dismissView ()
                }
            })
        }
    }

    func isTextValid (in textField: UITextField?) -> Bool {
        if let text = textField?.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmedText.isEmpty
        } else {
            return false
        }
    }

    func submitStudentLocation (shouldUpdate: Bool, location: CLLocationCoordinate2D) {
        if let userData: UserData = UserDefaultsManager.getObject(for: Keys.kUserDataKey),
            let address = addressTextField?.text, let mediaURL = linkTextField?.text {
            var studentLocation : StudentLocation!
            if selectedLocation != nil {
                studentLocation = selectedLocation
                studentLocation.mapString = address
                studentLocation.mediaURL = mediaURL
                studentLocation.latitude = location.latitude
                studentLocation.longitude = location.longitude
            } else {
                studentLocation = StudentLocation(firstName: userData.firstName, lastName: userData.lastName, latitude: location.latitude, longitude: location.longitude, mapString: address, mediaURL: mediaURL, objectId: "", uniqueKey: userData.uniqueId, updatedAt: Date())
            }

            _ = StudentLocationManager.shared.submitStudentLocation(shouldUpdate: shouldUpdate, studentLocation: studentLocation).failure {[weak self] in
                guard let weakself = self else { return }
                MessageManager.display(type: .error, message: CopyText.savingError, in: weakself, with: weakself.errorView)
            }.success(successClosure: { [weak self](location) in
                guard let weakself = self else { return }
                DispatchQueue.main.async {
                    weakself.linkTextField.resignFirstResponder()
                    MessageManager.display(type: .success, message: CopyText.savingSuccess, in: weakself, with: weakself.errorView)
                }

            })
        }
    }

    func locateAddress (location: @escaping (CLLocationCoordinate2D?) -> Void) {
        if isTextValid(in: addressTextField) {
            geoCode(address: addressTextField?.text, completion: { coordinates in
                location(coordinates)
            })
        } else {
            location(nil)
        }
    }

    func executeTextFieldTransitions () {
        addressTextFieldVertical.constant = -10
        addressTextField.isUserInteractionEnabled = false
        linkTextField.isHidden = false
        linkTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            self.inputContainerView.layoutIfNeeded()
            self.inputContainerView.updateConstraintsIfNeeded()
        }
    }

    func geoCode (address: String?, completion: @escaping (_ coordinates: CLLocationCoordinate2D?)->Void) {
        guard let address = address else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [weak self](placemarksOptional, error) -> Void in
            guard let weakself = self else { return }
            if let placemarks = placemarksOptional {
                if let location = placemarks.first?.location {
                    DispatchQueue.main.async {
                        weakself.mapView.isHidden = false
                        weakself.addPin(at: location.coordinate, title: address)
                        weakself.submissionContainerView.backgroundColor = .clear
                        weakself.submitButton.setTitle(weakself.resolveButtonText(buttonMode: weakself.selectedLocation != nil ? .updateMode : .submitMode), for: .normal)
                        completion(location.coordinate)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func addPin(at coordinates: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        let centerCoordinate = coordinates
        annotation.coordinate = centerCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
        focusMapView(coordinates: coordinates)
    }

    func focusMapView(coordinates: CLLocationCoordinate2D) {
        let mapCenter = coordinates
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(mapCenter, span)
        mapView.region = region
    }

    func didTapView () {
        view.endEditing(true)
    }

    func resolveButtonText (buttonMode: ButtonMode) -> String {
        return buttonMode.rawValue
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
