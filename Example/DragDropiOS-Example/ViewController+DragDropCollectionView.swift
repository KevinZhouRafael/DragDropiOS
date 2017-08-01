//
//  ViewController+DragDropCollectionView.swift
//  DragDropiOS-Example
//
//  Created by yuhan on 31/07/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import DragDropiOS

 // MARK : DragDropCollectionViewDelegate
extension ViewController{
    func collectionView(_ collectionView: UICollectionView, touchBeginAtIndexPath indexPath: IndexPath) {
        
        clearCellsDrogStatusOfCollectionView()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, representationImageAtIndexPath indexPath: IndexPath) -> UIImage? {
        
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
            cell.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return img
        }
        
        return nil
        
    }
    
    func collectionView(_ collectionView: UICollectionView, canDragAtIndexPath indexPath: IndexPath) -> Bool {
        
        return models[indexPath.item].fruit != nil
        
    }
    func collectionView(_ collectionView: UICollectionView, dragInfoForIndexPath indexPath: IndexPath) -> AnyObject {
        
        let dragInfo = Model()
        dragInfo.collectionIndex = indexPath.item
        dragInfo.fruit = models[indexPath.item].fruit
        
        return dragInfo
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, canDropWithDragInfo dataItem: AnyObject, AtIndexPath indexPath: IndexPath) -> Bool {
        let dragInfo = dataItem as! Model
        
        let overInfo = models[indexPath.item]
        
        debugPrint("move over index: \(indexPath.item)")
        
        //drag source is mouse over item（self）
        if overInfo.fruit != nil{
            return false
        }
        
        clearCellsDrogStatusOfCollectionView()
        
        for cell in collectionView.visibleCells{
            

                if overInfo.fruit == nil {
                    let cell = collectionView.cellForItem(at: indexPath) as! DragDropCollectionViewCell
                    cell.moveOverStatus()
                    debugPrint("can drop in . index = \(indexPath.item)")
                    
                    return true
                }else{
                    debugPrint("can't drop in. index = \(indexPath.item)")
                }

            
        }
        
        return false
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dropOutsideWithDragInfo info: AnyObject) {
        clearCellsDrogStatusOfCollectionView()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath,withDropInfo dropInfo:AnyObject?) -> Void{
        if (dropInfo != nil){
            
            models[dragIndexPath.item].fruit = (dropInfo as! Model).fruit
        }else{
            models[dragIndexPath.item].fruit = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath?,withDropInfo dropInfo:AnyObject?,atDropIndexPath dropIndexPath:IndexPath) -> Void{
        models[dropIndexPath.item].fruit = (dragInfo as! Model).fruit
        
    }
    
    
    func collectionViewStopDropping(_ collectionView: UICollectionView) {
        
        clearCellsDrogStatusOfCollectionView()
        
        collectionView.reloadData()
    }
    
    func collectionViewStopDragging(_ collectionView: UICollectionView) {
        
        clearCellsDrogStatusOfCollectionView()
        
        collectionView.reloadData()
        
    }
    
    
    func clearCellsDrogStatusOfCollectionView(){
        
        for cell in dragDropCollectionView.visibleCells{
            
            if (cell as! DragDropCollectionViewCell).hasContent() {
                (cell as! DragDropCollectionViewCell).selectedStatus()
                continue
            }
            
            (cell as! DragDropCollectionViewCell).nomoralStatus()
            
            
        }
        
    }
}
