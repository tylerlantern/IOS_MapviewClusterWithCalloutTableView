//
//  CalloutView.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 3/11/2560 BE.
//  Copyright © 2560 Nattapong. All rights reserved.
//

import UIKit
import  MapKit
/// This callout view is used to render a custom callout bubble for an annotation view.
/// The size of this is dictated by the constraints that are established between the
/// this callout view's `contentView` and its subviews (e.g. if those subviews have their
/// own intrinsic size). Or, alternatively, you always could define explicit width and height
/// constraints for the callout.
///
/// This is an abstract class that you won't use by itself, but rather subclass to and fill
/// with the appropriate content inside the `contentView`. But this takes care of all of the
/// rendering of the bubble around the callout.
class CalloutView: UIControl {
    enum BubblePointerType {
        case rounded
        case straight(angle: CGFloat)
    }
    enum TakePlaceWhere{
        case Top
        case Bottom
    }
    let margin : CGFloat = 4
    let width : CGFloat = 220
    let height : CGFloat = 150
    var anchorPoint : CGPoint = CGPoint(x: 0, y: 0)
    var noOfItem : Int = 0
    private let bubblePointerType = BubblePointerType.rounded
    let inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var parentViewFrame : CGRect!
    var parentViewBound : CGRect!
    let spaceBtwAnnotationView : CGFloat = 15
    let curvedOfAnchor : CGFloat = 50
    var infoitems : [MyInfoCluster]?
    let reuseIdentifier = "reusecell"
    var tableViewCell : UITableViewCell!
    private let bubbleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private let tableView : UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInitialization()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInitialization()
    }
    init(annotationView : MKAnnotationView) {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        Initialization(parentView: annotationView)
    }
    override func layoutSubviews() {
        drawPath()
    }
    
    private func Initialization(parentView : UIView){
        parentViewFrame = parentView.frame
        parentViewBound = parentView.bounds
        self.backgroundColor = UIColor.black
        self.layer.insertSublayer(bubbleLayer, at: 0)
        self.layer.mask = self.bubbleLayer
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableViewCell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.rowHeight = 35
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-self.inset.bottom)
        self.addSubview(self.tableView)
        
        let ySupposedPositionF = parentView.frame.origin.y - height
        let xSupposedPositionF = parentView.frame.midX - width / 2
        let screenWidth =  UIScreen.main.bounds.width
        anchorPoint.x = parentView.bounds.width / 2
        anchorPoint.y = 0
        var x : CGFloat = 0
        var y : CGFloat = 0
        if xSupposedPositionF < 0 {
            x = -1 * parentView.frame.origin.x + margin
        }else if xSupposedPositionF + width  > screenWidth  {
            x = parentView.bounds.midX - (width / 2) - (xSupposedPositionF + width - screenWidth) - margin
            
        }else {
            x = parentView.bounds.midX - width / 2
        }
        
        if ySupposedPositionF < 0 {
            y = parentView.bounds.height
        }else{
            y =   -1 * ( height)
        }
        self.frame.origin = CGPoint(x: x, y: y)
    }
    private func sharedInitialization() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.backgroundColor = UIColor.darkGray
        self.tableViewCell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.layer.insertSublayer(bubbleLayer, at: 0)
        self.layer.mask = self.bubbleLayer
        self.tableView.rowHeight = 35
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-self.inset.bottom)
        self.addSubview(self.tableView)
        
    }
    func reload(infos : [MyInfoCluster]?){
        
        guard let infos = infos else { return  }
        self.noOfItem = infos.count
        self.infoitems = infos
        self.tableView.reloadData()
        
    }
    private func drawPath(){
        let path = UIBezierPath()
        var point: CGPoint
        var controlPoint: CGPoint
        point = CGPoint(x: 0 + inset.left, y: 0)
        path.move(to: point)
        
        
        point.x = width - inset.right
        path.addLine(to: point)
        
        //Top Right
        controlPoint = CGPoint(x: width, y: 0)
        point = CGPoint(x: width, y: inset.top)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        
        
        
        //Right
        point = CGPoint(x: width, y: height - spaceBtwAnnotationView - inset.bottom)
        path.addLine(to: point)
        
        
        anchorPoint.x = (parentViewBound.width / 2 - self.frame.origin.x)
        anchorPoint.y = self.height - spaceBtwAnnotationView
        //Bottom Right
        controlPoint = CGPoint(x: width, y: height - spaceBtwAnnotationView )
        if  anchorPoint.x + curvedOfAnchor > self.width {
            point = CGPoint(x: width, y: height - spaceBtwAnnotationView )
        }else{
            point = CGPoint(x: width - inset.right, y: height - spaceBtwAnnotationView )
        }
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        
        //CalloutView is placed above an annotation view.
        if self.frame.origin.y < 0 {
            if  !(anchorPoint.x + curvedOfAnchor > self.width) {
                point.x = anchorPoint.x + curvedOfAnchor
            }
            
            path.addLine(to: point)
            
            point = CGPoint(x: anchorPoint.x, y: self.height)
            path.addQuadCurve(to: point, controlPoint: anchorPoint)
            
            point = CGPoint(x: anchorPoint.x - curvedOfAnchor, y: self.height - spaceBtwAnnotationView)
            
            if point.x < 0 {
                point.x = 0
                path.addQuadCurve(to: point, controlPoint: anchorPoint)
            }else{
                path.addQuadCurve(to: point, controlPoint: anchorPoint)
                
                //Bottom
                point = CGPoint(x: 0 + inset.left, y: height - spaceBtwAnnotationView)
                path.addLine(to: point)
                
                //Bottom Left
                controlPoint = CGPoint(x: 0, y: height - spaceBtwAnnotationView )
                point = CGPoint(x: 0, y: height - spaceBtwAnnotationView - inset.bottom)
                path.addQuadCurve(to: point, controlPoint: controlPoint)
                
                
                
            }
        }
        
        
        
        
        //Left
        point = CGPoint(x: 0 , y: 0 + inset.top)
        path.addLine(to: point)
        
        //Top Left
        controlPoint = CGPoint(x: 0, y: 0 )
        point = CGPoint(x: 0 + inset.left, y: 0)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        path.close()
        bubbleLayer.path = path.cgPath
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        var point: CGPoint
        var controlPoint: CGPoint
        
        point = CGPoint(x: bounds.size.width - inset.right, y: bounds.size.height - inset.bottom)
        path.move(to: point)
        
        switch bubblePointerType {
        case .rounded:
            // lower right
            point = CGPoint(x: bounds.size.width / 2.0 + inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)
            
            // right side of arrow
            controlPoint = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height - inset.bottom)
            point = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height)
            path.addQuadCurve(to: point, controlPoint: controlPoint)
            
            // left of pointer
            controlPoint = CGPoint(x: point.x, y: bounds.size.height - inset.bottom)
            point = CGPoint(x: point.x - inset.bottom, y: controlPoint.y)
            path.addQuadCurve(to: point, controlPoint: controlPoint)
        case .straight(let angle):
            // lower right
            point = CGPoint(x: bounds.size.width / 2.0 + tan(angle) * inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)
            
            // right side of arrow
            point = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height)
            path.addLine(to: point)
            
            // left of pointer
            point = CGPoint(x: bounds.size.width / 2.0 - tan(angle) * inset.bottom, y: bounds.size.height - inset.bottom)
            path.addLine(to: point)
        }
        
        // bottom left
        
        point.x = inset.left
        path.addLine(to: point)
        //
        //        // lower left corner
        //
        controlPoint = CGPoint(x: 0, y: bounds.size.height - inset.bottom)
        point = CGPoint(x: 0, y: controlPoint.y - inset.left)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        //
        //        // left
        //
        point.y = inset.top
        path.addLine(to: point)
        
        controlPoint = CGPoint(x: 0, y: 0)
        point = CGPoint(x: inset.left, y: 0)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        
        point = CGPoint(x: bounds.size.width - inset.left, y: 0)
        path.addLine(to: point)
        // top right corner
        controlPoint = CGPoint(x: bounds.size.width, y: 0)
        point = CGPoint(x: bounds.size.width, y: inset.top)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        // right
        point = CGPoint(x: bounds.size.width, y: bounds.size.height - inset.bottom - inset.right)
        path.addLine(to: point)
        // lower right corner
        controlPoint = CGPoint(x:bounds.size.width, y: bounds.size.height - inset.bottom)
        point = CGPoint(x: bounds.size.width - inset.right, y: bounds.size.height - inset.bottom)
        path.addQuadCurve(to: point, controlPoint: controlPoint)
        path.close()
        bubbleLayer.path = path.cgPath
    }
    /// Add this `CalloutView` to an annotation view (i.e. show the callout on the map above the pin)
    ///
    /// - Parameter annotationView: The annotation to which this callout is being added.
    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)
        
        // constraints for this callout with respect to its superview
        
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: annotationView.calloutOffset.y),
            centerXAnchor.constraint(equalTo: annotationView.centerXAnchor, constant: annotationView.calloutOffset.x)
            ])
    }
}
extension CalloutView :UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noOfItem
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        cell?.textLabel?.text = infoitems![indexPath.item].hotelName
        return cell!
    }
}



