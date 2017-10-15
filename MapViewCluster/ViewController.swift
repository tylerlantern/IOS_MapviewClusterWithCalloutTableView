//
//  ViewController.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 10/10/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {
    let  TBAnnotatioViewReuseID : String = "TBAnnotatioViewReuseID";
    var calloutView : CalloutView?
    var tempIndex = 0
        var testNodes : [HotelNode]!
    @IBAction func action_add(_ sender: Any) {
        tempIndex += 1
        cluster.insert(mapView: mapView, node: testNodes[tempIndex], model:  MyInfoCluster.self)
    }
    @IBOutlet weak var lb_currentCoordinate: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var cluster : MapCluster!

    override func viewDidLoad() {
        super.viewDidLoad()
                mapView.delegate = self
        //        coordinateQuadTree.buildTree()
        //        let initialLocation = CLLocation(latitude:13.7465004206227 , longitude: 100.528662553152)
        //        let regionRadius: CLLocationDistance = 3000
        //        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        //        let initialLocation = CLLocation(latitude:13.7465004206227 , longitude: 100.528662553152)
        //        let span = MKCoordinateSpan(latitudeDelta: 0.011608591217491693, longitudeDelta: 0.006799327030250879)
        //        let coordinateRegion = MKCoordinateRegionMake(initialLocation.coordinate, span)
        //        mapView.setRegion(coordinateRegion, animated: true)
        
        cluster = MapCluster()
        cluster.delegate = self
        cluster.initilization(nodes: self.buildTree(fileName: "USA-Part"))
        testNodes = self.buildTree(fileName: "USA-HotelMotel2")
        let initialLocation = CLLocation(latitude:28.22106 , longitude: -95.66974)
        let span = MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: CLLocationDegrees(100 * (UIScreen.main.bounds.width / UIScreen.main.bounds.height)) )
        let coordinateRegion = MKCoordinateRegionMake(initialLocation.coordinate, span)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func buildTree(fileName : String) -> [HotelNode]{
        let data : String
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else{
            print("cant load data");
            return []
        }
        data = try! String(contentsOfFile: path, encoding: String.Encoding.ascii)
        var line = data.components(separatedBy: "\n")
        let cline = line.count
        var nodes = [HotelNode]()
        for i in 0...cline-1 {
            if let node =  DataFromLine(line: line[i]) {
                nodes.append(node)
            }
        }
        return nodes
    }
    func DataFromLine(line:String) -> HotelNode? {
        if line == ""{
            return nil
        }
        let component = line.components(separatedBy: ",")
        let latitude =  (component[1] as NSString).doubleValue
        let longtitude = (component[0] as NSString).doubleValue
        let hotelName = component[2]
        let phoneNumber = component[3]
        var node = HotelNode(latitude: latitude, longitude: longtitude)
        node.name = hotelName
        node.phoneNumber = phoneNumber
        return node
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func addBounceAnimationToView(view : UIView) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [0.05,1.1,0.9,1]
        bounceAnimation.duration = 0.6
        let timingFunctions = [CAMediaTimingFunction](repeating: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), count: bounceAnimation.values!.count)
        bounceAnimation.timingFunctions = timingFunctions
        bounceAnimation.isRemovedOnCompletion = false
        view.layer.add(bounceAnimation, forKey: "bounce")
    }
}
extension ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        cluster.clusteredAnnotationsWithinMapRect(model: MyInfoCluster.self  , mapView: mapView)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TBAnnotatioViewReuseID) as? ClusterAnnotationView
        if annotationView == nil {
            annotationView = ClusterAnnotationView(initWith: annotation, reuseIdentifier: TBAnnotatioViewReuseID)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        let clusterAnnotation = annotation as! ClusterAnnotation
        annotationView?.setCount(count: clusterAnnotation.numberofChildren)
        return annotationView
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //        print("LAT:" + String(mapView.centerCoordinate.latitude) + " LONG:" + String(mapView.centerCoordinate.longitude))
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        //         print("LA:" + String(mapView.centerCoordinate.latitude) + " LO:" + String(mapView.centerCoordinate.longitude)
        //            + " Z:\(mapView.region.span)")
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            self.addBounceAnimationToView(view: view)
        }
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        calloutView = CalloutView(annotationView: view)
//        view.addSubview(calloutView!)
//        let annotationView = view as! myAnnotationView
//        let infoc = (annotationView.annotation as! ClusterAnnotation).infos as! [MyInfoCluster]
//        calloutView!.reload(infos: infoc)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        calloutView?.removeFromSuperview()
        calloutView = nil
    }
}
extension ViewController : MapClusterDelegate {
    func insertNodeParticipate(node: QuadTreeNodeData, annotation: ClusterAnnotation) {

        let hotelNode = node as! HotelNode
        let myInfo = MyInfoCluster(hotelName: hotelNode.name, phoneNumber: hotelNode.phoneNumber)
        annotation.infos.append(myInfo)
        annotation.numberofChildren += 1
        guard let annotationView = mapView.view(for: annotation) as? ClusterAnnotationView else {
            return
        }
        annotationView.setCount(count: annotation.numberofChildren)
//        annotationView.countLabel.text = String(annotation.numberofChildren)
    }
    func assignNodeDataUnderClusterAnnotation(node: QuadTreeNodeData, infos: [InfoCluster]) {
        let node = node as! HotelNode
        var infos = infos as! [MyInfoCluster]
        infos.append(MyInfoCluster(hotelName: node.name, phoneNumber: node.phoneNumber) )
    }
}

