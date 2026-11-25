# Technical Challenges — CineScope

## Keyless movie data

TMDb and OMDb require API keys. The iTunes Search API provides movie metadata without credentials, making the app buildable by anyone without developer registration.

## Stale search responses

Fast typing can produce overlapping requests. Each search is a cancellable task with a 300 ms debounce, so only the latest query updates the collection view.

## Poster caching

Downloading posters inside reusable cells can cause duplicate network work and wrong-image flicker. `ImageCache` uses an in-memory `NSCache` plus disk storage, and cells cancel their image task on reuse.

## Watchlist persistence

Movies are `Codable`, allowing the entire watchlist to be stored in `UserDefaults` without a database. An isolated suite name is used in UI tests to avoid polluting real user data.

## Programmatic layout

The grid uses `UICollectionViewFlowLayout` with a computed column count based on horizontal size class, and the detail screen uses a single scroll stack for predictable content sizing.

## Physical-device testing

External App Store links are documented rather than claimed as verified on hardware.
