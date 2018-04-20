//
//  DragDropManager.swift
//  DragDropManager.swift
//
//  Created by Rafael on 10/24/2016.
//  modified by rafael
//  Copyright (c) 2016 Rafael. All rights reserved.
//

import UIKit

@objc public protocol Draggable:NSObjectProtocol {
    @objc optional func touchBeginAtPoint(_ point : CGPoint) -> Void
    
    func canDragAtPoint(_ point : CGPoint) -> Bool
    func representationImageAtPoint(_ point : CGPoint) -> UIView?
    func dragInfoAtPoint(_ point : CGPoint) -> AnyObject?
    func dragComplete(_ dragInfo:AnyObject,dropInfo : AnyObject?) -> Void
    
    @objc optional func stopDragging() -> Void
}


@objc public protocol Droppable:NSObjectProtocol {
    func canDropWithDragInfo(_ dragInfo:AnyObject, inRect rect : CGRect) -> Bool
    func dropOverInfoInRect(_ rect:CGRect) -> AnyObject?
    @objc optional func dropOutside(_ dragInfo:AnyObject, inRect rect:CGRect)->Void
    
    @objc optional func willMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void
    @objc optional func didMoveItem(_ item : AnyObject, inRect rect : CGRect) -> Void
    @objc optional func didMoveOutItem(_ item : AnyObject) -> Void
    
    func dropComplete(_ dragInfo : AnyObject,dropInfo:AnyObject?, atRect : CGRect) -> Void
    
    @objc optional func checkFroEdgesAndScroll(_ item : AnyObject, inRect rect : CGRect) -> Void
    
    @objc optional func stopDropping() -> Void
}


let DragDropiOS_Noti_Cancel_Dragging = "NOTIFICATION_CANCEL_DRAGGING"
open class DragDropManager:NSObject,UIGestureRecognizerDelegate {
    
    var canvas : UIView = UIView()
    var views : [UIView] = []
    var longPressGestureRecogniser = UILongPressGestureRecognizer()
    

    
    struct Bundle {
        var offset : CGPoint = CGPoint.zero
        var sourceDraggableView : UIView
        var overDroppableView : UIView?
        var representationImageView : UIView
        var dragInfo : AnyObject
        var dropInfo : AnyObject?
    }
    var bundle : Bundle?
    
    func isDragging() -> Bool{
        return bundle != nil
    }
    
    public init(canvas : UIView, views : [UIView]) {
        
        super.init()
        
        self.canvas = canvas
        
        self.longPressGestureRecogniser.delegate = self
        self.longPressGestureRecogniser.minimumPressDuration = 0.3
        self.longPressGestureRecogniser.addTarget(self, action: #selector(DragDropManager.updateForLongPress(_:)))
        
        self.canvas.addGestureRecognizer(self.longPressGestureRecogniser)
        self.views = views
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelDragHandler), name: NSNotification.Name(rawValue: DragDropiOS_Noti_Cancel_Dragging), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard isDragging() == false else {
            return false
        }
        
        for view in self.views.filter({ v -> Bool in v is Draggable})  {
            
            debugPrint("view：%@, ",view)
            
            let draggable = view as! Draggable
                
            let touchPointInView = touch.location(in: view)
            
            if view.bounds.contains(touchPointInView) {
                if draggable.canDragAtPoint(touchPointInView) == true {
                    
                    if let representation = draggable.representationImageAtPoint(touchPointInView) {
                        
                        representation.frame = self.canvas.convert(representation.frame, from: view)
                        
                        representation.alpha = 0.7
                        
                        let pointOnCanvas = touch.location(in: self.canvas)
                        
                        let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x, y: pointOnCanvas.y - representation.frame.origin.y)
                        
                        
                        if let dataItem : AnyObject = draggable.dragInfoAtPoint(touchPointInView) {
                            
                            self.bundle = Bundle(
                                offset: offset,
                                sourceDraggableView: view,
                                overDroppableView : view is Droppable ? view : nil,
                                representationImageView: representation,
                                dragInfo : dataItem,
                                dropInfo : nil
                            )
                            
                            return true
                            
                        } // if let dataIte...
                        
                        
                    } // if let representation = dragg...
                    
                    
                } // if draggable.canDragAtP...
            }// end if contains
 
        } // for view in self.views.fil...
        
