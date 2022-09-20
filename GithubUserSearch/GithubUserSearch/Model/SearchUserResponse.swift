//
//  SearchUserResponse.swift
//  GithubUserSearch
//
//

import Foundation

struct SearchUserResponse: Decodable {
    var items: [SearchResult]
}
