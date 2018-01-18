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
    
    @objc optional func collectionView(_ collectionView: UICollectionView, indexPathForDragInfo dragInfo: AnyObject) -> IndexPath?
    func collectionView(_ collectionView: UICollectionView, dragInfoForIndexPath indexPath: IndexPath) -> AnyObject
    @objc optional func collectionView(_ collectionView: UICollectionView, representationImageAtIndexPath indexPath: IndexPath) -> UIImage?
    
    
    //drag
    func collectionView(_ collectionView: UICollectionView, touchBeginAtIndexPath indexPath:IndexPath) -> Void
    func collectionView(_ collectionView: UICollectionView, canDragAtIndexPath indexPath: IndexPath) -> Bool

    func collectionView(_ collectionView: UICollectionView, dragCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath,withDropInfo dropInfo:AnyObject?) -> Void
    func collectionViewStopDragging(_ collectionView: UICollectionView)->Void
    
    
    //drop
    func collectionView(_ collectionView: UICollectionView, canDropWithDragInfo info:AnyObject, AtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, dropOutsideWithDragInfo info:AnyObject) -> Void
    func collectionView(_ collectionView: UICollectionView, dropCompleteWithDragInfo dragInfo:AnyObject, atDragIndexPath dragIndexPath: IndexPath?,withDropInfo dropInfo:AnyObject?,atDropIndexPath dropIndexPath:IndexPath) -> Void
    func collectionViewStopDropping(_ collectionView: UICollectionView)->Void
    
}


@objc open class DragDropCollectionView: UICollectionView, Draggable, Droppable {


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)
    }
    
    fileprivate var draggingPathOfCellBeingDragged : IndexPath?
    
    fileprivate var iDataSource : UICollectionViewDataSource?
    fileprivate var iDelegate : UICollectionViewDelegate?
    
    open var dragDropDelegate:DragDropCollectionViewDelegate?
    
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
//        addObserver(self, forKeyPath: "contentSize", options: .old, context: nil)
    }
    
    deinit {
//        removeObserver(self, forKeyPath: "contentSize")
    }

    // MARK : Droppable
    func indexPathForCellOverlappingRect( _ rect : CGRect) -> IndexPath? {
        
        let centerPoint = CGPoint(x: rect.minX + rect.width/2, y: rect.minY + rect.height/2)
        
        
        for cell in visibleCells {
            
            if cell.frame.contains(centerPoint) {
                
                return self.indexPath(for: cell)
            }
            
        }

        return nil
    }
 
    var isHorizontal : Bool {
        return (self.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal
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
    var scrollDirection:UICollectionViewScrollDirection = .vertical
    fileprivate var dragRectCurrent:CGRect!
    
    fileprivate func startDisplayLink() {
        guard displayLink == nil else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(DragDropCollectionView.handlerDisplayLinkToContinuousScroll))
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
        
        if isHorizontal {
            
            let leftBoundary = CGRect(x: -30.0, y: 0.0, width: 30.0, height: self.frame.size.height)
            let rightBoundary = CGRect(x: self.frame.size.width, y: 0.0, width: 30.0, height: self.frame.size.height)
            
            if dragRectCurrent.intersects(leftBoundary) == true {
                rectForNextScroll.origin.x -= self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x < 0 {
                    rectForNextScroll.origin.x = 0
                }
            }
            else if dragRectCurrent.intersects(rightBoundary) == true {
                rectForNextScroll.origin.x += self.bounds.size.width * 0.5
                if rectForNextScroll.origin.x > self.contentSize.width - self.bounds.size.width {
                    rectForNextScroll.origin.x = self.contentSize.width - self.bounds.size.width
                }
            }
            
        } else { // is vertical
//            debugPrint("drag view rect: \(dragRectCurrent) ———— super view rect\(currentRect)")
            let topBoundary = CGRect(x: 0.0, y: -30.0, width: self.frame.size.width, height: 30.0)
            let bottomBoundary = CGRect(x: 0.0, y: self.frame.size.height, width: self.frame.size.width, height: 30.0)
            
            
            if dragRectCurrent.intersects(topBoundary) == true {
                rectForNextScroll.origin.y -= 5
                if rectForNextScroll.origin.y < 0 {
                    rectForNextScroll.origin.y = 0
                }
            }
            else if dragRectCurrent.intersects(bottomBoundary) == true {
//                debugPrint("move in bottomboundary : \(dragRectCurrent)")
                rectForNextScroll.origin.y += 5
                if rectForNextScroll.origin.y > self.contentSize.height - self.bounds.size.height {
                    rectForNextScroll.origin.y = self.contentSize.height - self.bounds.size.height
                }
            }
        }
        
        if currentRect.equalTo(rectForNextScroll) == false {
            
            scrollRectToVisible(rectForNextScroll, animated: false)

        }
    }

}

