//
//  EventViewController.swift
//  TravelLive
//
//  Created by Enola Zhu on 2022/4/14.
//

import UIKit

class EventViewController: UIViewController, UICollectionViewDelegate {
    
    
    static let headerKind = "headerKind"
    
    enum Section: Int {
        case tainan = 0
        case taizhong = 1
        case taipei = 2
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dynamicAnimator: UIDynamicAnimator!
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()
    }
    
    private func configureHierarchy() {
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.registerCellWithNib(identifier: String(describing: ImageCell.self), bundle: nil)
        collectionView.register(UINib(nibName: "TitleView", bundle: nil),
                            forSupplementaryViewOfKind: EventViewController.headerKind,
                            withReuseIdentifier: TitleView.reuseIdentifier)
        collectionView.delegate = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        
        
        let footerHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerHeaderSize, elementKind: EventViewController.headerKind, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)

        return layout
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ImageCell.self),
                for: indexPath) as? ImageCell else { fatalError("Cannot create new cell") }
            if indexPath.section == 0 {
                cell.backgroundColor = UIColor.primary
            } else {
                cell.backgroundColor = UIColor.blue
            }
            cell.propertyImageView.image = UIImage(named: "placeholder")
            
            return cell
        }
            
            dataSource.supplementaryViewProvider = {(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in

                // Get a supplementary view of the desired kind.
                if let titleView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TitleView.reuseIdentifier,
                    for: indexPath) as? TitleView {

                    switch kind {
                    case EventViewController.headerKind:
                        titleView.eventTitleLbl.text = "Place"
                    default:
                        ()
                    }
                    return titleView
                } else {
                    fatalError("Cannot create new supplementary")
                }
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.tainan])
        snapshot.appendItems(Array(1..<5))
        snapshot.appendSections([.taizhong])
        snapshot.appendItems(Array(6..<12))
        snapshot.appendSections([.taipei])
        snapshot.appendItems(Array(13..<20))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
extension EventViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}
