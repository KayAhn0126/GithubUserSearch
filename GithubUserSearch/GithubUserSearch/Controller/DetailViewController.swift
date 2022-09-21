//
//  DetailViewController.swift
//  GithubUserSearch
//
//  Created by Kay on 2022/09/21.
//

import UIKit
import Combine
import Kingfisher

class DetailViewController: UIViewController {
    @Published var userInfo: DetailSearchResult?
    var detailSubscription = Set<AnyCancellable>()
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var firstDateLabel: UILabel!
    @IBOutlet weak var latestUpdateLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func bind() {
        $userInfo
            .receive(on: RunLoop.main)
            .sink { [unowned self] user in
                self.configureCurrentView(user)
            }
            .store(in: &detailSubscription)
    }
    
    private func setupUI() {
        thumbnail.layer.cornerRadius = 80
    }

    private func configureCurrentView(_ user: DetailSearchResult?) {
        guard let user = user else { return }
        self.nameLabel.text = "Name : \(user.name ?? "Secret!")"
        self.loginLabel.text = "Github id : " + user.login
        self.followerLabel.text = "followers : \(user.followers)"
        self.followingLabel.text = "following : \(user.following)"
        self.firstDateLabel.text = "first date : \(user.firstDate)"
        self.latestUpdateLabel.text = "latest update : \(user.latestupdateDate)"
        self.companyLabel.text = "company : \(user.company ?? "still studying!")"
        self.locationLabel.text = "location : \(user.location ?? "somewhere on Earth")"
        self.thumbnail.kf.setImage(with: user.avatarUrl)
    }
}
