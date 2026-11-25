import Foundation
import Combine

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: any MovieServicing

    init(service: any MovieServicing = ITunesMovieService()) {
        self.service = service
    }

    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let term = trimmed.isEmpty ? "marvel" : trimmed
        isLoading = true
        errorMessage = nil
        do {
            movies = try await service.search(query: term)
        } catch {
            errorMessage = error.localizedDescription
            movies = []
        }
        isLoading = false
    }
}
