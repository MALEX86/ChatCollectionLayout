//
//  ViewController.swift
//  ChatCollectionLayout
//
//  Created by BarredEwe on 04/02/2019.
//  Copyright (c) 2019 BarredEwe. All rights reserved.
//

import UIKit
import ChatCollectionLayout

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let cellIdentifier = "messageCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    }
}

extension ViewController: UICollectionViewDelegate { }

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 64)
    }
}

