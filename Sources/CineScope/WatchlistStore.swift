import Foundation

final class WatchlistStore {
    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var movies: [Movie] = []

    init(defaults: UserDefaults = .standard, key: String = "cinescope.watchlist") {
        self.defaults = defaults
        self.key = key
        load()
    }

    func isSaved(_ movie: Movie) -> Bool {
        movies.contains { $0.trackId == movie.trackId }
    }

    func toggle(_ movie: Movie) {
        if isSaved(movie) {
            movies.removeAll { $0.trackId == movie.trackId }
        } else {
            movies.insert(movie, at: 0)
        }
        persist()
    }

    func remove(at index: Int) {
        guard movies.indices.contains(index) else { return }
        movies.remove(at: index)
        persist()
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let decoded = try? decoder.decode([Movie].self, from: data) else { return }
        movies = decoded
    }

    private func persist() {
        guard let data = try? encoder.encode(movies) else { return }
        defaults.set(data, forKey: key)
    }
}
