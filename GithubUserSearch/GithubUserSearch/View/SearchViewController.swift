//
//  SearchViewController.swift
//  GithubUserSearch
//
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    // 해야 할일 크게 2가지.
    // 컬렉션뷰 DiffableDataSource, NSsnapshot, compositional layout
    // 네트워크를 통해 데이터를 받았을때 파이프라인 생성 -> bind()
    
    enum Section {
        case main
    }
    
    typealias Item = SearchResult
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchController()
        configureDataSource()
    }
    
    private func configureDataSource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {
                return nil
            }
            cell.user.text = item.login
            return cell
        })
        collectionView.collectionViewLayout = configureLayout()
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createSearchController() {
        self.navigationItem.title = "Search"
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search Github User..."
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        self.navigationItem.searchController = searchController
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        print("\(text)")
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("completed with : \(searchBar.text)")
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}
