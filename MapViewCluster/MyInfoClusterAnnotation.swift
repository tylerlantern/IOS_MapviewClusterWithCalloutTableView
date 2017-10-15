//
//  MyInfoClusterAnnotation.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 10/13/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import UIKit

class MyInfoCluster: InfoCluster {
    var hotelName : String?
    var phoneNumber : String?
    init( hotelName : String? , phoneNumber : String?) {
        self.hotelName = hotelName
        self.phoneNumber = phoneNumber
    }
}
