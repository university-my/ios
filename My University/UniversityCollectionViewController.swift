//
//  UniversityCollectionViewController.swift
//  My University
//
//  Created by Yura Voevodin on 26.11.2019.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import UIKit

class UniversityCollectionViewController: UICollectionViewController {

  enum SectionLayoutKind: Int, CaseIterable {
      case list, grid2
      var columnCount: Int {
          switch self {
          case .grid2:
              return 2

          case .list:
              return 1
          }
      }
  }

  var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

      configureCollectionView()
      configureDataSource()
    }
}


extension UniversityCollectionViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            let columns = sectionLayoutKind.columnCount

            // The `group` auto-calculates the actual item width to make
            // the requested number of `columns` fit, so this `widthDimension` will be ignored.
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                 heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

            let groupHeight = columns == 1 ?
                NSCollectionLayoutDimension.absolute(44) :
                NSCollectionLayoutDimension.fractionalWidth(0.2)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        return layout
    }
}

extension UniversityCollectionViewController {
  func configureCollectionView() {
    // Register cell classes
    collectionView.collectionViewLayout = createLayout()
    collectionView.register(TextCell.self, forCellWithReuseIdentifier: TextCell.reuseIdentifier)
    collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
  }
  func configureDataSource() {
      dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) {
          (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in

          let section = SectionLayoutKind(rawValue: indexPath.section)!
          if section == .list {
              // Get a cell of the desired kind.
              if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier,
                                                       for: indexPath) as? ListCell {

                  // Populate the cell with our item description.
                  cell.label.text = "\(identifier)"

                  // Return the cell.
                  return cell
              } else {
                  fatalError("Cannot create new cell")
              }
          } else {
              // Get a cell of the desired kind.
              if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.reuseIdentifier,
                                                       for: indexPath) as? TextCell {

                  // Populate the cell with our item description.
                  cell.label.text = "\(identifier)"
                  cell.contentView.backgroundColor = .cornflowerBlue
                  cell.contentView.layer.borderColor = UIColor.black.cgColor
                  cell.contentView.layer.borderWidth = 1
                  cell.contentView.layer.cornerRadius = section == .grid2 ? 8 : 0
                  cell.label.textAlignment = .center
                  cell.label.font = UIFont.preferredFont(forTextStyle: .title1)

                  // Return the cell.
                  return cell
              } else {
                  fatalError("Cannot create new cell")
              }
          }
      }

      // initial data
      let itemsPerSection = 10
      var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
      SectionLayoutKind.allCases.forEach {
          snapshot.appendSections([$0])
          let itemOffset = $0.rawValue * itemsPerSection
          let itemUpperbound = itemOffset + itemsPerSection
          snapshot.appendItems(Array(itemOffset..<itemUpperbound))
      }
      dataSource.apply(snapshot, animatingDifferences: false)
  }
}

extension UniversityCollectionViewController {
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
