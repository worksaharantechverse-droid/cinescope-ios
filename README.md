# CineScope

A programmatic UIKit movie discovery app backed by the free iTunes Search API. Search movies, browse posters, inspect details and save titles to a local watchlist.

## Data source

Movie metadata comes from Apple's public iTunes Search API (`https://itunes.apple.com/search`, entity `movie`). It requires no API key or paid account. Poster images are downloaded from the URLs returned by the API and cached in memory and the Caches directory.

## Installation

```bash
cd 04-CineScope
brew install xcodegen
xcodegen generate
open CineScope.xcodeproj
```

## Build

```bash
xcodebuild -project CineScope.xcodeproj -scheme CineScope \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/CineScopeDerived CODE_SIGNING_ALLOWED=NO build
```

## Architecture

- **Models**: `Movie` and `MovieResponse` are `Codable`, with computed presentation values for year, genre, rating and poster URL.
- **Services**: `MovieServicing` with `ITunesMovieService` and `MockMovieService`; `ImageCache` provides two-level poster caching.
- **Store**: `WatchlistStore` persists saved movies with `UserDefaults` and `Codable`.
- **ViewModel**: `@MainActor MovieListViewModel` owns loading, error and result state.
- **Views**: `MovieListViewController`, `MovieCell`, `MovieDetailViewController`, `WatchlistViewController`, coordinated by `SceneDelegate` in a `UITabBarController`.

## Features

- Debounced movie search with the iTunes Search API.
- Two-column poster grid adapting to regular-width layouts.
- Detail screen with poster, year, genre, rating and synopsis.
- Save/unsave movies to a persistent watchlist.
- Watchlist tab with swipe-to-delete.
- Optional App Store deep link from each movie.
- Loading, empty and error states.
- Light and dark appearance.

## Verification

- Build: passed on Xcode 26.0.1, iOS 17.0 deployment target.
- Test targets compile via `build-for-testing`.
- Unit and UI tests authored; execution skipped at the user's request.
- Installed and launched on iPhone 17 (iOS 26.0); genuine light and dark screenshots captured.

## Known limitations

- Search and poster downloads require network access; cached posters remain available offline after first load.
- App Store deep links should be confirmed on a physical device.
- The mock service is used only for deterministic UI tests.
