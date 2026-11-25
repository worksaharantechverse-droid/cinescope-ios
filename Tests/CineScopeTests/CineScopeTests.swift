import XCTest
@testable import CineScope

final class MovieParsingTests: XCTestCase {
    func testDecodesITunesPayload() throws {
        let json = """
        {
          "resultCount": 1,
          "results": [
            {
              "trackId": 123,
              "trackName": "Arrival",
              "primaryGenreName": "Science Fiction",
              "releaseDate": "2016-11-11T07:00:00Z",
              "artworkUrl100": "https://example.com/100x100bb.jpg",
              "shortDescription": "Short",
              "longDescription": "Long synopsis",
              "trackViewUrl": "https://example.com/movie",
              "averageUserRating": 4.5,
              "userRatingCount": 100
            }
          ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(MovieResponse.self, from: json)
        let movie = try XCTUnwrap(response.results.first)
        XCTAssertEqual(movie.trackName, "Arrival")
        XCTAssertEqual(movie.year, "2016")
        XCTAssertEqual(movie.synopsis, "Long synopsis")
        XCTAssertEqual(movie.posterURL?.absoluteString, "https://example.com/600x900bb.jpg")
        XCTAssertTrue(movie.ratingText.contains("4.5"))
    }

    func testSynopsisFallbacks() {
        let movie = Movie(trackId: 1, trackName: "Test", primaryGenreName: nil, releaseDate: nil, artworkUrl100: nil, shortDescription: nil, longDescription: nil, trackViewUrl: nil, averageUserRating: nil, userRatingCount: nil)
        XCTAssertEqual(movie.genre, "Movie")
        XCTAssertEqual(movie.year, "Year unavailable")
        XCTAssertEqual(movie.synopsis, "No synopsis available for this title.")
    }
}

final class WatchlistStoreTests: XCTestCase {
    func testToggleAndPersist() {
        let suite = "CineScopeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let movie = Movie(trackId: 7, trackName: "Test", primaryGenreName: "Drama", releaseDate: "2020-01-01", artworkUrl100: nil, shortDescription: nil, longDescription: nil, trackViewUrl: nil, averageUserRating: nil, userRatingCount: nil)

        let store = WatchlistStore(defaults: defaults)
        XCTAssertFalse(store.isSaved(movie))
        store.toggle(movie)
        XCTAssertTrue(store.isSaved(movie))

        let reloaded = WatchlistStore(defaults: defaults)
        XCTAssertEqual(reloaded.movies.count, 1)

        store.toggle(movie)
        XCTAssertFalse(store.isSaved(movie))
    }
}
