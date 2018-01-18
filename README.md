# DragDropiOS


[![Version](https://img.shields.io/cocoapods/v/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/ActiveSQLite)
[![License](https://img.shields.io/cocoapods/l/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)
[![Platform](https://img.shields.io/cocoapods/p/DragDropiOS.svg?style=flat)](http://cocoapods.org/pods/DragDropiOS)

DragDropiOS is a drag and drop manager on iOS. 
It supports drag and drop with in one or more classes extends UIView.
This library contains  UICollectionView and UITableView that implenment of drag and drop manager.



## Example

The example shows a drag and drop demo betweens UICollectionView, UITableView and UIView.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![Simple image](https://raw.githubusercontent.com/KevinZhouRafael/DragDropiOS/master/dragdropdemo.gif)


## Requirements

- iOS 8.0+  
- Xcode 7.3
- Swift 4.0

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
github "KevinZhouRafael/DragDropiOS"
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
    func dropComplete(_ dragInfo : AnyObject,dropInfo:AnyObject?, atRect : CGRect) -> Void
    @objc optional func checkFroEdgesAndScroll(_ item : AnyObject, inRect rect : CGRect) -> Void
    @objc optional func stopDropping() -> Void
}
```
### DragDropTableView and DragDropTableViewDelegate

```swift
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

### Useage
- Just let the view implement the Dragable Interface, the view can drag from.
If the view implement the Dropable Interface, the view can drop in.

- If you want drag or drop cells with UITableView. please create child class of DragDropTableView, and implenment DragDropTableViewDelegate delegate.

- If you want drag or drop cells with UICollectionView, please create child class of DragDropCollectionView, and implenment DragDropCollectionViewDelegate delegate.

- Before tableView or collectionView reloadData. you should cancel dragging process, please use DragDropiOS.cancelDragging(). The example support reloaddata every 5s, please use startTimer() method in Example.



## Author

Rafael Zhou

- Email me: <wumingapie@gmail.com>
- Follow me on **Twitter**: [**@wumingapie**](https://twitter.com/wumingapie)
- Contact me on **Facebook**: [**wumingapie**](https://www.facebook.com/wumingapie)
- Contact me on **LinkedIn**: [**Rafael**](https://www.linkedin.com/in/rafael-zhou-7230943a/)


## License

DragDropiOS is available under the MIT license. See the LICENSE file for more info.
