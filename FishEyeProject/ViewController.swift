//
//  ViewController.swift
//  FishEyeProject
//
//  Created by Jason Fan on 2017/7/5.
//  Copyright © 2017年 zhiyuanFan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource {

    var _collectionView:  UICollectionView?
    var _layout: FishEyeCollectionViewLayout?
    var modelArray: [cellModel]?
    
    struct cellModel {
        var title: String?
        var isFinished: Bool?
    }
    
    
    func createFakeData() {
        self.modelArray = [cellModel]()
        for i in 0..<11 {
            var model = cellModel()
            model.title = "row num is \(i)"
            if i == 5 {
                model.isFinished = true
            } else {
                model.isFinished = false
            }
            self.modelArray?.append(model)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createFakeData()
        
        let cellSize = CGSize(width: 240, height: 100)
        _layout = FishEyeCollectionViewLayout(layoutRadius: 500, angularSpacing: 20, cellSize: cellSize, alignment: .center, cellHeight: 100, offsetX: 150)
        
        _collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: _layout!)
        _collectionView?.dataSource = self
        _collectionView?.delegate = self
        let nib = UINib(nibName: FishEyeCollectionViewCell.className, bundle: Bundle.main)
        _collectionView?.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1)
        _collectionView?.register(nib, forCellWithReuseIdentifier: FishEyeCollectionViewCell.className)
        self.view.addSubview(_collectionView!)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - COLLECTION VIEW DATA SOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.modelArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FishEyeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FishEyeCollectionViewCell.className, for: indexPath) as! FishEyeCollectionViewCell
        
        let model = self.modelArray?[indexPath.row]
        cell.titleLabel.text = model?.title
        if (model?.isFinished)! {
            cell.titleLabel.backgroundColor = UIColor(red: 113/255.0, green: 87/255.0, blue: 225/255.0, alpha: 1)
            cell.titleLabel.textColor = UIColor.white
        } else {
            cell.titleLabel.backgroundColor = UIColor.white
            cell.titleLabel.textColor = UIColor.black
        }

        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        //UIColor(red: 113/255.0, green: 87/255.0, blue: 225/255.0, alpha: 1)
        return cell
    }
    
    //MARK: - COLLECTION VIEW DELEGATE
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: FishEyeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FishEyeCollectionViewCell.className, for: indexPath) as! FishEyeCollectionViewCell
        print("selected row \(indexPath.row)")
    }
}


class FishEyeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    static let className: String = "FishEyeCollectionViewCell"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

