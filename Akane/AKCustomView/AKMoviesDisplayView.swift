//
//  AKMoviesDisplayView.swift
//  Akane
//
//  Created by Grass Plainson on 2020/5/13.
//  Copyright © 2020 Grass Plainson. All rights reserved.
//

import UIKit

class AKMoviesDisplayView: AKUIView {
    
    // MARK: - Property.
    
    var moviesCollectionView: AKUICollectionView!
    
    // MARK: - Init.

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        self.moviesCollectionView = AKUICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: flowLayout)
        flowLayout.itemSize = CGSize.init(width: AKConstant.MovieDisplayView.itemSizeWidth, height: AKConstant.MovieDisplayView.itemSizeHeight)
        flowLayout.minimumLineSpacing = AKConstant.MovieDisplayView.minLineSpace
        flowLayout.sectionInset.top = AKConstant.MovieDisplayView.itemTopEdge
        flowLayout.sectionInset.left = AKConstant.MovieDisplayView.itemLeftEdge
        flowLayout.sectionInset.right = AKConstant.MovieDisplayView.itemRightEdge
        flowLayout.sectionInset.bottom = AKConstant.MovieDisplayView.itemBottomEdge
        self.moviesCollectionView.register(AKMovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        self.moviesCollectionView.allowsMultipleSelection = true
        self.addSubview(self.moviesCollectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
