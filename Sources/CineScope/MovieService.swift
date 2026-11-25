import Foundation

protocol MovieServicing {
    func search(query: String) async throws -> [Movie]
}

final class ITunesMovieService: MovieServicing {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func search(query: String) async throws -> [Movie] {
        var components = URLComponents(string: "https://itunes.apple.com/search")!
        components.queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "entity", value: "movie"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "country", value: "us")
        ]
        guard let url = components.url else { throw MovieServiceError.invalidURL }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw MovieServiceError.badResponse
        }
        return try decoder.decode(MovieResponse.self, from: data).results
    }
}

enum MovieServiceError: LocalizedError {
    case invalidURL
    case badResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The search URL could not be created."
        case .badResponse: return "The movie service returned an unexpected response."
        }
    }
}

final class MockMovieService: MovieServicing {
    func search(query: String) async throws -> [Movie] {
        [
            Movie(trackId: 1, trackName: "The Grand Budapest Hotel", primaryGenreName: "Comedy", releaseDate: "2014-03-28", artworkUrl100: nil, shortDescription: "A concierge and his lobby boy are drawn into a mystery.", longDescription: nil, trackViewUrl: nil, averageUserRating: 4.5, userRatingCount: 1200),
            Movie(trackId: 2, trackName: "Arrival", primaryGenreName: "Science Fiction", releaseDate: "2016-11-11", artworkUrl100: nil, shortDescription: "A linguist is recruited to communicate with visitors.", longDescription: nil, trackViewUrl: nil, averageUserRating: 4.3, userRatingCount: 980),
            Movie(trackId: 3, trackName: "Little Miss Sunshine", primaryGenreName: "Drama", releaseDate: "2006-07-26", artworkUrl100: nil, shortDescription: "A family road trip to a beauty pageant.", longDescription: nil, trackViewUrl: nil, averageUserRating: 4.2, userRatingCount: 640)
        ]
    }
}
