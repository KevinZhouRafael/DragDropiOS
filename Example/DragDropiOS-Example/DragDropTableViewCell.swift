//
//  DragDropTableViewCell.swift
//  DragDropiOS-Example
//
//  Created by yuhan on 01/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import UIKit

class DragDropTableViewCell: UITableViewCell {

    static let IDENTIFIER = "DRAG_DROP_TABLE_VIEW_CELL"
    
    @IBOutlet weak var contentImageView:UIImageView!
    @IBOutlet weak var contentLabel:UILabel!
    
    var model:Model!
    
    override func awakeFromNib() {
        backgroundColor = UIColor.white
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        
        self.selectionStyle = .none
    }

    
    func updateData(_ model:Model){
        self.model = model
        if model.fruit != nil {
            selectedStatus()
            contentImageView.image = UIImage(named: model.fruit!.imageName!)
            contentLabel.text = model.fruit!.name!
        }else{
            nomoralStatus()
            
            contentImageView.image = nil
            contentLabel.text = nil
        }
    }
    
    func hasContent() -> Bool {
        return model.fruit != nil
    }
    
    func moveOverStatus(){
        backgroundColor = UIColor.orange.withAlphaComponent(0.5)
    }
    
    func nomoralStatus(){
        backgroundColor = UIColor.white
    }
    
    func selectedStatus(){
        backgroundColor = UIColor.blue.withAlphaComponent(0.5)
    }

    
}
