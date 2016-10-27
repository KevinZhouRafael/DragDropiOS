//
//  DragDropCollectionView.swift
//  DragDropCollectionView
//
//  Created by Rafael on 10/24/2016.
//  modified by rafael
//  Copyright (c) 2016 Rafael. All rights reserved.
//

import UIKit


@objc public protocol DragDropCollectionViewDelegate : NSObjectProtocol {
    
    optional func collectionView(collectionView: UICollectionView, indexPathForDragInfo dragInfo: AnyObject) -> NSIndexPath?
    func collectionView(collectionView: UICollectionView, dragInfoForIndexPath indexPath: NSIndexPath) -> AnyObject
    optional func collectionView(collectionView: UICollectionView, representationImageAtIndexPath indexPath: NSIndexPath) -> UIImage?
    
    
    //drag
    func collectionView(collectionView: UICollectionView, touchBeginAtIndexPath indexPath:NSIndexPath) -> Void
    func collectionView(collectionView: UICollectionView, canDragAtIndexPath indexPath: NSIndexPath) -> Bool

    func collectionView(collectionView: UICollectionView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: NSIndexPath,withDropInfo dropInfo:AnyObject) -> Void
    func collectionViewStopDragging(collectionView: UICollectionView)->Void
    
    
    //drop
    func collectionView(collectionView: UICollectionView, canDropWithDragInfo info:AnyObject, AtIndexPath indexPath: NSIndexPath) -> Bool
    func collectionView(collectionView: UICollectionView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: NSIndexPath,withDropInfo dropInfo:AnyObject,atDropIndexPath dropIndexPath:NSIndexPath) -> Void
    func collectionViewStopDropping(collectionView: UICollectionView)->Void
    
}


@objc public class DragDropCollectionView: UICollectionView, Draggable, Droppable {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var draggingPathOfCellBeingDragged : NSIndexPath?
    
    private var iDataSource : UICollectionViewDataSource?
    private var iDelegate : UICollectionViewDelegate?
    
