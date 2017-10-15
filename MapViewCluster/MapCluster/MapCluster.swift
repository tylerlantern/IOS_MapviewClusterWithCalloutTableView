//
//  CoordinateQuadTree.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 24/10/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import UIKit
import MapKit
func BoundingBoxForMapRect(mapRect : MKMapRect) -> BoundingBox{
    
    let topleft : CLLocationCoordinate2D = MKCoordinateForMapPoint(mapRect.origin)
    let botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
    let minLat : CLLocationDegrees = botRight.latitude
    let maxLat = topleft.latitude
    let minLon : CLLocationDegrees = topleft.longitude
    let maxLon : CLLocationDegrees = botRight.longitude
    return BoundingBox(x0: minLat, y0: minLon, xf: maxLat, yf: maxLon)
}
public protocol MapClusterDelegate  {
    func assignNodeDataUnderClusterAnnotation( node : QuadTreeNodeData , infos : [InfoCluster] )
    func insertNodeParticipate( node : QuadTreeNodeData , annotation : ClusterAnnotation )
}
public class MapCluster : NSObject {
    var delegate : MapClusterDelegate!
    lazy var queue : OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .default
        return q
    }()
    lazy var queueCrud :OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .userInitiated
        return q
    }()
    var root : QuadTreeNode!
    var tileRects : [MKMapRect] = [MKMapRect]()
    override init() {
        super.init()
    }
    var world : BoundingBox!
    func initilization(nodes : [QuadTreeNodeData]   )  {
        world = BoundingBox(latitude0: 19, longitude0: -166, latitudef: 72, longitudef: -53)
        self.root = QuadTreeBuildWithData(nodes: nodes, count: nodes.count, worldBoundingBox: world, capacity: 4)
    }
    func QuadTreeBuildWithData(nodes : [QuadTreeNodeData],count : Int,worldBoundingBox : BoundingBox , capacity : Int) -> QuadTreeNode{
        let root = QuadTreeNode(boundingBox: worldBoundingBox, bucketCapacity: capacity)
        for item in nodes {
            _ = root.QuadTreeNodeInsertData(node: root, data: item)
        }
        return root
    }
    var isZoomScaleChange = false
    var currentZoomScale : CGFloat = 0.0
    
    func doubleEqual(_ a: CGFloat, _ b: CGFloat) -> Bool {
        return fabs(a - b) < CGFloat.ulpOfOne
    }
    
    //    void TBQuadTreeTraverse(TBQuadTreeNode* node, TBQuadTreeTraverseBlock block)
    //    {
    //    block(node);
    //
    //    if (node->northWest == NULL) {
    //    return;
    //    }
    //
    //    TBQuadTreeTraverse(node->northWest, block);
    //    TBQuadTreeTraverse(node->northEast, block);
    //    TBQuadTreeTraverse(node->southWest, block);
    //    TBQuadTreeTraverse(node->southEast, block);
    //    }
    func insert<IFC : InfoCluster > ( mapView : MKMapView  ,node : QuadTreeNodeData , model : IFC.Type)  {
        let coordinate = CLLocationCoordinate2DMake(node.x, node.y)
        let annotation = ClusterAnnotation(c: coordinate, count: 1)
        mapView.addAnnotation(annotation)
       _  = root.QuadTreeNodeInsertData(node: root, data: node)
    }
    func  clusterAnnotationTraverse (node :QuadTreeNodeData ) {
        
    }
    func getWorldMapRect() -> MKMapRect {
        
        let coordinate1 = CLLocationCoordinate2DMake( world.x0 , world.y0)
        let coordinate2 = CLLocationCoordinate2DMake( world.xf , world.yf)
        let p1 = MKMapPointForCoordinate(coordinate1)
        let p2 = MKMapPointForCoordinate(coordinate2)
        let worldMapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y))
        return worldMapRect
    }
    func clusteredAnnotationsWithinMapRect<IFC : InfoCluster > ( model : IFC.Type , mapView : MKMapView  ){
        guard  root != nil else { return  }
        queue.cancelAllOperations()
        queueCrud.cancelAllOperations()
        let mapViewBoundsWidth = mapView.bounds.size.width
        let mapViewVisibleMapRectSizeWidth = CGFloat(mapView.visibleMapRect.size.width)
        let zoomScale : CGFloat = mapViewBoundsWidth / mapViewVisibleMapRectSizeWidth
        let zoomLevel = self.ZoomScaleToZoomlevel(scale: zoomScale)
        let targetMapRect =  zoomLevel <= 4 ?  getWorldMapRect() :  mapView.visibleMapRect
        self.currentZoomScale = zoomScale
        queue.addOperation {
            var clusterAnnotations = [ClusterAnnotation]()
            let TBCellSize  = self.CellSizeForZoomScale(zoomscale: zoomScale)
            let scalefactor = zoomScale / TBCellSize
            let minX = Int(floor((CGFloat(MKMapRectGetMinX(targetMapRect)) * scalefactor)))
            let maxX = Int(floor(CGFloat(MKMapRectGetMaxX(targetMapRect)) * scalefactor))
            let minY = Int(floor(CGFloat(MKMapRectGetMinY(targetMapRect)) * scalefactor))
            let maxY = Int(floor(CGFloat(MKMapRectGetMaxY(targetMapRect)) * scalefactor))
            self.tileRects.removeAll()
            for x in minX...maxX {
                let xF = CGFloat(x)
                for y in minY...maxY{
                    var totalX : Double = 0
                    var totalY : Double = 0
                    var count : Int = 0
                    let yF = CGFloat(y)
                    let mapRect = MKMapRectMake( Double(xF/scalefactor), Double(yF/scalefactor), Double(CGFloat(1.0)/scalefactor), Double(CGFloat(1.0)/scalefactor))
                    self.tileRects.append(mapRect)
                    let infos = [IFC]()
                    self.QuadTreeGatherDataInRange(node: self.root, range: BoundingBoxForMapRect(mapRect: mapRect), block: { (node) in
                        totalX += node.x
                        totalY += node.y
                        count += 1
                        self.delegate.assignNodeDataUnderClusterAnnotation(node: node, infos: infos)
                    },section: .none )
                    if count == 1{
                        let coordinate = CLLocationCoordinate2DMake(totalX, totalY)
                        let annotation = ClusterAnnotation(c: coordinate, count: count)
                        annotation.infos = infos
                        annotation.mapRect = mapRect
                        clusterAnnotations.append(annotation)
                    }
                    else {
                        let coordinate = CLLocationCoordinate2DMake(totalX / Double(count), totalY/Double(count))
                        let annotation = ClusterAnnotation(c: coordinate, count: count)
                        annotation.infos = infos
                        annotation.mapRect = mapRect
                        clusterAnnotations.append(annotation)
                    }
                }
            }
            self.updateMapViewAnnotationsWithAnnotations(mapView: mapView, annotations: clusterAnnotations)
        }
    }
    func CellSizeForZoomScale (zoomscale:MKZoomScale) -> CGFloat{
        let zoomlevel : Int = ZoomScaleToZoomlevel(scale: zoomscale)
        switch zoomlevel {
        case 13,14,15:
            return 64
        case 16,17,18:
            return 32
        case 19 :
            return 16
        default:
            return 88
        }
    }
    func ZoomScaleToZoomlevel(scale:MKZoomScale) -> Int{
        let totalTilesAtMaxZoom  = CGFloat( MKMapSizeWorld.width / 256.0)
        let zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom)
        let s =    zoomLevelAtMaxZoom +  floor(log2(scale) + 0.5)
        let zoomLevel = max(0, s )
        return Int(round(zoomLevel))
    }
    enum Section : Int {
        case none = 0
        ,northWest,northEast,southWest,southEast
    }
    func QuadTreeGatherDataInRange(node:QuadTreeNode,range : BoundingBox,block :  (QuadTreeNodeData) -> (),section :Section ){
        if !BoundingBoxIntersectsBoundingBox(b1: node.boundingBox, b2: range) {
            return ;
        }
        for n in node.points {
            if BoundingBoxContainsData(box: range, data: n){
                block(n)
            }
        }
        if node.northWest == nil {
            return;
        }
        QuadTreeGatherDataInRange(node: node.northWest!, range: range, block: block,section: .northWest)
        QuadTreeGatherDataInRange(node: node.northEast!, range: range, block: block,section: .northEast)
        QuadTreeGatherDataInRange(node: node.southWest!, range: range, block: block,section: .southWest)
        QuadTreeGatherDataInRange(node: node.southEast!, range: range, block: block,section: .southEast)
    }
    func updateMapViewAnnotationsWithAnnotations( mapView : MKMapView , annotations : [ClusterAnnotation])  {
        let before  = mapView.annotations as! [ClusterAnnotation]
        //        let index =  before.index { (a) -> Bool in
        //            a.coordinate.latitude == mapView.userLocation.coordinate.latitude &&
        //                a.coordinate.longitude == mapView.userLocation.coordinate.longitude
        //        }
        //        if let index = index {
        //            before.remove(at: index)
        //        }
        let after = annotations
        let tokeep = before.filter { (bf) -> Bool in
            after.contains(where: { (af) -> Bool in
                return af.coordinate.latitude == bf.coordinate.latitude && af.coordinate.longitude == bf.coordinate.longitude
            })
        }
        let toAdd = after.filter { (af) -> Bool in
            !tokeep.contains(where: { (tk) -> Bool in
                return af.coordinate.latitude == tk.coordinate.latitude && af.coordinate.longitude == tk.coordinate.longitude
            })
        }
        let toRemove = before.filter { (bf) -> Bool in
            !tokeep.contains(where: { (tk) -> Bool in
                return bf.coordinate.latitude == tk.coordinate.latitude && bf.coordinate.longitude == tk.coordinate.longitude
            })
        }
        DispatchQueue.main.async {
            mapView.removeAnnotations(toRemove)
            mapView.addAnnotations(toAdd)
        }
    }
}
