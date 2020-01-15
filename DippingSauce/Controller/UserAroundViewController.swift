//
//  UserAroundViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/12.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit
import GeoFire
import FirebaseDatabase
import ProgressHUD

class UserAroundViewController: UIViewController {

    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let mySlider = UISlider()
    let distanceLabel = UILabel()
    let manager = CLLocationManager()
    var userLat = ""
    var userLong = ""
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    // geoFire Query
    var queryHandle: DatabaseHandle?
    var myQuery: GFQuery!
    var distance: Double = INITIAL_DISTANCE
    var users:[User] = []
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupSegmentedControl()
        configureLocationManager()
        
    }
    
    func setupNavigationBar(){
        // NavigationRightBarButtonItems
        let refresh = UIBarButtonItem(image: UIImage(named: IMAGE_ICON_REFRESH), style: .plain, target: self, action: #selector(refreshButtonDidTapped))
        distanceLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        distanceLabel.font = UIFont.systemFont(ofSize: 13)
        distanceLabel.text = "\(Int(distance)) km"
        distanceLabel.textColor = UIColor(red: 74/255, green: 168/255, blue: 216/255, alpha: 1)
        let distanceItem = UIBarButtonItem(customView: distanceLabel)

        // NavigationTitle/slideritem
        self.navigationItem.title = "Find User"
        mySlider.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        mySlider.minimumValue = 1
        mySlider.maximumValue = 50
        mySlider.isContinuous = true
        // 초기 설정값
        mySlider.value = Float(distance)
        mySlider.tintColor = UIColor(red: 74/255, green: 168/255, blue: 216/255, alpha: 1)
        mySlider.addTarget(self, action: #selector(sliderValueChanged(slider:event:)), for: .valueChanged)
    
        self.navigationItem.titleView = mySlider
        self.navigationItem.rightBarButtonItems = [refresh, distanceItem]
    }
    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    func setupSegmentedControl(){
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
    }
    
    func configureLocationManager(){
        // location에 대한 정보
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            manager.startUpdatingLocation()
        }
        self.geoFireRef = Ref().databaseGeo
        self.geoFire = GeoFire(firebaseRef: self.geoFireRef)
    }
    
    func findUsers(){
        
        // 옵저버가 여러개 되어서 같은 정보를 여러번 가져온다. 때문에 queryHandel이 있으면 옵저버를 끝낸다.
        if queryHandle != nil, myQuery != nil{
            myQuery.removeObserver(withFirebaseHandle: queryHandle!)
            myQuery = nil
            queryHandle = nil
        }
        
        if let userLat = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LATITUDE) as? String{
            self.userLat = userLat
        }
        if let userLong = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LONGITUDE) as? String{
            self.userLong = userLong
        }
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        
        myQuery = geoFire.query(at: location, withRadius: distance)
        users.removeAll()
        queryHandle =  myQuery.observe(.keyEntered, with: {(key, location) in
            if key != Api.User.currentUserId{
                Api.User.getUserSingleInfo(uid: key) { (user) in
                    // 같은것이 있으면 넣지 않는 로직 이었으나 queryHandle로 중복되게 옵저버가 일을 안 하게하였기 때문에 이 로직은 필요없다.
                    // 아니다 이 부분은 혹시나 하는 것에 필요한 듯 하다.
                    if !self.users.contains(where: {$0.uid == key}){
                        guard let isMale = user.isMale else{
                            return
                        }
                        switch self.segmentedControl.selectedSegmentIndex{
                        case 0:
                            if isMale{
                                self.users.append(user)
                            }
                            break
                        case 1:
                            if !isMale{
                                self.users.append(user)
                            }
                            break
                        case 2:
                            self.users.append(user)
                        default:
                            break
                        }
                        self.collectionView.reloadData()
                    }
                }
            }
        })
    }
    
    @objc func refreshButtonDidTapped(){
        findUsers()
        
        
    }
    @objc func sliderValueChanged(slider: UISlider, event: UIEvent){
        //print(Double(slider.value))
        if let touchEvent = event.allTouches?.first{
            distance = Double(slider.value)
            distanceLabel.text = "\(Int(distance)) km"
            
            switch touchEvent.phase{
            case .began:
                break
            case .moved:
                break
            case .ended:
                findUsers()
                break
            default:
                break
            }
        }
    }
    
    @IBAction func mapButtonDidTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: STORYBOARD_NAME_AROUND, bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_MAP) as! MapViewController
        
        mapVC.users = users
        
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        findUsers()
    }
    
    
    
}

extension UserAroundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IDENTIFIER_USER_AROUND_CELL, for: indexPath) as! UserAroundCollectionViewCell
        cell.loadData(users[indexPath.row], currentLocation: self.currentLocation)
        cell.controller = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3 - 2, height: view.frame.size.width/3 - 2)
    }

    // 가르는 선의 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: STORYBOARD_NAME_AROUND, bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: IDENTIFIER_DETATIL) as! DetailViewController
        
        detailVC.user = users[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
}

extension UserAroundViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse){
            manager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        ProgressHUD.showError(error.localizedDescription)
    }
    
    // update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // update를 한번만 하기위해 한다.
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        let updatedLocation: CLLocation = locations.first!
        self.currentLocation = updatedLocation
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        // update Location
        let userDefaults: UserDefaults = UserDefaults.standard
        userDefaults.set("\(newCoordinate.latitude)", forKey: CURRENT_LOCATION_LATITUDE)
        userDefaults.set("\(newCoordinate.longitude)", forKey: CURRENT_LOCATION_LONGITUDE)
        userDefaults.synchronize()
        
        if let userLat = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LATITUDE) as? String{
            self.userLat = userLat
        }
        if let userLong = UserDefaults.standard.value(forKey: CURRENT_LOCATION_LONGITUDE) as? String{
            self.userLong = userLong
        }
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        
        // send location to firebase
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues([CURRENT_LOCATION_LATITUDE : userLat, CURRENT_LOCATION_LONGITUDE: userLong])
        geoFire.setLocation(location, forKey: Api.User.currentUserId) { (error) in
            if error == nil{
                // find user
                //print("setLocation")
                self.findUsers()
            }
        }
        
    }
}
