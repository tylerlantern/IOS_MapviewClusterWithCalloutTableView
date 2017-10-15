//
//  TBClusterAnnotationView.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 30/11/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import UIKit
import MapKit

class myAnnotationView : ClusterAnnotationView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//hittest
extension myAnnotationView{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitview = super.hitTest(point, with: event)
        if hitview != nil {
            self.bringSubview(toFront: self)
            
        }
        return hitview
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds;
        var isInside: Bool = rect.contains(point);
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point);
                if isInside
                {
                    break;
                }
            }
        }
        return isInside;
    }
}

//let TBScaleFactorAlpha : Float = 0.3
//let TBScaleFactorBeta : Float = 0.4
//func TBScaledValueForValue(value : Int) -> Float {
//    return 1.0 / (1.0 + expf(-1 * TBScaleFactorAlpha * powf(Float(value), TBScaleFactorBeta)));
//}
//func TBCenterRect(rect:CGRect,center : CGPoint) -> CGRect{
//    let r = CGRect(x: center.x - rect.size.width / 2.0
//        , y: center.y - rect.size.height / 2.0
//        , width: rect.size.width,
//          height: rect.size.height)
//    return r
//}
//func TBRectCenter(rect : CGRect) -> CGPoint{
//    return CGPoint(x: rect.midX, y: rect.midY)
//}
