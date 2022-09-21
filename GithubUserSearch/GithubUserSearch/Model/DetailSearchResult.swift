//
//  DetailSearchResult.swift
//  GithubUserSearch
//
//  Created by Kay on 2022/09/21.
//

import Foundation

struct DetailSearchResult: Hashable, Identifiable, Decodable {
    var id: Int64
    var login: String
    var name: String?
    var avatarUrl: URL
    var htmlUrl: String
    var followers: Int
    var following: Int
    var firstDate: String
    var latestupdateDate: String
    var company: String?
    var location: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case followers
        case following
        case firstDate = "created_at"
        case latestupdateDate = "updated_at"
        case company
        case location
    }
}
