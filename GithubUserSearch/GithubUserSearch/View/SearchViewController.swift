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
    
    @Published private(set) var searchUserResult: [SearchResult] = []
    var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchController()
        configureDataSource()
        bind()
    }
    
    private func bind() {
        $searchUserResult
            .receive(on: RunLoop.main)
            .sink { [unowned self] result in
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(result, toSection: .main)
                self.datasource.apply(snapshot)
            }.store(in: &subscriptions)
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
        
        guard let keyword = searchBar.text else { return }
        let base = "https://api.github.com/"
        let path = "search/users"
        let params: [String: String] = ["q": keyword]
        let header: [String: String] = ["Content-Type": "application/json"]
        
        var urlComponents = URLComponents(string: base + path)!
        let queryItems = params.map { (key: String, value: String) in
            return URLQueryItem(name: key, value: value)
        }
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        header.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .replaceError(with: [])
            .receive(on: RunLoop.main)
            .assign(to: \.searchUserResult, on: self)
            .store(in: &subscriptions)
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}
