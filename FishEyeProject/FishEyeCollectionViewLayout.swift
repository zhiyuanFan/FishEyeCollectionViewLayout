//
//  FishEyeCollectionViewLayout.swift
//  FishEyeProject
//
//  Created by Jason Fan on 2017/7/5.
//  Copyright © 2017年 zhiyuanFan. All rights reserved.
//

import UIKit

enum LayoutAlignment: Int {
    case center = 0
    case left = 1
}

class FishEyeCollectionViewLayout: UICollectionViewFlowLayout {
    
    var cellSize: CGSize?
    var offset: CGFloat?
    var offsetX: CGFloat?
    var itemHeight: CGFloat?
    var angularSpacing: CGFloat?
    var layoutRadius: CGFloat?
    var selectedItem: Int?
    var cellCount: Int?
    var shouldSnap: Bool?
    var shouldFlip: Bool?
    var alignment: LayoutAlignment?
    
    //MARK: - init
    override init() {
        super.init()
        setup()
        self.shouldSnap = false
        self.shouldFlip = false
    }
    
    convenience init(layoutRadius: CGFloat ,
                     angularSpacing: CGFloat,
                     cellSize: CGSize,
                     alignment: LayoutAlignment,
                     cellHeight: CGFloat,
                     offsetX: CGFloat) {
        self.init()
        
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        self.cellSize = cellSize
        self.offsetX = offsetX
        self.layoutRadius = layoutRadius
        self.angularSpacing = angularSpacing
        self.itemHeight = cellHeight
        self.itemSize = cellSize
        self.cellSize = cellSize
        
        self.sectionInset = .zero
        self.scrollDirection = .vertical
        
        setup()
    }
    
    
    override func prepare() {
        super.prepare()
        self.cellCount = (self.collectionView?.numberOfSections)! > 0 ? self.collectionView?.numberOfItems(inSection: 0) : 0
        self.offset = -((self.collectionView?.contentOffset.y)!) / self.itemHeight!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FUNCTIONS
    func setup() {
        self.offset = 0
    }
    
    func getRectForItem(itemIndex: Int) -> CGRect {
        let newIndex = CGFloat(itemIndex)+self.offset!
        let scaleFactor = fmax(0.6, 1 - fabs(newIndex*0.25))
        let deltaX = (self.cellSize?.width)! / 2
        var rX = cosf(Float(self.angularSpacing! * newIndex * .pi/180)) * Float(self.layoutRadius! + (deltaX*scaleFactor))
        let rY = sinf(Float(self.angularSpacing! * newIndex * .pi/180)) * Float(self.layoutRadius! + (deltaX*scaleFactor))
        var oX = self.offsetX! - (self.layoutRadius! + (0.5 * (self.cellSize?.width)!));
        let oY = (self.collectionView?.bounds.size.height)!/2 + (self.collectionView?.contentOffset.y)! - (0.5 * (self.cellSize?.height)!)
        
        
        if self.shouldFlip! {
            oX = (self.collectionView?.frame.size.width)! + self.layoutRadius! - self.offsetX! - (0.5 * (self.cellSize?.width)!)
            rX *= -1
        }
        
        let itemFrame = CGRect(x: oX + CGFloat(rX), y: oY + CGFloat(rY), width: (self.cellSize?.width)!, height: (self.cellSize?.height)!)
        
        return itemFrame
    }
    
    
    //MARK: - SYSTEM FUNCTIONS MUST COMPLEMENT
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (self.collectionView?.bounds.size.width)!, height: CGFloat(self.cellCount! - 1) * self.itemHeight! + (self.collectionView?.bounds.size.height)!)
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        let maxVisibleHalf = Int(180 / self.angularSpacing!)
        for i in 0..<self.cellCount! {
            let itemFrame = getRectForItem(itemIndex: i)
            if rect.intersects(itemFrame) , i > Int(-1*self.offset!) - maxVisibleHalf, i < Int(-1*self.offset!) + maxVisibleHalf {
                let indexPath = IndexPath(item: i, section: 0)
                let attributes = layoutAttributesForItem(at: indexPath)
                attributesArray.append(attributes!)
            }
        }
        return attributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let newIndex = CGFloat(indexPath.item) + self.offset!
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.size = self.cellSize!
        var scaleFactor: CGFloat
        var deltaX: CGFloat
        var translationT: CGAffineTransform
        var rotationT = CGAffineTransform(rotationAngle: (self.angularSpacing)! * newIndex * .pi/180)
        if self.shouldFlip! {
            rotationT = CGAffineTransform(rotationAngle: -(self.angularSpacing)! * newIndex * .pi/180);
        }
        
        let minRange = -(self.angularSpacing)! / 2.0;
        let maxRange = (self.angularSpacing)! / 2.0;
        let currentAngle = (self.angularSpacing)! * newIndex;
        
        if (currentAngle > minRange) , (currentAngle < maxRange) {
            self.selectedItem = indexPath.item
        }
        
        if self.alignment == .left {
            
            scaleFactor = fmax(0.6, 1 - fabs( newIndex * 0.25))
            let newFrame = getRectForItem(itemIndex: indexPath.item)
            attributes.frame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y, width: newFrame.size.width, height: newFrame.size.height)
            translationT = CGAffineTransform(translationX: 0, y: 0)
        }else  {
            scaleFactor = fmax(0.4, 1 - fabs( newIndex * 0.50));
            deltaX = (self.collectionView?.bounds.size.width)!/2;
            
            if self.shouldFlip! {
                attributes.center = CGPoint(x: (self.collectionView?.frame.size.width)! + self.layoutRadius! - self.offsetX!, y: (self.collectionView?.bounds.size.height)!/2 + (self.collectionView?.contentOffset.y)!)
                translationT = CGAffineTransform(translationX:  -1 * (self.layoutRadius!  + ((1 - scaleFactor) * -30)), y: 0)
            }else{
                attributes.center = CGPoint(x: -(self.layoutRadius)! + self.offsetX!, y: (self.collectionView?.bounds.size.height)!/2 + (self.collectionView?.contentOffset.y)!)
                translationT = CGAffineTransform(translationX: self.layoutRadius! + ((1 - scaleFactor) * -30), y: 0)
            }
        }
        
        let scaleT = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        attributes.alpha = scaleFactor
        attributes.isHidden = false
        
        attributes.transform = scaleT.concatenating(translationT).concatenating(rotationT)

        return attributes
    }
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if self.shouldSnap! {
            let index = Int(floor(proposedContentOffset.y / self.itemHeight!))
            let off = (Int(proposedContentOffset.y) % Int(self.itemHeight!))
            
            let targetY = ( CGFloat(off) > self.itemHeight! * 0.5 && index <= self.cellCount!) ? CGFloat(index+1) * self.itemHeight! : CGFloat(index) * self.itemHeight!
            return CGPoint(x: proposedContentOffset.x, y: targetY)
        }else{
            return proposedContentOffset
        }
    }
    
    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        return IndexPath(item: 0, section: 0)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
}
