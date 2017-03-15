# DragDropiOS


[![Version](https://img.shields.io/cocoapods/v/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![License](https://img.shields.io/cocoapods/l/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![Platform](https://img.shields.io/cocoapods/p/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)

DragDropiOS is a drag and drop manager on iOS. 
It supports drag and drop with in one or more classes extends UIView.
This library contains a UICollectionView implenment of drag and drop manager.



## Example

The example shows a drag and drop demo between UICollectionView and UIViews.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![Simple image](https://raw.githubusercontent.com/KevinChouRafael/DragDropiOS/master/dragdropdemo.gif)


## Requirements

- iOS 8.0+  
- Xcode 7.3
- Swift 3.0

## Installation

### Cocoapods

DragDropiOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DragDropiOS"
```
### Carthage

If you're using [Carthage](https://github.com/Carthage/Carthage), you can add a dependency on DragDropiOS by adding it to your Cartfile:

```ruby
github "KevinChouRafael/DragDropiOS"
```


## Introduce

### Draggable

```swift
@objc public protocol Draggable:NSObjectProtocol {
    @objc optional func touchBeginAtPoint(_ point : CGPoint) -> Void
    
    func canDragAtPoint(_ point : CGPoint) -> Bool
    func representationImageAtPoint(_ point : CGPoint) -> UIView?
    func dragInfoAtPoint(_ point : CGPoint) -> AnyObject?
    func dragComplete(_ dragInfo:AnyObject,dropInfo : AnyObject?) -> Void
    
    @objc optional func stopDragging() -> Void
}
```

### Dropable

```swift
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
```

### DragDropCollectionView and DragDropCollectionViewDelegate
```swift
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
```

## Author

Rafael Zhou, wumingapie@gmail.com

## License

DragDropiOS is available under the MIT license. See the LICENSE file for more info.
