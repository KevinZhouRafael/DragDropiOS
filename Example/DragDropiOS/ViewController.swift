//
//  ViewController.swift
//  DragDropiOS
//
//  Created by rafael zhou on 10/25/2016.
//  Copyright (c) 2016 rafael zhou. All rights reserved.
//

import UIKit
import DragDropiOS

class Model {
    var index:Int!
    var text:String?

}

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,DragDropCollectionViewDelegate {
    
    
    var models:[Model] = [Model]()
    
    var dragDropManager:DragDropManager!
    
    @IBOutlet weak var collectionView:DragDropCollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< 20 {
            let model = Model()
            model.index = i
            if i % 7 == 0 {
                model.text = "text\(i)"
            }
            models.append(model)
        }
        
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.bounces = false
        collectionView.dragDropDelegate = self
        
        dragDropManager = DragDropManager(canvas: self.view, collectionViews: [collectionView])
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCell.IDENTIFIER, forIndexPath: indexPath) as! CollectionViewCell
        
        cell.updateData(model)
        
        return cell
    }
    
    // MARK : DragDropCollectionViewDelegate
    func collectionView(collectionView: UICollectionView, touchBeginAtIndexPath indexPath: NSIndexPath) {
        
        clearCellsDrogStatus()
        
    }
    
    func collectionView(collectionView: UICollectionView, canDragAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return models[indexPath.item].text != nil
        
    }
    func collectionView(collectionView: UICollectionView, dragInfoForIndexPath indexPath: NSIndexPath) -> AnyObject {
        
        let dragInfo = Model()
        dragInfo.index = indexPath.item
        dragInfo.text = models[indexPath.item].text
        
        return dragInfo
    }
    
    
    func collectionView(collectionView: UICollectionView, canDropWithDragInfo dataItem: AnyObject, AtIndexPath indexPath: NSIndexPath) -> Bool {
        let dragInfo = dataItem as! Model
        
        let overInfo = models[indexPath.item]
        
        debugPrint("move over index: \(indexPath.item)")
        
        if indexPath.item == dragInfo.index {
            return false
        }
        
        clearCellsDrogStatus()
        
        for cell in collectionView.visibleCells(){

            //update move over cell status
            if overInfo.index == (cell as! CollectionViewCell).model.index {
                
                if overInfo.text == nil {
                    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
                    cell.moveOverStatus()
                    debugPrint("can drop in . index = \(indexPath.item)")
                    
                    return true
                }else{
                    debugPrint("can't drop in. index = \(indexPath.item)")
                }
                
            }
            
        }
        
        return false
        
    }
    
    func collectionView(collectionView: UICollectionView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: NSIndexPath,withDropInfo dropInfo:AnyObject) -> Void{
        models[dragIndexPath.item].text = (dropInfo as! Model).text
    }
    
    func collectionView(collectionView: UICollectionView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: NSIndexPath,withDropInfo dropInfo:AnyObject,atDropIndexPath dropIndexPath:NSIndexPath) -> Void{
        models[dropIndexPath.item].text = (dragInfo as! Model).text
        
    }
    

    func collectionViewStopDropping(collectionView: UICollectionView) {
        
    }
    
    func collectionViewStopDragging(collectionView: UICollectionView) {
        
        clearCellsDrogStatus()
        
        collectionView.reloadData()
        
    }
    
    
    func clearCellsDrogStatus(){
        
        for cell in collectionView.visibleCells(){

            if (cell as! CollectionViewCell).hasContent() {
                (cell as! CollectionViewCell).selectedStatus()
                continue
            }
            
            (cell as! CollectionViewCell).nomoralStatus()
            
            
        }
        
    }
}
