import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)

        let arguments = ProcessInfo.processInfo.arguments
        let isMocked = arguments.contains("-UITestMock")
        let defaults: UserDefaults = isMocked
            ? (UserDefaults(suiteName: "CineScopeUITests") ?? .standard)
            : .standard
        if isMocked && arguments.contains("-UITestReset") {
            defaults.removePersistentDomain(forName: "CineScopeUITests")
        }

        let service: any MovieServicing = isMocked ? MockMovieService() : ITunesMovieService()
        let watchlist = WatchlistStore(defaults: defaults)

        let discover = UINavigationController(rootViewController: MovieListViewController(
            viewModel: MovieListViewModel(service: service),
            watchlist: watchlist
        ))
        discover.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        let saved = UINavigationController(rootViewController: WatchlistViewController(watchlist: watchlist))
        saved.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "bookmark"), tag: 1)

        let tabs = UITabBarController()
        tabs.viewControllers = [discover, saved]
        tabs.tabBar.tintColor = CineTheme.accent

        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
    }
}
