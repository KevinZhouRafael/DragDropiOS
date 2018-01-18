//
//  DragDropTableView.swift
//  Pods
//
//  Created by Rafael on 31/07/2017.
//
//


import UIKit


@objc public protocol DragDropTableViewDelegate : NSObjectProtocol {
    
    @objc optional func tableView(_ tableView: UITableView, indexPathForDragInfo dragInfo: AnyObject) -> IndexPath?
    func tableView(_ tableView: UITableView, dragInfoForIndexPath indexPath: IndexPath) -> AnyObject
    @objc optional func tableView(_ tableView: UITableView, representationImageAtIndexPath indexPath: IndexPath) -> UIImage?
    
    
    //drag
    func tableView(_ tableView: UITableView, touchBeginAtIndexPath indexPath:IndexPath) -> Void
    func tableView(_ tableView: UITableView, canDragAtIndexPath indexPath: IndexPath) -> Bool
    
    func tableView(_ tableView: UITableView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath,withDropInfo dropInfo:AnyObject?) -> Void
    func tableViewStopDragging(_ tableView: UITableView)->Void
    
    
    //drop
    func tableView(_ tableView: UITableView, canDropWithDragInfo info:AnyObject, AtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func tableView(_ tableView: UITableView, dropOutsideWithDragInfo info:AnyObject) -> Void
    func tableView(_ tableView: UITableView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath?,withDropInfo dropInfo:AnyObject?,atDropIndexPath dropIndexPath:IndexPath) -> Void
    func tableViewStopDropping(_ tableView: UITableView)->Void
    
}


@objc open class DragDropTableView: UITableView, Draggable, Droppable {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var draggingPathOfCellBeingDragged : IndexPath?
    
    fileprivate var iDataSource : UITableViewDataSource?
    fileprivate var iDelegate : UITableViewDelegate?
    
    open var dragDropDelegate:DragDropTableViewDelegate?
    

    func indexPathForCellOverlappingRect( _ rect : CGRect) -> IndexPath? {
        
        let centerPoint = CGPoint(x: rect.minX + rect.width/2, y: rect.minY + rect.height/2)
        
        
        for cell in visibleCells {
            
            if cell.frame.contains(centerPoint) {
                
                return self.indexPath(for: cell)
            }
            
        }
        
        return nil
    }

    open func checkFroEdgesAndScroll(_ item : AnyObject, inRect rect : CGRect) -> Void {
        startDisplayLink()
        
        // Check Paging
        var normalizedRect = rect
        normalizedRect.origin.x -= self.contentOffset.x
        normalizedRect.origin.y -= self.contentOffset.y
        
        
        dragRectCurrent = normalizedRect
        
    }
    
    
    
    
    //scroll relate
    fileprivate var displayLink: CADisplayLink?
    internal var scrollSpeedValue: CGFloat = 10.0
    fileprivate var dragRectCurrent:CGRect!
    
