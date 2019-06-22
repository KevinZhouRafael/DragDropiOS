//
//  ViewController.swift
//  DragDropiOS
//
//  Created by rafael zhou on 10/25/2016.
//  Copyright (c) 2016 rafael zhou. All rights reserved.
//

import UIKit
import DragDropiOS


class ViewController: UIViewController {
    var timer:Timer!
    
    var collectionModels:[Model] = [Model]()
    var tableModels:[Model] = [Model]()
    
    var dragDropManager:DragDropManager!
    
    @IBOutlet weak var dragDropCollectionView:DragDropCollectionView!
    @IBOutlet weak var dragDropTableView:DragDropTableView!
    @IBOutlet weak var dragDropView:DragDropView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildCollectionModels()
        
        buildTableViewModels()
        
        dragDropCollectionView.backgroundColor = UIColor.white
        dragDropCollectionView.bounces = false
        dragDropCollectionView.dragDropDelegate = self
        
        
        dragDropTableView.dragDropDelegate = self
        dragDropManager = DragDropManager(canvas: self.view, views: [dragDropView,dragDropCollectionView,dragDropTableView])
        
        //reloadCollection every 5 seconds.
//        startTimer()
    }
    
    
    func buildCollectionModels(){
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
            
            collectionModels.append(model)
        }
    }
    
    func buildTableViewModels() {
        for j in 0 ..< 8{
            let m = Model()
            m.tableIndex = j
            tableModels.append(m)
        }
    }
    
    func startTimer(){
        if timer == nil {
            timer = Timer(timeInterval: 5, target: self, selector: #selector(timerHandler(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    

    func createRandomMan(start: Int, end: Int) ->() ->Int? {
        
        var nums = [Int]();
        for i in start...end{
            nums.append(i)
        }
        
        func randomMan() -> Int? {
            if !nums.isEmpty {
                //                let index = Int(arc4random_uniform(UInt32(nums.count)))
                let index = Int.random(in: 0 ..< nums.count)
                return nums.remove(at: index)
            }
            else {
                return nil
            }
        }
        return randomMan
    }

    
    @objc func timerHandler(timer:Timer) {
        print("timer-> \(timer.isValid)")
        
        //1、Cancel dragging progressing
        DragDropiOS.cancelDragging()
        
        //2、Change models
        let randomGen = createRandomMan(start: 0, end: 15)
        
        var furits = [Fruit]()
        furits.append(Fruit(id: randomGen()!, name: "Avocado",imageName:"Avocado"))
        furits.append(Fruit(id: randomGen()!, name: "Durian",imageName:"Durian"))
        furits.append(Fruit(id: randomGen()!, name: "Mangosteen",imageName:"Mangosteen"))
       
        
        collectionModels.removeAll()
        for i in 0 ..< 15 {
            let model = Model()
            model.collectionIndex = i

            for j in 0 ..< 3 {
                if furits[j].id == i {
                    model.fruit = furits[j]
                }
            }
            collectionModels.append(model)
        }

        //3、Reload data
        dragDropCollectionView.reloadData()
    }

}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
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


extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = collectionModels[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DragDropCollectionViewCell.IDENTIFIER, for: indexPath) as! DragDropCollectionViewCell
        
        cell.updateData(model)
        
        return cell
    }
}
