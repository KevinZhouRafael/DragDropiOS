//
//  Model.swift
//  DragDropiOS
//
//  Created by kai zhou on 08/02/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
class Model {
    var collectionIndex:Int? //not use now
    var tableIndex:Int? //not use now
    var fruit:Fruit?
}


class Fruit {
    var id:Int!
    var name:String?
    var imageName:String?
    init(id:Int,name:String,imageName:String) {
        self.id = id
        self.name = name
        self.imageName = imageName
    }
}
