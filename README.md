# 14 GithubUserSearch

## 🍎 search 버튼이 클릭 되었을때 실행되는 searchBarSearchButtonClicked 메서드 분석
- SearchViewController은 검색창에 유저네임이 입력되고 search 버튼을 누르게 되면 관련된 유저네임을 보여준다.
- 알아봐야할점.
    - 1. 유저네임을 입력하면 무엇을 기준으로 가져오나?
        - 입력된 키워드가 포함되어있으면 포함시키는것인지?
        - 몇 글자만 들어가있더라도 가져오는것인지 확인하기.
    - 2. request를 구성하는 요소 파악하기
