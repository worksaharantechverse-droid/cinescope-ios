# Architecture — CineScope

## Layers

| Layer | Types | Responsibility |
|-------|-------|----------------|
| Model | `Movie`, `MovieResponse` | Codable iTunes payload and computed display values |
| Service | `MovieServicing`, `ITunesMovieService`, `MockMovieService` | Search networking and deterministic test data |
| Cache | `ImageCache` | NSCache plus Caches-directory JPEG storage |
| Store | `WatchlistStore` | Codable persistence of saved movies |
| ViewModel | `MovieListViewModel` | Loading, results and error state |
| Views | `MovieListViewController`, `MovieCell`, `MovieDetailViewController`, `WatchlistViewController` | Programmatic UIKit screens |

## Search flow

`UISearchController` updates the view model after a 300 ms debounce. Cancelling the previous task prevents stale responses from replacing newer results. The initial screen loads a popular query so the grid is never empty on first launch.

## Image loading

Poster URLs are upgraded from 100×100 to 600×900 where possible. Images are stored in `NSCache` and in the app Caches directory, avoiding repeated downloads during scrolling and after relaunch.

## Dependency injection

`SceneDelegate` injects either `ITunesMovieService` or `MockMovieService`, and a standard or isolated `UserDefaults` suite. UI tests can therefore run without network access or cross-run state.

## SOLID application

- Single responsibility: networking, caching and persistence are separated.
- Liskov substitution: mock and real services conform to the same protocol.
- Dependency inversion: the view model depends on `MovieServicing`, not URLSession.
