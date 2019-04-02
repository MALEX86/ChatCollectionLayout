import UIKit

public class ChatCollectionLayout: UICollectionViewFlowLayout {

    private var topMostVisibleItem = Int.max
    private var bottomMostVisibleItem = -Int.max

    private var offset: CGFloat = 0.0
    private var visibleAttributes: [UICollectionViewLayoutAttributes]?

    private var isInsertingItemsToTop = false
    private var isInsertingItemsToBottom = false

    var scrollIndexPath: IndexPath?

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleAttributes = super.layoutAttributesForElements(in: rect)
        offset = 0.0
        isInsertingItemsToTop = false
        isInsertingItemsToBottom = false

        return visibleAttributes
    }

    // swiftlint:disable:next cyclomatic_complexity
    override public func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        guard let collectionView = collectionView, let visibleAttributes = visibleAttributes else {
            return
        }

        bottomMostVisibleItem = -Int.max
        topMostVisibleItem = Int.max
        let container = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width:  collectionView.frame.size.width,
                               height: (collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)))

        for attributes in visibleAttributes {
            if attributes.frame.intersects(container) {
                let item = attributes.indexPath.item
                if item < topMostVisibleItem { topMostVisibleItem = item }
                if item > bottomMostVisibleItem { bottomMostVisibleItem = item }
            }
        }

        super.prepare(forCollectionViewUpdates: updateItems)

        var willInsertItemsToTop = false
        var willInsertItemsToBottom = false

        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                guard let indexPathAfterUpdate = updateItem.indexPathAfterUpdate, indexPathAfterUpdate.item != NSNotFound else {
                    continue
                }
                if topMostVisibleItem + updateItems.count > indexPathAfterUpdate.item,
                    let newAttributes = self.layoutAttributesForItem(at: indexPathAfterUpdate) {
                    offset += (newAttributes.size.height + self.minimumLineSpacing)
                    willInsertItemsToTop = true
                } else if bottomMostVisibleItem <= indexPathAfterUpdate.item,
                    let newAttributes = self.layoutAttributesForItem(at: indexPathAfterUpdate) {
                    offset += (newAttributes.size.height + self.minimumLineSpacing)
                    willInsertItemsToBottom = true
                }
            default:
                break
            }
        }

        if willInsertItemsToTop || willInsertItemsToBottom {
            let collectionViewContentHeight = collectionView.contentSize.height
            let collectionViewFrameHeight = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)

            if collectionViewContentHeight + offset > collectionViewFrameHeight {
                if willInsertItemsToTop {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    isInsertingItemsToTop = true
                } else if willInsertItemsToBottom {
                    isInsertingItemsToBottom = true
                }
            }
        }
    }

    override public func finalizeCollectionViewUpdates() {
        guard let collectionView = self.collectionView else { return }

        if isInsertingItemsToTop {
            if let scrollToIndex = scrollIndexPath, let offsetY = layoutAttributesForItem(at: scrollToIndex)?.frame.origin.y {
                offset = offsetY
            }
            let newContentOffset = CGPoint(x: collectionView.contentOffset.x,
                                           y: collectionView.contentOffset.y + offset)
            collectionView.contentOffset = newContentOffset
            CATransaction.commit()
        } else if isInsertingItemsToBottom {
            let newContentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentSize.height + offset -
                collectionView.frame.size.height + collectionView.contentInset.bottom)
            collectionView.setContentOffset(newContentOffset, animated: true)
        }
    }

}

