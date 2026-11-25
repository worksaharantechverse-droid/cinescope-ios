import Foundation

struct MovieResponse: Decodable {
    let resultCount: Int
    let results: [Movie]
}

struct Movie: Codable, Equatable, Hashable, Identifiable {
    let trackId: Int
    let trackName: String
    let primaryGenreName: String?
    let releaseDate: String?
    let artworkUrl100: String?
    let shortDescription: String?
    let longDescription: String?
    let trackViewUrl: String?
    let averageUserRating: Double?
    let userRatingCount: Int?

    var id: Int { trackId }

    var year: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "Year unavailable" }
        return String(releaseDate.prefix(4))
    }

    var genre: String { primaryGenreName ?? "Movie" }

    var synopsis: String {
        let text = longDescription ?? shortDescription ?? ""
        return text.isEmpty ? "No synopsis available for this title." : text
    }

    var ratingText: String {
        guard let rating = averageUserRating else { return "Not rated" }
        return String(format: "%.1f ★ (%d ratings)", rating, userRatingCount ?? 0)
    }

    var posterURL: URL? {
        guard let artworkUrl100, let url = URL(string: artworkUrl100) else { return nil }
        return URL(string: artworkUrl100.replacingOccurrences(of: "100x100bb", with: "600x900bb")) ?? url
    }
}
