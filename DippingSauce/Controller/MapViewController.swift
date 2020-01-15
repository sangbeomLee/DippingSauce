//
//  MapViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/13.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import MapKit
import ProgressHUD

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var users:[User] = []
    var currentTrensportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    var currentCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        addAnnotation()
        setupSegmentedControl()
    }

    func addAnnotation(){
        var nearByAnnotations: [MKAnnotation] = []
        for user in users{
            if user.latitude.isEmpty{
                continue
            }
            let location = CLLocation(latitude: Double(user.latitude)!, longitude: Double(user.longitude)!)
            
            let annotation = UserAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = user.username

            if let age = user.age{
                annotation.age = age
                annotation.subtitle = "age: \(age)"
            }
            if let isMale = user.isMale{
                annotation.isMale = isMale
            }
            annotation.profileImage = user.profileImage
            annotation.uid = user.uid
            nearByAnnotations.append(annotation)
        }
        self.mapView.showAnnotations(nearByAnnotations, animated: true)
    }
    
    func setupSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        // direction button을 눌렀을 때 나오게 할 것이다.
        segmentedControl.isHidden = true
        segmentedControl.addTarget(self, action: #selector(showDirection(coordinate:)), for: .valueChanged)
        
    }
    
    @objc func showDirection(coordinate: CLLocationCoordinate2D){
        switch segmentedControl.selectedSegmentIndex{
        case 0: self.currentTrensportType = .automobile
            break
        case 1: self.currentTrensportType = .walking
            break
        default: break
        }
        
        // coordinate에 정보을 가지고있다. coordinate가 0이 들어 올때를 대비해서 currentCoordinate를 저장 해놓았다.
        if coordinate.latitude != 0 || coordinate.longitude != 0{
            currentCoordinate = coordinate
        }
        segmentedControl.isHidden = false
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(coordinate: currentCoordinate!)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = currentTrensportType
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (routeResponse, error) in
            guard let routeResponse = routeResponse else{
                if let error = error{
                    ProgressHUD.showError(error.localizedDescription)
                    print(error.localizedDescription)
                }
                return
            }
            let route = routeResponse.routes.first!
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func backButtonDidTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    // accessoryContol을 눌렀을 때 불러오는 함수
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate{
            showDirection(coordinate: coordinate)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        var annotationView: MKAnnotationView?
        
        // reuse the annotation if possible
        if annotation.isKind(of: MKUserLocation.self){
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: IMAGE_ICON_PERSON)
        }else if let deqAno = mapView.dequeueReusableAnnotationView(withIdentifier: identifier){
            annotationView = deqAno
            annotationView?.annotation = annotation
        }else{
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annoView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? UserAnnotation{
            annotationView.canShowCallout = true
            
            let image = anno.profileImage
            let resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            resizeRenderImageView.image = image
            let width = resizeRenderImageView.frame.size.width
            resizeRenderImageView.layer.cornerRadius = width/2
            resizeRenderImageView.clipsToBounds = true
            resizeRenderImageView.contentMode = .scaleAspectFill
            
            // what
            UIGraphicsBeginImageContextWithOptions(resizeRenderImageView.frame.size, false, 0.0)
            resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            annotationView.image = thumbnail
            
            let infoButton = UIButton()
            infoButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            infoButton.setImage(UIImage(named: IMAGE_ICON_DIRECTION), for: .normal)
            annotationView.rightCalloutAccessoryView = infoButton
            
            let leftIconView = UIImageView()
            leftIconView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            if let isMale = anno.isMale{
                leftIconView.image = isMale ? UIImage(named: IMAGE_ICON_MALE) : UIImage(named: IMAGE_ICON_FEMALE)
                annotationView.leftCalloutAccessoryView = leftIconView
            }
            
        }
        
        
        return annotationView
    }
}
