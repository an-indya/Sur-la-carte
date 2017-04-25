//
//  SecondViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/20/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class ListModeViewController: UITableViewController, SegueHandler {

    @IBOutlet var errorView: ErrorView!
    let loginManager = LoginManager()
    let studentLocationManager = StudentLocationManager.shared
    var locations: StudentLocations!
    let reuseIdentifier = "LocationTableViewCell"
    enum SegueIdentifier: String {
        case editLocation = "editLocation"
        case addLocation = "addLocation"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locations = studentLocationManager.downloadedLocations
        clearsSelectionOnViewWillAppear = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateTable()
    }


    func fetchStudentLocations (completion: @escaping ((StudentLocations)->Void)) {
        _ = studentLocationManager.fetchStudentLocations().success(successClosure: { (locations) in
            completion(locations)
        }).failure { [weak self] errorType in
            guard let weakself = self else { return }
            MessageManager.displayError(errorMessage: CopyText.studentLocationFetchError, errorType: errorType, errorView: weakself.errorView, viewController: weakself)
        }
    }

    func populateTable() {
        fetchStudentLocations { [weak self] (studentLocations) in
            guard let weakself = self else { return }
            weakself.locations = studentLocations
            DispatchQueue.main.async {
                weakself.tableView.reloadData()
            }
        }
    }

    func displayError(errorMessage: CopyText) {
        MessageManager.display(type: .error, message: errorMessage, in: self, with: errorView)
    }

    @IBAction func didTapRefresh(_ sender: Any) {
        populateTable()
    }

    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        LoginManager.logout()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations != nil ? locations.studentLocations.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? LocationTableViewCell
        if locations.studentLocations.count > indexPath.row {
            let location = locations.studentLocations[indexPath.row]
            cell?.nameLabel?.text = "\(location.firstName) \(location.lastName)"
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if locations.studentLocations.count > indexPath.row {
            let location = locations.studentLocations[indexPath.row]
            //Commenting out the following as this leads to editing the selected item
            //performSegue(withIdentifier: SegueIdentifier.editLocation.rawValue, sender: location)

            //We could prefix the links with http in case its not there. But in that call any garbage value is treated as link. So, google.com becomes http://google.com but unfortunately sdasdad becomes http://sdasdad which is also a valid link. So ignoring.
            /*var link = location.mediaURL
            if !link.contains("http") {
                link = "http://" + link
            }*/

            if let url = URL(string: location.mediaURL) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
                } else {
                    tableView.deselectRow(at: indexPath, animated: true)
                    MessageManager.display(type: .warning, message: .linkInvalid, in: self, with: errorView)
                }
            }
        }


    }
}

