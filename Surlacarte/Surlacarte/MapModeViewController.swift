//
//  FirstViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/20/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapModeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTapLogout(_ sender: UIBarButtonItem) {
        LoginManager.dismiss(viewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

