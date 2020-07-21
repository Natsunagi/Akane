//
//  AKMapViewController.swift
//  Akane
//
//  Created by Grass Plainson on 2020/7/20.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AKMapViewController: UIViewController {
    
    // MARK: - Property.
    
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var deviceTrackPoint: Array<(x: Double, y: Double)> = Array<(x: Double, y: Double)>.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mapView = MKMapView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        self.view.addSubview(self.mapView)
        self.mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        
        self.locationManager = CLLocationManager.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
        
        let annotation: MapLocationAnnotation = MapLocationAnnotation.init(coordinate: CLLocation.init(latitude: Double("28.358")!, longitude: Double("121.444")!).coordinate, imageName: nil)
        self.mapView.addAnnotation(annotation)
        
        // 地图焦点移动到该位置。
        self.mapView.setRegion(MKCoordinateRegion.init(center: CLLocation.init(latitude: Double("28.358")!, longitude: Double("121.444")!).coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
    
        // - 画轨迹。
        
        var pointArray: Array<MKMapPoint> = Array<MKMapPoint>.init()
        self.deviceTrackPoint = [(28.358, 121.444), (29.0, 122.0), (30.0, 123.0), (31.0, 124.0), (40.0, 140.0)]
        for point in self.deviceTrackPoint {
            let pointLocation: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: point.x, longitude: point.y)
            let dataPoint: MKMapPoint = MKMapPoint.init(pointLocation)
            pointArray.append(dataPoint)
        }
        let polyline: MKPolyline = MKPolyline.init(points: &pointArray, count: pointArray.count)
        self.mapView.addOverlays([polyline])
    }
}

// MARK: - MKMapViewDelegate.

extension AKMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView: MKAnnotationView = MKAnnotationView.init()
        pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin", for: annotation)
        
        let locationAnnotation: MapLocationAnnotation = annotation as! MapLocationAnnotation
        pinView.annotation = locationAnnotation
        pinView.canShowCallout = false
        pinView.isDraggable = true
        pinView.image = UIImage.init(named: "地图大头针")
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render: MKPolylineRenderer = MKPolylineRenderer.init(overlay: overlay)
        render.lineWidth = 5.0
        render.strokeColor = .orange
        return render
    }
}

// MARK: - CLLocationManagerDelegate.

extension AKMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let currentLocation: CLLocation = locations.last!
        self.mapView.setRegion(MKCoordinateRegion.init(center: currentLocation.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
    }
}

// MARK: - Annotation.

class MapLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var annotationMark: String?
    
    init(coordinate: CLLocationCoordinate2D, imageName: String?) {
        if (imageName != nil) {
            let imageView: UIImageView = UIImageView.init()
            imageView.image = UIImage.init(named: imageName!)
        }
        self.coordinate = coordinate
    }
}
