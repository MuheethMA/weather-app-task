//
//  LocationManager.swift
//  TaskOpenWeather
//
//  Created by Abdul on 9/3/24.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(latitude: Double, longitude: Double)
    func didFailWithError(error: Error)
    func locationAccessDenied()
}

class LocationManager: NSObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        // Only start updating location if location services are enabled
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            } else {
                // Location services are not enabled, notify delegate
                self.delegate?.locationAccessDenied()
            }
        }
    }

    // CLLocationManagerDelegate method: Called when authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                self.startLocationUpdates()
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.delegate?.locationAccessDenied()
            }
        case .notDetermined:
            // Authorization not determined yet; no need to take action
            break
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    // CLLocationManagerDelegate method: Called when the location manager updates location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()

            // Retrieve latitude and longitude
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            // Notify the delegate of the location update
            DispatchQueue.main.async {
                self.delegate?.didUpdateLocation(latitude: latitude, longitude: longitude)
            }
        }
    }

    // CLLocationManagerDelegate method: Called when location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Notify the delegate of the failure
        DispatchQueue.main.async {
            self.delegate?.didFailWithError(error: error)
        }
    }
}
