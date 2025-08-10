//
//  LocationManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 04/08/25.
//

import Foundation
import CoreLocation
import Contacts

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<String?, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // Método público para obter a cidade com async
    func getCityName() async -> String? {
        locationManager.requestWhenInUseAuthorization()
        
        guard CLLocationManager.locationServicesEnabled() else {
            return nil
        }

        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    // Delegate: localização recebida
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            let city = placemarks?.first?.locality ?? placemarks?.first?.subAdministrativeArea
            self.locationContinuation?.resume(returning: city)
            self.locationContinuation = nil
        }
    }

    // Delegate: erro
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro ao obter localização: \(error.localizedDescription)")
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
}
