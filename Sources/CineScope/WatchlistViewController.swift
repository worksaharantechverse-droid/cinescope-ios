import UIKit

final class WatchlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel = UILabel()
    private let watchlist: WatchlistStore

    init(watchlist: WatchlistStore) {
        self.watchlist = watchlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        view.backgroundColor = CineTheme.background()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emptyLabel.isHidden = !watchlist.movies.isEmpty
        tableView.reloadData()
    }

    private func setup() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WatchlistCell")
        tableView.accessibilityIdentifier = "watchlist-table"
        view.addSubview(tableView)

        emptyLabel.text = "Saved movies appear here.\nTap + on a movie to add it."
        emptyLabel.font = CineTheme.font(15, weight: .medium)
        emptyLabel.textColor = CineTheme.secondaryText()
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        watchlist.movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell", for: indexPath)
        let movie = watchlist.movies[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = movie.trackName
        config.secondaryText = "\(movie.year) · \(movie.genre)"
        config.textProperties.color = CineTheme.primaryText()
        config.secondaryTextProperties.color = CineTheme.secondaryText()
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = CineTheme.surface()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = MovieDetailViewController(movie: watchlist.movies[indexPath.row], watchlist: watchlist)
        navigationController?.pushViewController(detail, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        watchlist.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        emptyLabel.isHidden = !watchlist.movies.isEmpty
    }
}
