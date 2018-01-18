//
//  DragDropiOS.swift
//  DragDropiOS
//
//  Created by kai zhou on 18/01/2018.
//  Copyright © 2018 kai zhou. All rights reserved.
//

import Foundation

public func cancelDragging(){
    NotificationCenter.default.post(name:NSNotification.Name(rawValue: DragDropiOS_Noti_Cancel_Dragging) , object: nil)
}

