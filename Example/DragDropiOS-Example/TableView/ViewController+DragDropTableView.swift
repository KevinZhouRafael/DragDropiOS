//
//  ViewController+DragDropTableView.swift
//  DragDropiOS-Example
//
//  Created by yuhan on 01/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import DragDropiOS

extension ViewController:DragDropTableViewDelegate{
    func tableView(_ tableView: UITableView, touchBeginAtIndexPath indexPath: IndexPath) {
        
        clearCellsDrogStatusOfTableView()
        
    }
    
    func tableView(_ tableView: UITableView, representationImageAtIndexPath indexPath: IndexPath) -> UIImage? {
        
        
        if let cell = tableView.cellForRow(at: indexPath) {
            UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
            cell.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return img
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, canDragAtIndexPath indexPath: IndexPath) -> Bool {
        
        return tableModels[indexPath.item].fruit != nil
        
    }
    func tableView(_ tableView: UITableView, dragInfoForIndexPath indexPath: IndexPath) -> AnyObject {
        
        let dragInfo = Model()
        dragInfo.tableIndex = indexPath.item
        dragInfo.fruit = tableModels[indexPath.item].fruit
        
        return dragInfo
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canDropWithDragInfo dataItem: AnyObject, AtIndexPath indexPath: IndexPath) -> Bool {
        let dragInfo = dataItem as! Model
        
        let overInfo = tableModels[indexPath.item]
        
//        debugPrint("move over index: \(indexPath.item)")
        
        //drag source is mouse over item（self）
        if overInfo.fruit != nil{
            return false
        }
        
        clearCellsDrogStatusOfTableView()
        
        for cell in tableView.visibleCells{
            
                if overInfo.fruit == nil {
                    let cell = tableView.cellForRow(at: indexPath) as! DragDropTableViewCell
                    cell.moveOverStatus()
                    debugPrint("can drop in . index = \(indexPath.item)")
                    
                    return true
                }else{
                    debugPrint("can't drop in. index = \(indexPath.item)")
                }
            
            
        }
        
        return false
        
    }
    
    
    func tableView(_ tableView: UITableView, dropOutsideWithDragInfo info: AnyObject) {
        clearCellsDrogStatusOfTableView()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath,withDropInfo dropInfo:AnyObject?) -> Void{
        if (dropInfo != nil){
            
            tableModels[dragIndexPath.item].fruit = (dropInfo as! Model).fruit
        }else{
            tableModels[dragIndexPath.item].fruit = nil
        }
    }
    
    func tableView(_ tableView: UITableView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath?,withDropInfo dropInfo:AnyObject?,atDropIndexPath dropIndexPath:IndexPath) -> Void{
        tableModels[dropIndexPath.item].fruit = (dragInfo as! Model).fruit
        
    }
    
    
    func tableViewStopDropping(_ tableView: UITableView) {
        
        clearCellsDrogStatusOfTableView()
        
        tableView.reloadData()
    }
    
    func tableViewStopDragging(_ tableView: UITableView) {
        
        clearCellsDrogStatusOfTableView()
        
        tableView.reloadData()
        
    }
    
    
    func clearCellsDrogStatusOfTableView(){
        
        for cell in dragDropTableView.visibleCells{
            
            if (cell as! DragDropTableViewCell).hasContent() {
                (cell as! DragDropTableViewCell).selectedStatus()
                continue
            }
            
            (cell as! DragDropTableViewCell).nomoralStatus()
            
            
        }
        
    }
}
