//
//  ClusterAnnotation.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 24/10/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class InfoCluster {

}
public class ClusterAnnotation : NSObject,MKAnnotation{
    var mCoordinate : CLLocationCoordinate2D
    private var _title : String?
    private var _subtitle : String?
    var mapRect :  MKMapRect?
    var numberofChildren : Int
    var totalCoordinatePoint :CGPoint = CGPoint.zero
    lazy var infos = [InfoCluster]()
    public var coordinate: CLLocationCoordinate2D {
        get{
            return mCoordinate
        }set{
            mCoordinate = newValue
        }
    }
    public var title: String?{
        return _title
    }
    public var subtitle: String?{
        return _subtitle
    }
    public func set(title  : String, subtitle : String) {
        self._title = title
        self._subtitle = subtitle
    }
    init(c : CLLocationCoordinate2D,count : Int) {
        self.mCoordinate = c
        self.numberofChildren = count
        self._title = "\(count) hotels in this area"
    }
}
func ==(lhs: ClusterAnnotation, rhs: ClusterAnnotation) -> Bool{
    return lhs.mCoordinate.latitude == rhs.mCoordinate.latitude && lhs.mCoordinate.longitude == rhs.mCoordinate.longitude
}