//MARK: - Dragable
extension DragDropCollectionView{
    open func canDragAtPoint(_ point : CGPoint) -> Bool {
        
        guard self.dragDropDelegate != nil else {
            return false
        }
        
        if let indexPath = self.indexPathForItem(at: point) {
            
            return dragDropDelegate!.collectionView(self, canDragAtIndexPath: indexPath)
            
        }
        
        return self.indexPathForItem(at: point) != nil
    }
    
    
    open func representationImageAtPoint(_ point : CGPoint) -> UIView? {
        
        var imageView : UIView?
        
        if let indexPath = self.indexPathForItem(at: point) {
            
            if dragDropDelegate != nil && dragDropDelegate!.responds(to: #selector(DragDropCollectionViewDelegate.collectionView(_:representationImageAtIndexPath:))){
                
                if let cell = self.cellForItem(at: indexPath) {
                    let img = dragDropDelegate!.collectionView!(self, representationImageAtIndexPath: indexPath)
                    
                    imageView = UIImageView(image: img)
                    imageView?.frame = cell.frame
                }
                
                
            }else{
                if let cell = self.cellForItem(at: indexPath) {
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
        
        if let indexPath = self.indexPathForItem(at: point) {
            
            if dragDropDelegate != nil {
                
                dataItem = dragDropDelegate!.collectionView(self, dragInfoForIndexPath: indexPath)
                
            }
            
        }
        return dataItem
    }
    
    
    
    open func touchBeginAtPoint(_ point : CGPoint) -> Void {
        
        self.draggingPathOfCellBeingDragged = self.indexPathForItem(at: point)
        
        if dragDropDelegate != nil {
            
            dragDropDelegate!.collectionView(self, touchBeginAtIndexPath: self.draggingPathOfCellBeingDragged!)
            
        }
        
        
    }
    
    
    
    open func stopDragging() -> Void {
        invalidateDisplayLink()
        
        if let idx = self.draggingPathOfCellBeingDragged {
            if let cell = self.cellForItem(at: idx) {
                cell.isHidden = false
            }
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        if dragDropDelegate != nil {
            dragDropDelegate!.collectionViewStopDragging(self)
            
        }
        
        
    }

    open func dragComplete(_ dragInfo:AnyObject,dropInfo : AnyObject?) -> Void {
        
        if dragDropDelegate != nil {
            
            if let dragIndexPath = draggingPathOfCellBeingDragged {
                
                dragDropDelegate!.collectionView(self, dragCompleteWithDragInfo: dragInfo,atDragIndexPath: dragIndexPath,withDropInfo: dropInfo)
                
                
            }
            
        }
        
    }
    
}


//MARK: - Droppable
extension DragDropCollectionView{
    
    open func canDropWithDragInfo(_ item: AnyObject,  inRect rect: CGRect) -> Bool {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.collectionView(self, canDropWithDragInfo: item, AtIndexPath: indexPath)
                
            }
        }
        
        return false
    }
    
    open func dropOverInfoInRect(_ rect: CGRect) -> AnyObject? {
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            if dragDropDelegate != nil {
                
                return dragDropDelegate!.collectionView(self, dragInfoForIndexPath: indexPath)
                
            }
        }
        return nil
    }
    open func dropOutside(_ dragInfo: AnyObject, inRect rect: CGRect) {
        if dragDropDelegate != nil && dragDropDelegate!.responds(to: #selector(DragDropCollectionViewDelegate.collectionView(_:dropOutsideWithDragInfo:))){
            dragDropDelegate!.collectionView!(self, dropOutsideWithDragInfo: dragInfo)
        }
    }
    
    open func stopDropping() {
        if dragDropDelegate != nil {
            
            dragDropDelegate!.collectionViewStopDropping(self)
            
        }
    }
    
    open func dropComplete(_ dragInfo : AnyObject,dropInfo:AnyObject?, atRect rect: CGRect) -> Void{
        
        if let dropIndexPath = self.indexPathForCellOverlappingRect(rect) {
            if  let dragIndexPath = draggingPathOfCellBeingDragged{
                if dragDropDelegate != nil {
                    dragDropDelegate!.collectionView(self, dropCompleteWithDragInfo: dragInfo, atDragIndexPath: dragIndexPath, withDropInfo: dropInfo, atDropIndexPath: dropIndexPath)
                    
                }
                
            }else{
                if dragDropDelegate != nil {
                    dragDropDelegate!.collectionView(self, dropCompleteWithDragInfo: dragInfo, atDragIndexPath: nil, withDropInfo: dropInfo, atDropIndexPath: dropIndexPath)
                    
                }
            }
            
        }
        
        self.draggingPathOfCellBeingDragged = nil
        
        self.reloadData()
        
    }
    
    
//    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath != nil && keyPath! == "contentSize" {
//            print("observe")
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: DragDropManager.NOTIFICATION_CANCEL_DRAGGING), object: nil)
//        }
//    }

}
