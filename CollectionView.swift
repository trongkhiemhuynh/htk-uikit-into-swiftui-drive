//
//  File.swift
//  Drive Diffable Datasource
//
//  Created by khiemht on 28/10/2024.
//

import Foundation
import SwiftUI

struct CollectionView<Section: Hashable, Item: Hashable, Cell: View>: UIViewRepresentable {
    let cell: (IndexPath, Item) -> Cell
    let rows: [CollectionRow<Section, Item>]
    let sectionLayoutProvider: (Int, NSCollectionLayoutEnvironment)->NSCollectionLayoutSection
    
    // MARK:-init
    init(rows: [CollectionRow<Section, Item>],
         sectionLayoutProvider: @escaping(Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection, @ViewBuilder cell:@escaping(IndexPath, Item)->Cell) {
        
        self.rows = rows
        self.sectionLayoutProvider = sectionLayoutProvider
        self.cell = cell
    }
    
    // MARK:-class coordinator
    class Coordinator {
        fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
        fileprivate var datasource: DataSource? = nil
        
        fileprivate var sectionLayoutProvider: ((Int, NSCollectionLayoutEnvironment)->NSCollectionLayoutSection)?
        fileprivate var rowsHash: Int? = nil
    }
    
    private class HostCell: UICollectionViewCell {
        private var hostController: UIHostingController<Cell>?
        
        override func prepareForReuse() {
            if let hostView = hostController?.view {
                hostView.removeFromSuperview()
            } else {
                hostController = nil
            }
        }
        
        var hostedCell: Cell? {
            willSet {
                guard let view = newValue else {return}
                
                hostController = UIHostingController(rootView: view)
                
                if let hostView = hostController?.view {
                    hostView.frame = contentView.bounds
                    hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    contentView.addSubview(hostView)
                }
            }
        }
    }
    
    // MARK:- protocol function?
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    
    private func layout(context: Context) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // MARK: hello section Index, layout Environment
            // MARK:- mark closure
            let layout = context.coordinator.sectionLayoutProvider!(sectionIndex, layoutEnvironment)
            return layout
//            return sectionLayoutProvider(sectionIndex, layoutEnvironment)
        }
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let cellIdentifier = "hostCell"
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout(context: context))
        
        collectionView.register(HostCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        
        context.coordinator.datasource = Coordinator.DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            
            //MARK:- fixed temp return ui collection cell for the item
//            return UICollectionViewCell()
            let hostCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HostCell
            
            hostCell.hostedCell = cell(indexPath, item)
            reloadData(context: context)
            return hostCell
        }
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
//        guard let dataSource = context.coordinator.datasource else {return}
//        dataSource.apply(snapshot(), animatingDifferences: true)
        // MARK:- revision update
        
        reloadData(context: context, animated:  true)
    }
    
    func snapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        for row in rows {
            snapshot.appendSections([row.section])
            snapshot.appendItems(row.items, toSection: row.section)
        }
        
        return snapshot
    }
    
    private func reloadData(context: Context, animated: Bool = false) {
        let coordinator = context.coordinator
        coordinator.sectionLayoutProvider = self.sectionLayoutProvider
        
        guard let dataSource = coordinator.datasource else {return}
        
        let rowsHash = rows.hashValue
        if coordinator.rowsHash != rowsHash {
            dataSource.apply(snapshot(), animatingDifferences: animated, completion: nil)
            coordinator.rowsHash = rowsHash
        }
    }
}

struct CollectionRow<Section: Hashable, Item: Hashable>: Hashable {
    //...
    let section: Section
    let items: [Item]
}
