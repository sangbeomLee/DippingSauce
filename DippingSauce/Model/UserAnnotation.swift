//
//  UserAnnotation.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/13.
//  Copyright © 2020 이상범. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: MKPointAnnotation{
    var uid: String?
    var age: Int?
    var profileImage: UIImage?
    var isMale: Bool?
    
}
