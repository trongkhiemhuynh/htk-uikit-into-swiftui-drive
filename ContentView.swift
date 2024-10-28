import SwiftUI

struct ContentView: View {
    
    typealias Row = CollectionRow<Int, String>
    
    var rows: [Row] = {
        var rows = [Row]()
        
        for i in 0..<100 {
            rows.append(Row(section: i, items: (0..<10).map({ j in
                "\(i), \(j)"
            })))
        }
        return rows
    }()
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//        }
        
        CollectionView(rows: rows) { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(320), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
            section.interGroupSpacing = 40
            section.orthogonalScrollingBehavior = .continuous
            return section
        } cell: { indexPath, item in
            GeometryReader { geometry in
                Button(action: {print("hello \(item) - \(indexPath)")}) {
                    Text(item)
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                        .background(Color.blue)
                }
                .buttonStyle(BorderedButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)

    }
}
