//
//  ViewController.swift
//  CollectionViewHorizontal-Sample
//
//  Created by 今村京平 on 2021/10/10.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet private weak var myCollectionView: UICollectionView!

    private var items = ["1", "2", "3", "4", "5", "6"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        let layout = myCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = myCollectionView.bounds.height
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        myCollectionView.collectionViewLayout = layout
        myCollectionView.decelerationRate = .fast
    }

    private func setupCollectionView() {
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
    }

    // MARK: - CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyCollectionViewCell
        cell.configure(text: items[indexPath.row])
        cell.backgroundColor = .systemGray6
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width, height: 400)
    }
}

final class myCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }

        // sectionInset を考慮して表示領域を拡大する
        let expansionMargin = sectionInset.left + sectionInset.right
        let expandedVisibleRect = CGRect(x: collectionView.contentOffset.x - expansionMargin,
                                          y: 0,
                                          width: collectionView.bounds.width + (expansionMargin * 2),
                                          height: collectionView.bounds.height)

        // 表示領域の layoutAttributes を取得し、X座標でソートする
        // rectの範囲内に存在するアイテムのAttributesを返す(layoutAttributesForElements(in:))
        guard let targetAttributes = layoutAttributesForElements(in: expandedVisibleRect)?
            .sorted(by: { $0.frame.minX < $1.frame.minX }) else { return proposedContentOffset }

        let nextAttributes: UICollectionViewLayoutAttributes?
        if velocity.x == 0 {
            // スワイプせずに指を離した場合は、画面中央から一番近い要素を取得する
            nextAttributes = layoutAttributesForNearbyCenterX(in: targetAttributes, collectionView: collectionView)
        } else if velocity.x > 0 {
            // 左スワイプの場合は、最後の要素を取得する
            nextAttributes = targetAttributes.last
        } else {
            // 右スワイプの場合は、先頭の要素を取得する
            nextAttributes = targetAttributes.first
        }
        guard let attributes = nextAttributes else { return proposedContentOffset }

        if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
            // ヘッダーの場合は先頭の座標を返す
            return CGPoint(x: 0, y: collectionView.contentOffset.y)
        } else {
            // 画面左端からセルのマージンを引いた座標を返して画面中央に表示されるようにする
            let cellLeftMargin = (collectionView.bounds.width - attributes.bounds.width) * 0.5
            return CGPoint(x: attributes.frame.minX - cellLeftMargin, y: collectionView.contentOffset.y)
        }
    }

    // 画面中央に一番近いセルの attributes を取得する
    private func layoutAttributesForNearbyCenterX(in attributes: [UICollectionViewLayoutAttributes], collectionView: UICollectionView) -> UICollectionViewLayoutAttributes? {
        print(collectionView.contentLayoutGuide)
        let intervalArray: [CGFloat] = attributes.map { abs($0.center.x - collectionView.contentOffset.x - collectionView.frame.width / 2) }
        let minimumInterval = intervalArray.min()
        let minIndex = intervalArray.firstIndex(of: minimumInterval!)!
        return attributes[minIndex]
    }
}
