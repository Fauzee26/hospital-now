//
//  MapViewController.swift
//  ExamHospitalNow
//
//  Created by HilmyF on 10/08/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var btnProvinceName: UIButton!
    @IBOutlet weak var labelHospitalName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelRegionDesc: UILabel!
    
    var hospital: Hospital?
    
    class func create() -> MapViewController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryboard.instantiateViewController(withIdentifier: String(describing: self)) as! MapViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
    }
    
    func setupUI() {
        self.title = "Map Location"
        
        viewBottom.layer.cornerRadius = 24
        viewBottom.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        mapView.isUserInteractionEnabled = false
        
        guard let hospital else {return}
        
        btnProvinceName.setTitle("Prov. \(hospital.province)", for: .normal)
        labelHospitalName.text = hospital.name
        labelAddress.text = hospital.address
        var hospitalDesc = hospital.region
        
        if let phone = hospital.phone {
            hospitalDesc += " · " + phone
        }
        
        labelRegionDesc.text = hospitalDesc
    }
    
    func fetchData() {
        guard let hospital else {return}
        
        getLocationInMap(address: hospital.address) { location, error in
            if let error {
                print("Failed get map location from address, rerouting using region")
                self.getLocationInMap(address: hospital.region) { locationRegion, errorRegion in
                    if let locationRegion {
                        self.setupUIMap(location: locationRegion)
                    } else {
                        print("Failed get map location from region")
                    }
                }
            } else {
                guard let location else {return}
                self.setupUIMap(location: location)
            }
        }
    }
    
    func setupUIMap(location: CLLocation) {
        guard let hospital else {return}

        let coordinate = location.coordinate
        
        let annotation = MKPointAnnotation()
        annotation.title = hospital.name
        annotation.subtitle = hospital.region
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
        let regionRadius: CLLocationDistance = 12
        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getLocationInMap(address: String, completion: @escaping(CLLocation?, Error?) -> (Void)) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error {
                if let error = error as? CLError {
                    switch error.code {
                    case .locationUnknown:
                        print("locationUnknown: location manager was unable to obtain a location value right now.")
                    case .denied:
                        print("denied: user denied access to the location service.")
                    case .promptDeclined:
                        print("promptDeclined: user didn’t grant the requested temporary authorization.")
                    case .network:
                        print("network: network was unavailable or a network error occurred.")
                    case .headingFailure:
                        print("headingFailure: heading could not be determined.")
                    case .rangingUnavailable:
                        print("rangingUnavailable: ranging is disabled.")
                    case .rangingFailure:
                        print("rangingFailure: a general ranging error occurred.")
                    default : break
                    }
                }
                completion(nil, error)
            } else {
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    return
                }
                completion(location, nil)
            }
        }
    }
}
