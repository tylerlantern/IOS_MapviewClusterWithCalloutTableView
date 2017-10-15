//
//  QuadTree.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 10/10/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

//import Foundation
import UIKit
import MapKit


public protocol QuadTreeNodeData {
    var x : Double {get}
    var y : Double {get}
 }


struct BoundingBox {
    var x0 :Double
    var y0 :Double
    var xf :Double
    var yf :Double
    init(latitude0 : Double , longitude0 : Double,latitudef : Double , longitudef : Double ) {
        x0 = latitude0
        y0 = longitude0
        xf = latitudef
        yf = longitudef
    }
    init(x0 : Double , y0 : Double,xf : Double , yf : Double  ) {
        self.x0 = x0
        self.y0 = y0
        self.xf = xf
        self.yf = yf
    }
}

func BoundingBoxIntersectsBoundingBox(b1 : BoundingBox , b2 : BoundingBox) -> Bool{
        return b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0
}

func BoundingBoxContainsData(box:BoundingBox , data : QuadTreeNodeData) -> Bool{
    let containsx = box.x0 <=  data.x && data.x <= box.xf
    let containsY = box.y0 <= data.y && data.y <= box.yf
    return containsx && containsY
}





