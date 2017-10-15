//
//  HtotelNode.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 10/13/17.
//  Copyright © 2017 Nattapong Unaregul. All rights reserved.
//

import UIKit

struct HotelNode : QuadTreeNodeData {
    var x: Double
    var y: Double
    var name : String?
    var phoneNumber : String?
    
    init( latitude : Double , longitude : Double) {
        x = latitude
        y = longitude
    }
}
