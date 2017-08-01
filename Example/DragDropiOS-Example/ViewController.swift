//
//  ViewController.swift
//  DragDropiOS
//
//  Created by rafael zhou on 10/25/2016.
//  Copyright (c) 2016 rafael zhou. All rights reserved.
//

import UIKit
import DragDropiOS


class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,DragDropCollectionViewDelegate,
                        UITableViewDelegate,UITableViewDataSource, DragDropTableViewDelegate {
    
    var models:[Model] = [Model]()
    var tableModels:[Model] = [Model]()
    
    var dragDropManager:DragDropManager!
    
    @IBOutlet weak var dragDropCollectionView:DragDropCollectionView!
    @IBOutlet weak var dragDropTableView:DragDropTableView!
    @IBOutlet weak var dragDropView:DragDropView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        for i in 0 ..< 15 {
            let model = Model()
            model.collectionIndex = i
            if i == 0 {
                let fruit = Fruit(id: 1, name: "Avocado",imageName:"Avocado")
                model.fruit = fruit
            }
            if i == 1 {
                let fruit = Fruit(id: 2, name: "Durian",imageName:"Durian")
                model.fruit = fruit
            }
            if i == 2{
                let fruit = Fruit(id: 3, name: "Mangosteen",imageName:"Mangosteen")
                model.fruit = fruit
            }

            models.append(model)
        }
        
        
        for j in 0 ..< 8{
            let m = Model()
            m.tableIndex = j
            tableModels.append(m)
        }
        
        dragDropCollectionView.backgroundColor = UIColor.white
        dragDropCollectionView.bounces = false
        dragDropCollectionView.dragDropDelegate = self
        
        
        dragDropTableView.dragDropDelegate = self
        dragDropManager = DragDropManager(canvas: self.view, views: [dragDropView,dragDropCollectionView,dragDropTableView])
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DragDropCollectionViewCell.IDENTIFIER, for: indexPath) as! DragDropCollectionViewCell
        
        cell.updateData(model)
        
        return cell
    }
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: DragDropTableViewCell.IDENTIFIER, for: indexPath) as! DragDropTableViewCell
        cell.updateData(model)
        return cell
        
    }

}
