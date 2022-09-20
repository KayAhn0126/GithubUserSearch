//
//  SearchViewController.swift
//  GithubUserSearch
//
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchController()
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
