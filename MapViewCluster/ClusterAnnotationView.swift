//
//  TBClusterAnnotationView.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 30/11/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import UIKit
import MapKit

struct animationPoint {
    var x : CGFloat
    var y : CGFloat
}

class ClusterAnnotationView : MKAnnotationView {
    var countLabel : UILabel!
    var containerView : UIView!
    var count : Int = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    init(initWith annotation : MKAnnotation,reuseIdentifier : String) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupLabel()
        self.setCount(count: 1)
    }
    func setupLabel() {
        
        containerView = UIView()
        containerView.backgroundColor = UIColor.orange
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 2
        containerView.clipsToBounds = true
        
        countLabel = UILabel()
        countLabel.backgroundColor = UIColor.clear
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        countLabel.shadowColor = UIColor(white: 0, alpha: 0.75)
        
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.numberOfLines = 1
        countLabel.font = UIFont.boldSystemFont(ofSize: 14)
        countLabel.baselineAdjustment = .alignCenters
        
        containerView.addSubview(countLabel)
        self.addSubview(containerView)
        
        
        
    }
    func setCount(count : Int){
        
        
        //        CGRect newBounds = CGRectMake(0, 0, roundf(44 * TBScaledValueForValue(count)), roundf(44 * TBScaledValueForValue(count)));
        //        self.frame = TBCenterRect(newBounds, self.center);
        //        CGRect newLabelBounds = CGRectMake(0, 0, newBounds.size.width / 1.3, newBounds.size.height / 1.3);
        //        self.countLabel.frame = TBCenterRect(newLabelBounds, TBRectCenter(newBounds));
        self.count = count
        let scale = CGFloat(roundf(37 * TBScaledValueForValue(value:count)))
        let newBound = CGRect(x: 0.0, y: 0.0, width: scale, height: scale)
        self.frame = newBound
        
        let newContainerBounds = CGRect(x: 0.0, y: 0.0, width: newBound.size.width / 1.3, height: newBound.size.height / 1.3)
        
        
        
        self.containerView.frame = TBCenterRect(rect: newContainerBounds, center: TBRectCenter(rect: newBound))
        self.countLabel.frame = self.containerView.frame
        
        self.containerView.bounds = newBound
        
        self.countLabel.text = String(count)

    }
    
    let TBScaleFactorAlpha : Float = 0.3
    let TBScaleFactorBeta : Float = 0.4
    func TBScaledValueForValue(value : Int) -> Float {
        return 1.0 / (1.0 + expf(-1 * TBScaleFactorAlpha * powf(Float(value), TBScaleFactorBeta)));
    }
    func TBCenterRect(rect:CGRect,center : CGPoint) -> CGRect{
        let r = CGRect(x: center.x - rect.size.width / 2.0
            , y: center.y - rect.size.height / 2.0
            , width: rect.size.width,
              height: rect.size.height)
        return r
    }
    func TBRectCenter(rect : CGRect) -> CGPoint{
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    
}
extension ClusterAnnotationView{
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


