//
//  ViewController.swift
//  DragDropiOS
//
//  Created by rafael zhou on 10/25/2016.
//  Copyright (c) 2016 rafael zhou. All rights reserved.
//

import UIKit
import DragDropiOS



class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,DragDropCollectionViewDelegate {
    
    var models:[Model] = [Model]()
    
    var dragDropManager:DragDropManager!
    
    @IBOutlet weak var dragDropCollectionView:DragDropCollectionView!
    @IBOutlet weak var dragDropView1:DragDropView!
    @IBOutlet weak var dragDropView2:DragDropView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< 20 {
            let model = Model()
            model.index = i
            if i == 0 {
                model.text = "Avocado"
                model.imageName = "Avocado"
            }
            if i == 1 {
                model.text = "Durian"
                model.imageName = "Durian"
            }
            if i == 2{
                model.text = "Mangosteen"
                model.imageName = "Mangosteen"
            }

            models.append(model)
        }
        
        dragDropCollectionView.backgroundColor = UIColor.white
        dragDropCollectionView.bounces = false
        dragDropCollectionView.dragDropDelegate = self
        
        dragDropManager = DragDropManager(canvas: self.view, views: [dragDropCollectionView,dragDropView1,dragDropView2])
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.IDENTIFIER, for: indexPath) as! CollectionViewCell
        
        cell.updateData(model)
        
        return cell
    }
    
    // MARK : DragDropCollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, touchBeginAtIndexPath indexPath: IndexPath) {
        
        clearCellsDrogStatus()
        
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
        
        return models[indexPath.item].text != nil
        
    }
    func collectionView(_ collectionView: UICollectionView, dragInfoForIndexPath indexPath: IndexPath) -> AnyObject {
        
        let dragInfo = Model()
        dragInfo.index = indexPath.item
        dragInfo.text = models[indexPath.item].text
        dragInfo.imageName = models[indexPath.item].imageName
        
        return dragInfo
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, canDropWithDragInfo dataItem: AnyObject, AtIndexPath indexPath: IndexPath) -> Bool {
        let dragInfo = dataItem as! Model
        
        let overInfo = models[indexPath.item]
        
        debugPrint("move over index: \(indexPath.item)")
        
        //drag source is mouse over item（self）
        if indexPath.item == dragInfo.index && dragInfo.text == overInfo.text {
            return false
        }
        
        clearCellsDrogStatus()
        
        for cell in collectionView.visibleCells{

            //update move over cell status
            if overInfo.index == (cell as! CollectionViewCell).model.index {
                
                if overInfo.text == nil {
                    let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
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
    
    
    func collectionView(_ collectionView: UICollectionView, dropOutsideWithDragInfo info: AnyObject) {
        clearCellsDrogStatus()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath,withDropInfo dropInfo:AnyObject?) -> Void{
        if (dropInfo != nil){
            
            models[dragIndexPath.item].text = (dropInfo as! Model).text
            models[dragIndexPath.item].imageName = (dropInfo as! Model).imageName
        }else{
            models[dragIndexPath.item].text = nil
            models[dragIndexPath.item].imageName = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath?,withDropInfo dropInfo:AnyObject?,atDropIndexPath dropIndexPath:IndexPath) -> Void{
        models[dropIndexPath.item].text = (dragInfo as! Model).text
        models[dropIndexPath.item].imageName = (dragInfo as! Model).imageName
        
    }
    

    func collectionViewStopDropping(_ collectionView: UICollectionView) {
        
        clearCellsDrogStatus()
        
        collectionView.reloadData()
    }
    
    func collectionViewStopDragging(_ collectionView: UICollectionView) {
        
        clearCellsDrogStatus()
        
        collectionView.reloadData()
        
    }
    
    
    func clearCellsDrogStatus(){
        
        for cell in dragDropCollectionView.visibleCells{

            if (cell as! CollectionViewCell).hasContent() {
                (cell as! CollectionViewCell).selectedStatus()
                continue
            }
            
            (cell as! CollectionViewCell).nomoralStatus()
            
            
        }
        
    }
}
