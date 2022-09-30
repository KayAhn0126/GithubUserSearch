# GithubUserSearch

## 🍎 작동 화면

| 작동 화면 | 
| :-: | 
| ![](https://i.imgur.com/GvMt9fy.gif)| 

## 🍎 GithubUserProfile과 다른점
- [GithubUserProfile 프로젝트](https://github.com/KayAhn0126/GithubUserProfile)의 작동 화면을 보면 정확한 user name을 입력하지 않으면 원하는 결과를 얻기 어렵다. 그래서 입력한 user name을 가지고 있는 username을 보여주게 하고 그중 하나를 선택하면 자세한 내용(이름, username, follower, location, etc.)을 보여주는 세부화면으로 들어가는 앱

## 🍎 search 버튼이 클릭 되었을때 실행되는 searchBarSearchButtonClicked 및 searchBarCancelButtonClicked 메서드 분석
- SearchViewController 내 searchBarSearchButtonClicked 메서드 코드 

```swift
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        datasource.apply(snapshot)
    }
}
```




## 🍎 궁금했던점
- SearchViewController은 검색창에 user name이 입력되고 search 버튼을 누르게 되면 관련된 유저네임을 보여준다.
- user name을 query로 주었을때 무엇을 기준으로 데이터(결과)를 가져오는지 궁금했다. (ex. 키워드 포함 or 연관성 or 글자수, etc.)
- 내가 원했던 답은 아니였지만 아래와 같은 답을 찾을수 있었다.
    - [Many of the resources on this API provide a shortcut for getting information about the currently authenticated user. If a request URL does not include a {username} parameter then the response will be for the logged in user](https://docs.github.com/en/rest/users/users)