    public var dragDropDelegate:DragDropCollectionViewDelegate?
    
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    
    }
    

    // MARK : Draggable
    public func canDragAtPoint(point : CGPoint) -> Bool {
        
        guard self.dragDropDelegate != nil else {
            return false
        }
        
        if let indexPath = self.indexPathForItemAtPoint(point) {

            return dragDropDelegate!.collectionView(self, canDragAtIndexPath: indexPath)
            
        }
        
        return self.indexPathForItemAtPoint(point) != nil
    }
    
    public func representationImageAtPoint(point : CGPoint) -> UIView? {
        
        var imageView : UIView?
        
        if let indexPath = self.indexPathForItemAtPoint(point) {
            
            if dragDropDelegate != nil && dragDropDelegate!.respondsToSelector(#selector(DragDropCollectionViewDelegate.collectionView(_:representationImageAtIndexPath:))){
                
                if let cell = self.cellForItemAtIndexPath(indexPath) {
                    let img = dragDropDelegate!.collectionView!(self, representationImageAtIndexPath: indexPath)
                    
                    imageView = UIImageView(image: img)
                    imageView?.frame = cell.frame
                }
                
                
            }else{
                if let cell = self.cellForItemAtIndexPath(indexPath) {
                    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
                    cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                    let img = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    imageView = UIImageView(image: img)
                    imageView?.frame = cell.frame
                }
            }


        }
        
        return imageView
    }
    
    public func dragInfoAtPoint(point : CGPoint) -> AnyObject? {
        
        var dataItem : AnyObject?
        
        if let indexPath = self.indexPathForItemAtPoint(point) {
            
            if dragDropDelegate != nil {
                
                dataItem = dragDropDelegate!.collectionView(self, dragInfoForIndexPath: indexPath)
                
            }
            
        }
        return dataItem
    }
    
    
    
    public func touchBeginAtPoint(point : CGPoint) -> Void {
        
        self.draggingPathOfCellBeingDragged = self.indexPathForItemAtPoint(point)
        
        if dragDropDelegate != nil {
    
            dragDropDelegate!.collectionView(self, touchBeginAtIndexPath: self.draggingPathOfCellBeingDragged!)
            
        }

        
    }
    

    
    public func stopDragging() -> Void {
        invalidateDisplayLink()
        
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItemAtIndexPath(idx) {
                cell.hidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        if dragDropDelegate != nil {
            dragDropDelegate!.collectionViewStopDragging(self)
            
        }
        
        
    }
    
    public func dragComplete(dragInfo:AnyObject,dropInfo : AnyObject) -> Void {
        
        if dragDropDelegate != nil {
            
            if let dragIndexPath = draggingPathOfCellBeingDragged {
                
                dragDropDelegate!.collectionView(self, dragCompleteWithDragInfo: dragInfo,atDragIndexPath: dragIndexPath,withDropInfo: dropInfo)
                
                
            }
            
        }
        
    }
    
    // MARK : Droppable

    public func canDropWithDragInfo(item: AnyObject,  inRect rect: CGRect) -> Bool {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.collectionView(self, canDropWithDragInfo: item, AtIndexPath: indexPath)
                
            }
        }
        
        return false
    }

    public func dropOverInfoInRect(rect: CGRect) -> AnyObject? {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.collectionView(self, dragInfoForIndexPath: indexPath)
                
            }
        }
        return nil
    }
    

    func indexPathForCellOverlappingRect( rect : CGRect) -> NSIndexPath? {
        
        let centerPoint = CGPoint(x: rect.minX + rect.width/2, y: rect.minY + rect.height/2)
        
        
        for cell in visibleCells() {
            
            if CGRectContainsPoint(cell.frame, centerPoint) {
                
                return self.indexPathForCell(cell)
            }
            
        }

        return nil
    }
    
    public func stopDropping() {
        if dragDropDelegate != nil {
            
            dragDropDelegate!.collectionViewStopDropping(self)
            
        }
    }
    

    
 
    var isHorizontal : Bool {
        return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .Horizontal
    }
    
    
    public func checkFroEdgesAndScroll(item : AnyObject, inRect rect : CGRect) -> Void {
        startDisplayLink()
        
        // Check Paging
        var normalizedRect = rect
        normalizedRect.origin.x -= self.contentOffset.x
        normalizedRect.origin.y -= self.contentOffset.y
        
        
        dragRectCurrent = normalizedRect
        
    }
    
    public func dropComplete(dragInfo : AnyObject,dropInfo:AnyObject, atRect rect: CGRect) -> Void{
        
        if let dropIndexPath = self.indexPathForCellOverlappingRect(rect) {
            if  let dragIndexPath = draggingPathOfCellBeingDragged{
                if dragDropDelegate != nil {
                    dragDropDelegate!.collectionView(self, dropCompleteWithDragInfo: dragInfo, atDragIndexPath: dragIndexPath, withDropInfo: dropInfo, atDropIndexPath: dropIndexPath)
                    
                }
                
            }

        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        self.reloadData()
        
    }
    
    


    //scroll relate
    private var displayLink: CADisplayLink?
    internal var scrollSpeedValue: CGFloat = 10.0
    var scrollDirection:UICollectionViewScrollDirection = .Vertical
    private var dragRectCurrent:CGRect!
    
    private func startDisplayLink() {
        guard displayLink == nil else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(DragDropCollectionView.handlerDisplayLinkToContinuousScroll))
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        dragRectCurrent = nil
    }
    
    
    func handlerDisplayLinkToContinuousScroll(){
        if dragRectCurrent == nil {
            return
        }
        
        let currentRect : CGRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        var rectForNextScroll : CGRect = currentRect
        
        if isHorizontal {
            
            let leftBoundary = CGRect(x: -30.0, y: 0.0, width: 30.0, height: self.frame.size.height)
            let rightBoundary = CGRect(x: self.frame.size.width, y: 0.0, width: 30.0, height: self.frame.size.height)
            
            if CGRectIntersectsRect(dragRectCurrent, leftBoundary) == true {
                rectForNextScroll.origin.x -= self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x < 0 {
                    rectForNextScroll.origin.x = 0
                }
            }
            else if CGRectIntersectsRect(dragRectCurrent, rightBoundary) == true {
                rectForNextScroll.origin.x += self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x > self.contentSize.width - self.bounds.size.width {
                    rectForNextScroll.origin.x = self.contentSize.width - self.bounds.size.width
                }
            }
            
        } else { // is vertical
//            debugPrint("drag view rect: \(dragRectCurrent) ———— super view rect\(currentRect)")
            let topBoundary = CGRect(x: 0.0, y: -30.0, width: self.frame.size.width, height: 30.0)
            let bottomBoundary = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 30.0)
            
            
            if CGRectIntersectsRect(dragRectCurrent, topBoundary) == true {
                rectForNextScroll.origin.y -= 5
                if rectForNextScroll.origin.y < 0 {
                    rectForNextScroll.origin.y = 0
                }
            }
            else if CGRectIntersectsRect(dragRectCurrent, bottomBoundary) == true {
//                debugPrint("move in bottomboundary : \(dragRectCurrent)")
                rectForNextScroll.origin.y += 5
                if rectForNextScroll.origin.y > self.contentSize.height - self.bounds.size.height {
                    rectForNextScroll.origin.y = self.contentSize.height - self.bounds.size.height
                }
            }
        }
        
        if CGRectEqualToRect(currentRect, rectForNextScroll) == false {
            
            scrollRectToVisible(rectForNextScroll, animated: false)

        }
    }

}
