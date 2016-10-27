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
    optional func touchBeginAtPoint(point : CGPoint) -> Void
    
    func canDragAtPoint(point : CGPoint) -> Bool
    func representationImageAtPoint(point : CGPoint) -> UIView?
    func dragInfoAtPoint(point : CGPoint) -> AnyObject?
    func dragComplete(dragInfo:AnyObject,dropInfo : AnyObject) -> Void
    
    optional func stopDragging() -> Void
}


@objc public protocol Droppable:NSObjectProtocol {
    func canDropWithDragInfo(dragInfo:AnyObject, inRect rect : CGRect) -> Bool
    
    optional func willMoveItem(item : AnyObject, inRect rect : CGRect) -> Void
    optional func didMoveItem(item : AnyObject, inRect rect : CGRect) -> Void
    optional func didMoveOutItem(item : AnyObject) -> Void
    
    func dropComplete(dragInfo : AnyObject,dropInfo:AnyObject, atRect : CGRect) -> Void
    
    func dropOverInfoInRect(rect:CGRect) -> AnyObject?
    func checkFroEdgesAndScroll(item : AnyObject, inRect rect : CGRect) -> Void
    
    optional func stopDropping() -> Void
}


public class DragDropManager:NSObject,UIGestureRecognizerDelegate {
    
     var canvas : UIView = UIView()
     var views : [UIView] = []
     var longPressGestureRecogniser = UILongPressGestureRecognizer()
    
    
    struct Bundle {
        var offset : CGPoint = CGPointZero
        var sourceDraggableView : UIView
        var overDroppableView : UIView?
        var representationImageView : UIView
        var dragInfo : AnyObject
        var dropInfo : AnyObject?
    }
    var bundle : Bundle?
    
    
    public init(canvas : UIView, collectionViews : [UIView]) {
        
        super.init()
        
        self.canvas = canvas
        
        self.longPressGestureRecogniser.delegate = self
        self.longPressGestureRecogniser.minimumPressDuration = 0.3
        self.longPressGestureRecogniser.addTarget(self, action: #selector(DragDropManager.updateForLongPress(_:)))
        
        self.canvas.addGestureRecognizer(self.longPressGestureRecogniser)
        self.views = collectionViews
    }
    
     public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        for view in self.views.filter({ v -> Bool in v is Draggable})  {
            
                let draggable = view as! Draggable
                
                let touchPointInView = touch.locationInView(view)
                
                if draggable.canDragAtPoint(touchPointInView) == true {
                    
                    if let representation = draggable.representationImageAtPoint(touchPointInView) {
                        
                        representation.frame = self.canvas.convertRect(representation.frame, fromView: view)
                        
                        representation.alpha = 0.7
                        
                        let pointOnCanvas = touch.locationInView(self.canvas)
                        
                        let offset = CGPointMake(pointOnCanvas.x - representation.frame.origin.x, pointOnCanvas.y - representation.frame.origin.y)
                        
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
            
        } // for view in self.views.fil...
        
        return false
        
    }
    
    
    
    
     public func updateForLongPress(recognizer : UILongPressGestureRecognizer) -> Void {
        
        if var bundle = self.bundle {
            
            let pointOnCanvas = recognizer.locationInView(recognizer.view)
            let sourceDraggable : Draggable = bundle.sourceDraggableView as! Draggable
            let pointOnSourceDraggable = recognizer.locationInView(bundle.sourceDraggableView)
            
            switch recognizer.state {
                
                
            case .Began :
                self.canvas.addSubview(bundle.representationImageView)
                sourceDraggable.touchBeginAtPoint?(pointOnSourceDraggable)
                
            case .Changed :
                
                // Update the frame of the representation image
                var repImgFrame = bundle.representationImageView.frame
                repImgFrame.origin = CGPointMake(pointOnCanvas.x - bundle.offset.x, pointOnCanvas.y - bundle.offset.y);
                bundle.representationImageView.frame = repImgFrame
                
                var overlappingArea : CGFloat = 0.0
                
                var mainOverView : UIView?
                
                for view in self.views.filter({ v -> Bool in v is Droppable }) {
                 
                    let viewFrameOnCanvas = self.convertRectToCanvas(view.frame, fromView: view)
                    
                    
                    let intersectionNew = CGRectIntersection(bundle.representationImageView.frame, viewFrameOnCanvas).size
                    
                    
                    if (intersectionNew.width * intersectionNew.height) > overlappingArea {
                        
                        overlappingArea = intersectionNew.width * intersectionNew.width
                        
                        mainOverView = view
                    }

                    
                }
                
                
                
                if let droppable = mainOverView as? Droppable {
                    
                    let rect = self.canvas.convertRect(bundle.representationImageView.frame, toView: mainOverView)
                    
                    if droppable.canDropWithDragInfo(bundle.dragInfo, inRect: rect) {
                        
//                        debugPrint("can drop \(rect)")
                        bundle.dropInfo = droppable.dropOverInfoInRect(rect)
                        if mainOverView != bundle.overDroppableView { // if it is the first time we are entering
                            
                            if (bundle.overDroppableView as! Droppable).respondsToSelector(#selector(Droppable.didMoveOutItem(_:))) {
                                
                                (bundle.overDroppableView as! Droppable).didMoveOutItem!(bundle.dragInfo)
                            }
                            
                            if droppable.respondsToSelector(#selector(Droppable.willMoveItem(_:inRect:))){
                                
                                droppable.willMoveItem!(bundle.dragInfo, inRect: rect)
                            }
                            
                        }
                        
                        // set the view the dragged element is over
                        self.bundle!.overDroppableView = mainOverView
                        
                        if droppable.respondsToSelector(#selector(Droppable.didMoveItem(_:inRect:))) {
                            
                            droppable.didMoveItem!(bundle.dragInfo, inRect: rect)
                        }
                        
                        // can't drop with drag into
                    }else{
                        bundle.dropInfo = nil
                    }
                    
                    
                    //checkForEdgesAndScroll when every recognizer changed
                    (bundle.overDroppableView as! Droppable).checkFroEdgesAndScroll(bundle.dragInfo, inRect: rect)
                    
                }
                
               
            case .Ended :
                
//                if bundle.sourceDraggableView != bundle.overDroppableView { // if we are actually dropping over a new view.
                
                    print("\(bundle.overDroppableView?.tag)")
                    
                    if let droppable = bundle.overDroppableView as? Droppable {
                        
                        let rect = self.canvas.convertRect(bundle.representationImageView.frame, toView: bundle.overDroppableView)
                        
                        
                        if droppable.canDropWithDragInfo(bundle.dragInfo, inRect: rect) {
                            
                            bundle.dropInfo = droppable.dropOverInfoInRect(rect)
                            
                            sourceDraggable.dragComplete(bundle.dragInfo,dropInfo: bundle.dropInfo!)
                            droppable.dropComplete(bundle.dragInfo,dropInfo: bundle.dragInfo, atRect: rect)
                            
                            droppable.stopDropping?()
                            
                        }else{
                         
                        }
                        
                    }
//                }
                
                
                bundle.representationImageView.removeFromSuperview()
                sourceDraggable.stopDragging?()
                
            default:
                break
                
            }
            
            
        } // if let bundle = self.bundle ...
        
        
    }
 
 
    
    // MARK: Helper Methods 
    func convertRectToCanvas(rect : CGRect, fromView view : UIView) -> CGRect {
        
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
   
}
 