    fileprivate func startDisplayLink() {
        guard displayLink == nil else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(DragDropTableView.handlerDisplayLinkToContinuousScroll))
        displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    fileprivate func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        dragRectCurrent = nil
    }
    
    
    @objc func handlerDisplayLinkToContinuousScroll(){
        if dragRectCurrent == nil {
            return
        }
        
        let currentRect : CGRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        var rectForNextScroll : CGRect = currentRect
        
        // Only vertical
            //        debugPrint("drag view rect: \(dragRectCurrent) ———— super view rect\(currentRect)")
            let topBoundary = CGRect(x: 0.0, y: -30.0, width: self.frame.size.width, height: 30.0)
            let bottomBoundary = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 30.0)
            
            
            if dragRectCurrent.intersects(topBoundary) == true {
                rectForNextScroll.origin.y -= 5
                if rectForNextScroll.origin.y < 0 {
                    rectForNextScroll.origin.y = 0
                }
            }
            else if dragRectCurrent.intersects(bottomBoundary) == true {
            //              debugPrint("move in bottomboundary : \(dragRectCurrent)")
                rectForNextScroll.origin.y += 5
                if rectForNextScroll.origin.y > self.contentSize.height - self.bounds.size.height {
                    rectForNextScroll.origin.y = self.contentSize.height - self.bounds.size.height
                }
            }
        
        
        if currentRect.equalTo(rectForNextScroll) == false {
            
            scrollRectToVisible(rectForNextScroll, animated: false)
            
        }
    }
    
    
    // MARK : Draggable
    open func canDragAtPoint(_ point : CGPoint) -> Bool {
        
        guard self.dragDropDelegate != nil else {
            return false
        }
        if let indexPath = self.indexPathForRow(at: point) {
            
            return dragDropDelegate!.tableView(self, canDragAtIndexPath: indexPath)
            
        }
        
        return self.indexPathForRow(at: point) != nil
    }
    
    open func representationImageAtPoint(_ point : CGPoint) -> UIView? {
        
        var imageView : UIView?
        
        if let indexPath = self.indexPathForRow(at: point) {
            
            if dragDropDelegate != nil && dragDropDelegate!.responds(to: #selector(DragDropTableViewDelegate.tableView(_:representationImageAtIndexPath:))){
                
                if let cell = self.cellForRow(at: indexPath) {
                    let img = dragDropDelegate!.tableView!(self, representationImageAtIndexPath: indexPath)
                    
                    imageView = UIImageView(image: img)
                    imageView?.frame = cell.frame
                }
                
                
            }else{
                if let cell = self.cellForRow(at: indexPath) {
                    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
                    cell.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let img = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    imageView = UIImageView(image: img)
                    imageView?.frame = cell.frame
                }
            }
            
            
        }
        
        return imageView
    }
    
    open func dragInfoAtPoint(_ point : CGPoint) -> AnyObject? {
        
        var dataItem : AnyObject?
        
        if let indexPath = self.indexPathForRow(at: point) {
            
            if dragDropDelegate != nil {
                
                dataItem = dragDropDelegate!.tableView(self, dragInfoForIndexPath: indexPath)
                
            }
            
        }
        return dataItem
    }
    
    
    
    open func touchBeginAtPoint(_ point : CGPoint) -> Void {
        
        self.draggingPathOfCellBeingDragged = self.indexPathForRow(at: point)
        
        if dragDropDelegate != nil {
            
            dragDropDelegate!.tableView(self, touchBeginAtIndexPath: self.draggingPathOfCellBeingDragged!)
            
        }
        
        
    }
    
    
    
    open func stopDragging() -> Void {
        invalidateDisplayLink()
        
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForRow(at: idx) {
                cell.isHidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        if dragDropDelegate != nil {
            dragDropDelegate!.tableViewStopDragging(self)
            
        }
        
        
    }
    
    open func dragComplete(_ dragInfo:AnyObject,dropInfo : AnyObject?) -> Void {
        
        if dragDropDelegate != nil {
            
            if let dragIndexPath = draggingPathOfCellBeingDragged {
                
                dragDropDelegate!.tableView(self, dragCompleteWithDragInfo: dragInfo,atDragIndexPath: dragIndexPath,withDropInfo: dropInfo)
                
                
            }
            
        }
        
    }
    
    // MARK : Droppable
    
    open func canDropWithDragInfo(_ item: AnyObject,  inRect rect: CGRect) -> Bool {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.tableView(self, canDropWithDragInfo: item, AtIndexPath: indexPath)
                
            }
        }
        
        return false
    }
    
    open func dropOverInfoInRect(_ rect: CGRect) -> AnyObject? {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.tableView(self, dragInfoForIndexPath: indexPath)
                
            }
        }
        return nil
    }
    
    open func dropOutside(_ dragInfo: AnyObject, inRect rect: CGRect) {
        if dragDropDelegate != nil && dragDropDelegate!.responds(to: #selector(DragDropTableViewDelegate.tableView(_:dropOutsideWithDragInfo:))){
            dragDropDelegate!.tableView!(self, dropOutsideWithDragInfo: dragInfo)
        }
    }
    
    open func stopDropping() {
        if dragDropDelegate != nil {
            
            dragDropDelegate!.tableViewStopDropping(self)
            
        }
    }
    
    open func dropComplete(_ dragInfo : AnyObject,dropInfo:AnyObject?, atRect rect: CGRect) -> Void{
        
        if let dropIndexPath = self.indexPathForCellOverlappingRect(rect) {
            if  let dragIndexPath = draggingPathOfCellBeingDragged{
                if dragDropDelegate != nil {
                    dragDropDelegate!.tableView(self, dropCompleteWithDragInfo: dragInfo, atDragIndexPath: dragIndexPath, withDropInfo: dropInfo, atDropIndexPath: dropIndexPath)
                    
                }
                
            }else{
                if dragDropDelegate != nil {
                    dragDropDelegate!.tableView(self, dropCompleteWithDragInfo: dragInfo, atDragIndexPath: nil, withDropInfo: dropInfo, atDropIndexPath: dropIndexPath)
                    
                }
            }
            
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        self.reloadData()
        
    }
    


}
