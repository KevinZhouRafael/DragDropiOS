# DragDropiOS

[![CI Status](http://img.shields.io/travis/rafael zhou/DragDropiOS.svg?style=flat)](https://travis-ci.org/rafael zhou/DragDropiOS)
[![Version](https://img.shields.io/cocoapods/v/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![License](https://img.shields.io/cocoapods/l/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![Platform](https://img.shields.io/cocoapods/p/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)

DragDropiOS is a drag and drop manager on iOS. 
It supports drag and drop with in one or more classes extends UIView.
This library contains a UICollectionView implenment of drag and drop manager.



## Example

The example shows a drag and drop demo in one collectionView.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+  
- Xcode 7.3
- Swift 2.2

## Installation

DragDropiOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DragDropiOS"
```
## Introduce

### Draggable

```swift
@objc public protocol Draggable:NSObjectProtocol {
    optional func touchBeginAtPoint(point : CGPoint) -> Void
    
    func canDragAtPoint(point : CGPoint) -> Bool
    func representationImageAtPoint(point : CGPoint) -> UIView?
    func dragInfoAtPoint(point : CGPoint) -> AnyObject?
    func dragComplete(dragInfo:AnyObject,dropInfo : AnyObject) -> Void
    
    optional func stopDragging() -> Void
}
```

### Dropable

```swift
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
}
```

### DragDropCollectionView and DragDropCollectionViewDelegate
```swift
@objc public protocol DragDropCollectionViewDelegate : NSObjectProtocol {
    
    optional func collectionView(collectionView: UICollectionView, indexPathForDragInfo dragInfo: AnyObject) -> NSIndexPath?
    func collectionView(collectionView: UICollectionView, dragInfoForIndexPath indexPath: NSIndexPath) -> AnyObject
    optional func collectionView(collectionView: UICollectionView, representationImageAtIndexPath indexPath: NSIndexPath) -> UIImage
    
    
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
```

## Author

rafael zhou, wumingapie@gmail.com

## License

DragDropiOS is available under the MIT license. See the LICENSE file for more info.