        return false
        
    }
    
    
    
    
    @objc open func updateForLongPress(_ recognizer : UILongPressGestureRecognizer) -> Void {
        
        if var bundle = self.bundle {
            
            let pointOnCanvas = recognizer.location(in: recognizer.view)
            let sourceDraggable : Draggable = bundle.sourceDraggableView as! Draggable
            let pointOnSourceDraggable = recognizer.location(in: bundle.sourceDraggableView)
            
            switch recognizer.state {
                
                
            case .began :
                self.canvas.addSubview(bundle.representationImageView)
                sourceDraggable.touchBeginAtPoint?(pointOnSourceDraggable)
                
            case .changed :
                
                // Update the frame of the representation image
                
                var repImgFrame = bundle.representationImageView.frame
                repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundle.offset.x, y: pointOnCanvas.y - bundle.offset.y);
                bundle.representationImageView.frame = repImgFrame
                
                var overlappingArea : CGFloat = 0.0
                
                var currentOverView : UIView?
                
                for view in self.views.filter({ v -> Bool in v is Droppable }) {
                 
                    let viewFrameOnCanvas = self.convertRectToCanvas(view.frame, fromView: view)
                    
                    
                    let intersectionNew = bundle.representationImageView.frame.intersection(viewFrameOnCanvas).size
                    
                    
                    if (intersectionNew.width * intersectionNew.height) > overlappingArea {
                        
                        overlappingArea = intersectionNew.width * intersectionNew.width
                        
                        currentOverView = view
                    }
                    
                }
                if currentOverView == nil {
                    currentOverView = recognizer.view
                }
                
                
                
                if let droppable = currentOverView as? Droppable {
                    
                    let rect = self.canvas.convert(bundle.representationImageView.frame, to: currentOverView)
                    
                    if droppable.canDropWithDragInfo(bundle.dragInfo, inRect: rect) {
                        
//                        debugPrint("can drop \(rect)")
                        bundle.dropInfo = droppable.dropOverInfoInRect(rect)
                        
                        //currentOverView -> new over View
                        // bundle.overDroppableView -> old over View
                        if currentOverView != bundle.overDroppableView { // if it is the first time we are entering
                            
                            if bundle.overDroppableView != nil{
                                
                                if let overDropableView = bundle.overDroppableView as? Droppable {
                                    
                                    if overDropableView.responds(to: #selector(Droppable.didMoveOutItem(_:)))
                                    {
                                        
                                        overDropableView.didMoveOutItem!(bundle.dragInfo)
                                    }
                                    
                                    if droppable.responds(to: #selector(Droppable.willMoveItem(_:inRect:))){
                                        
                                        droppable.willMoveItem!(bundle.dragInfo, inRect: rect)
                                    }
                                    
                                    
                                    if overDropableView.responds(to: #selector(Droppable.dropOutside(_:inRect:))){
                                        overDropableView.dropOutside!(bundle.dragInfo, inRect: rect)
                                    }
                                }
                            }
                            
                        }
                        
                        // set the view the dragged element is over
                        self.bundle!.overDroppableView = currentOverView
                        
                        if droppable.responds(to: #selector(Droppable.didMoveItem(_:inRect:))) {
                            
                            droppable.didMoveItem!(bundle.dragInfo, inRect: rect)
                        }
                        
                        
                        // can't drop with drag into
                    }else{
                        self.bundle!.overDroppableView = currentOverView
                        
                        //currentOverView -> new over View
                        // bundle.overDroppableView -> old over View
                        
                        if currentOverView != bundle.overDroppableView { // drag into other view
                            
                            if bundle.overDroppableView != nil{
                                if let overDropableView = bundle.overDroppableView as? Droppable {
                                    
                                    if overDropableView.responds(to: #selector(Droppable.dropOutside(_:inRect:))){
                                        overDropableView.dropOutside!(bundle.dragInfo, inRect: rect)
                                    }
                                }
                            }
                        }
                        
                        self.bundle!.overDroppableView = currentOverView

                    }
                    
                    
                    
                    //checkForEdgesAndScroll when every recognizer changed
                    if let dropAble = bundle.overDroppableView as? Droppable {
                        if dropAble.responds(to: #selector(Droppable.checkFroEdgesAndScroll(_:inRect:))) {
                            dropAble.checkFroEdgesAndScroll!(bundle.dragInfo, inRect: rect)
                        }
                    }
                    
                }
                
               
            case .ended :
                
//                if bundle.sourceDraggableView != bundle.overDroppableView { // if we are actually dropping over a new view.
                
                print("\(String(describing: bundle.overDroppableView?.tag))")
                    
                    if let droppable = bundle.overDroppableView as? Droppable {
                        
                        let rect = self.canvas.convert(bundle.representationImageView.frame, to: bundle.overDroppableView)
                        
                        
                        if droppable.canDropWithDragInfo(bundle.dragInfo, inRect: rect) {
                            
                            bundle.dropInfo = droppable.dropOverInfoInRect(rect)
                            
                            sourceDraggable.dragComplete(bundle.dragInfo,dropInfo: bundle.dropInfo)
                            droppable.dropComplete(bundle.dragInfo,dropInfo: bundle.dragInfo, atRect: rect)
                            
                            sourceDraggable.stopDragging?()
                            droppable.stopDropping?()
                            
                        }else{
                         
                        }
                        
                    }
//                }
                
                
                bundle.representationImageView.removeFromSuperview()
                self.bundle = nil
                sourceDraggable.stopDragging?()
                
            default:
                break
                
            }
            
            
        } // if let bundle = self.bundle ...
        
        
    }
 
 
    
    // MARK: Helper Methods 
    func convertRectToCanvas(_ rect : CGRect, fromView view : UIView) -> CGRect {
        
        var r : CGRect = rect
        
        var v = view
        
        while v != self.canvas {
            
            if let sv = v.superview {
                
                r.origin.x += sv.frame.origin.x
                r.origin.y += sv.frame.origin.y
                
                v = sv
                
                continue
            }
            break
        }
        
        return r
    }
   
    @objc private func cancelDragHandler() {
        cancelDragProcess()
    }
    private func cancelDragProcess(){
        if let bundle = self.bundle {
            bundle.representationImageView.removeFromSuperview()
            
            if let dragable = bundle.sourceDraggableView as? Draggable {
                dragable.stopDragging?()
            }
            
            if let droppable = bundle.overDroppableView as? Droppable {
                droppable.stopDropping?()
            }

            self.bundle = nil
        }
       
    }
}
 
