//
//  QuadTreeNode.swift
//  MapViewCluster
//
//  Created by Nattapong Unaregul on 24/10/2016.
//  Copyright © 2016 Nattapong. All rights reserved.
//

import UIKit

public class QuadTreeNode {
    
    var northWest : QuadTreeNode?
    var northEast : QuadTreeNode?
    var southWest : QuadTreeNode?
    var southEast : QuadTreeNode?
    
    let boundingBox : BoundingBox
    var points : [QuadTreeNodeData]
    let bucketCapacity :  Int
    var count : Int = 0
    var debugString : String = ""
    init(boundingBox : BoundingBox,bucketCapacity:Int) {
        self.boundingBox = boundingBox
        self.bucketCapacity = bucketCapacity
        self.points = [QuadTreeNodeData]()
    }
    func QuadTreeNodeSubdivide(node:QuadTreeNode) {
        let box = node.boundingBox
        let xMid : Double = (box.xf + box.x0) / 2.0
        let yMid : Double = (box.yf + box.y0) / 2.0
        let northWest = BoundingBox(x0: box.x0, y0: box.y0, xf: xMid, yf: yMid)
        let northEast = BoundingBox(x0: xMid, y0: box.y0, xf: box.xf, yf: yMid)
        let southWest = BoundingBox(x0: box.x0, y0: yMid, xf: xMid, yf: box.yf)
        let southEast = BoundingBox(x0: xMid, y0: yMid, xf: box.xf, yf: box.yf)
        
//        print("start QuadTreeNodeSubdivide node:\(node.boundingBox)")
//        print("northWest:\(northWest)")
//        print("northEast:\(northEast)")
//        print("southWest:\(southWest)")
//        print("southEast:\(southEast)")
//        print("end QuadTreeNodeSubdivide")
        node.northWest = QuadTreeNode(boundingBox: northWest, bucketCapacity: node.bucketCapacity);
        node.northEast = QuadTreeNode(boundingBox: northEast, bucketCapacity: node.bucketCapacity);
        node.southWest = QuadTreeNode(boundingBox: southWest, bucketCapacity: node.bucketCapacity);
        node.southEast = QuadTreeNode(boundingBox: southEast, bucketCapacity: node.bucketCapacity);
    }
    func QuadTreeNodeInsertData(node: QuadTreeNode,data : QuadTreeNodeData ) -> Bool {
        guard BoundingBoxContainsData(box: node.boundingBox, data: data) else {
//            print("nic: \(data.hotelInfo.hotelName) \(node.boundingBox) Lat:\(data.x) Long:\(data.y)")
            return false
        }
        if node.points.count < node.bucketCapacity {
//            print("about to insert to node :insertedData:\(data.hotelInfo.hotelName) \(node.boundingBox) ")
            node.points.append(data)
            count += 1
            return true
        }
        if node.northWest == nil {
            QuadTreeNodeSubdivide(node: node)
        }
        if QuadTreeNodeInsertData(node: node.northWest!, data: data) {
            return true
        }
        if QuadTreeNodeInsertData(node: node.northEast!, data: data){
            return true
        }
        if QuadTreeNodeInsertData(node: node.southWest!, data: data){
            return true
        }
        if QuadTreeNodeInsertData(node: node.southEast!, data: data){
            return true
        }
        return false
    }
}
