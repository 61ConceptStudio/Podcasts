//
//  EpisodesViewModel.swift
//  Podcasts
//
//  Created by Eugene Karambirov on 22/02/2019.
//  Copyright © 2019 Eugene Karambirov. All rights reserved.
//

import Foundation

final class EpisodesViewModel {

    // MARK: - Private
    fileprivate let networkingService = NetworkingService()

    // MARK: - Properties
    let podcast: Podcast
    var episodes = [Episode]()
    var dataSource: TableViewDataSource<Episode, EpisodeCell>?

    init(podcast: Podcast) {
        self.podcast = podcast
    }

}

// MARK: - Methods
extension EpisodesViewModel {

    func fetchEpisodes(_ completion: @escaping () -> Void) {
        print("Looking for episodes at feed url:", podcast.feedUrl ?? "")
        guard let feedURL = podcast.feedUrl else { return }
        networkingService.fetchEpisodes(feedUrl: feedURL) { [weak self] episodes in
            guard let self = self else { return }
            self.episodesDidLoad(episodes)
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func saveFavorite() {
        print("Saving info into UserDefaults")
        var listOfPodcasts = UserDefaults.standard.savedPodcasts
        listOfPodcasts.append(podcast)
        let data = try! NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts,
                                                     requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    }

    func download(_ episode: Episode) {
        print("Downloading episode into UserDefaults")
        UserDefaults.standard.downloadEpisode(episode)
        networkingService.downloadEpisode(episode)
    }

    func episode(for indexPath: IndexPath) -> Episode {
        return episodes[indexPath.row]
    }

    fileprivate func episodesDidLoad(_ episodes: [Episode]) {
        self.episodes = episodes
        dataSource = .make(for: episodes)
    }

}
