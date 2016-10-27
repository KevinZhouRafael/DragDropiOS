//
//  CollectionViewCell.swift
//  UICollectionViewFreezeLayout
//
//  Created by rafael on 7/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    static let IDENTIFIER = "COLLECTION_VIEW_CELL"
    
    @IBOutlet weak var contentLabel:UILabel!
    
    var model:Model!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.whiteColor()
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 0.5
    }
    
    
    func updateData(model:Model){
        self.model = model
        if model.text != nil {
            selectedStatus()
            contentLabel.text = model.text!
        }else{
            nomoralStatus()
            
            contentLabel.text = ""
        }
    }
    
    func hasContent() -> Bool {
        return model.text != nil
    }
    
    func moveOverStatus(){
        backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
    }
    
    func nomoralStatus(){
        backgroundColor = UIColor.whiteColor()
    }
    
    func selectedStatus(){
        backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
    }
    

}
