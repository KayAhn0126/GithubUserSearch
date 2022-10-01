# GithubUserSearch
- UICollectionView
    - UICollectionViewDiffableDataSource
    - NSDiffableDataSourceSnapshot
    - UICollectionViewCompositionalLayout
- UISearchController
- Combine
- Kingfisher
- Xcode Package Manager
- Navigation Controller

## 🍎 전반적인 프로세스 설명
- 메인화면에서 찾고싶은 user의 username 검색
- 데이터를 수신 후 해당 username을 포함하는 데이터를 반환
- 특정 username을 선택하면 해당 user의 자세한 정보를 보여줌.

## 🍎 작동 화면

| 작동 화면 | 
| :-: | 
| ![](https://i.imgur.com/GvMt9fy.gif)| 

## 🍎 GithubUserProfile과 다른점
- [GithubUserProfile 프로젝트](https://github.com/KayAhn0126/GithubUserProfile)의 작동 화면을 보면 정확한 user name을 입력하지 않으면 원하는 결과를 얻기 어렵다. 그래서 입력한 user name을 가지고 있는 username을 보여주게 하고 그중 하나를 선택하면 자세한 내용(이름, username, follower, location, etc.)을 보여주는 세부화면으로 들어가는 앱

## 🍎 extension내 UISearchBarDelegate 관련 optional 함수 구현
```swift
extension SearchViewController: UISearchBarDelegate {
    
    // search 버튼이 클릭 되었을 때 실행되는 searchBarSearchButtonClicked 메서드 코드 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return } // 사용자가 입력한 user name
        let base = "https://api.github.com/"
        let path = "search/users"
        let params: [String: String] = ["q": keyword]
        let header: [String: String] = ["Content-Type": "application/json"]
        
        var urlComponents = URLComponents(string: base + path)!    // url주소로 component 생성
        let queryItems = params.map { (key: String, value: String) in
            return URLQueryItem(name: key, value: value)           // 파라미터의 key/value 를 배열 형태로 반환
        }
        urlComponents.queryItems = queryItems                      // component의 queryItems 프로퍼티에 대입
        
        var request = URLRequest(url: urlComponents.url!)          // 위에서 생성한 component의 url을 이용해 request 생성
        header.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)       // header를 돌면서 key/value를 request에 추가
        }

        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data } 
            // 클로져 내 $0은 URLSession.DataTaskPublisher.Output 타입이다
            // 정의부 -> typealias URLSession.DataTaskPublisher.Output = (data: Data, response: URLResponse)
            // 즉, RLSession.DataTaskPublisher.Output.data
            .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
            // JSONDecoder를 사용해 data를 SearchUserResponse형태로 decode 한다.
            .map { $0.items }
            // SearchUserResponse의 items를 받아온다.
            .replaceError(with: [])
            // func replaceError(with output: Output) -> Just<Output>
            // 에러가 발생하면 빈 배열로 대체한다.
            .receive(on: RunLoop.main)
            .assign(to: \.searchUserResult, on: self)
            .store(in: &subscriptions)
    }
    
    // cancel 버튼이 클릭 되었을 때 실행되는 searchBarCancelButtonClicked 메서드
    // cancel 버튼이 클릭되면 빈배열을 snapshot에 추가해 datasource에 적용시킨다.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems([], toSection: .main)
        datasource.apply(snapshot)
    }
}
```

## 🍎 collectionView에서 아이템이 선택되었을때 작동하는 메서드 구현
- 이곳에서도 네트워크 통신을 하는 코드가 있지만 위의 방식과 다른점이라면
    1. path와 params가 다름. -> 그에 따라 map이나 foreach를 사용하지 않음.
    2. NetworkService 객체 사용
        - 위의 코드에선 URLComponent와 URLRequest까지 모두 구현했지만
        - 아래의 코드에선 Resource 인스턴스를 만들때 URLComponent와 URLRequest 생성에 필요한 데이터를 매개변수로 받아 내부에서 생성 후 Resource 인스턴스를 NetworkService에 사용. (이 방법이 더 깔끔하다)
``` swift
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedUserName = searchUserResult[indexPath.item].login
        
        let resource = Resource<DetailSearchResult>(    // Resource 인스턴스 생성
            base: "https://api.github.com/",
            path: "users/\(selectedUserName)",
            params: [:],
            header: ["Content-Type": "application/json"]
        )
        let detailStoryboard = UIStoryboard(name: "Detail", bundle: nil)
        let currentVC = detailStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        let detailNetwork = NetworkService(configuration: .default) // 네트워크 객체 생성
        detailNetwork.load(resource)    // 네트워크 객체의 load메서드에 resource를 넣어줌으로써 수신 시작.
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error Code : \(error)")
                case .finished:
                    print("Completed with: \(completion)")
                    break
                }
            } receiveValue: { result in
                currentVC.userInfo = result
            }
            .store(in: &subscriptions)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        currentVC.navigationItem.title = selectedUserName
        navigationController?.pushViewController(currentVC, animated: true)
    }
}
```

## 🍎 궁금했던점
- SearchViewController은 검색창에 user name이 입력되고 search 버튼을 누르게 되면 관련된 유저네임을 보여준다.
- user name을 query로 주었을때 무엇을 기준으로 데이터(결과)를 가져오는지 궁금했다. (ex. 키워드 포함 or 연관성 or 글자수, etc.)
- 내가 원했던 답은 아니였지만 아래와 같은 답을 찾을수 있었다.
    - [Many of the resources on this API provide a shortcut for getting information about the currently authenticated user. If a request URL does not include a {username} parameter then the response will be for the logged in user](https://docs.github.com/en/rest/users/users)
