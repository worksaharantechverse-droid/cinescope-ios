import UIKit

final class MovieDetailViewController: UIViewController {
    private let movie: Movie
    private let watchlist: WatchlistStore
    private let hero = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingLabel = UILabel()
    private let synopsisLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let storeButton = UIButton(type: .system)
    private var imageTask: Task<Void, Never>?

    init(movie: Movie, watchlist: WatchlistStore) {
        self.movie = movie
        self.watchlist = watchlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = CineTheme.background()
        setup()
        loadImage()
    }

    private func setup() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        hero.contentMode = .scaleAspectFill
        hero.clipsToBounds = true
        hero.backgroundColor = UIColor(red: 0.16, green: 0.12, blue: 0.16, alpha: 1)
        hero.image = UIImage(systemName: "film.fill")?.withRenderingMode(.alwaysTemplate)
        hero.tintColor = CineTheme.accent.withAlphaComponent(0.55)
        hero.heightAnchor.constraint(equalToConstant: 320).isActive = true

        titleLabel.text = movie.trackName
        titleLabel.font = CineTheme.font(26, weight: .bold)
        titleLabel.textColor = CineTheme.primaryText()
        titleLabel.numberOfLines = 0

        metaLabel.text = "\(movie.year) · \(movie.genre)"
        metaLabel.font = CineTheme.font(14, weight: .semibold)
        metaLabel.textColor = CineTheme.secondaryText()

        ratingLabel.text = movie.ratingText
        ratingLabel.font = CineTheme.font(13, weight: .medium)
        ratingLabel.textColor = CineTheme.gold

        synopsisLabel.text = movie.synopsis
        synopsisLabel.font = CineTheme.font(15)
        synopsisLabel.textColor = CineTheme.primaryText()
        synopsisLabel.numberOfLines = 0

        configureSaveButton()
        storeButton.setTitle("Open in App Store", for: .normal)
        storeButton.titleLabel?.font = CineTheme.font(15, weight: .semibold)
        storeButton.isHidden = movie.trackViewUrl == nil
        storeButton.addTarget(self, action: #selector(openStore), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [hero, titleLabel, metaLabel, ratingLabel, synopsisLabel, saveButton, storeButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40)
        ])
        view.accessibilityIdentifier = "movie-detail"
    }

    private func configureSaveButton() {
        let saved = watchlist.isSaved(movie)
        var config = UIButton.Configuration.filled()
        config.title = saved ? "Saved to Watchlist" : "Add to Watchlist"
        config.image = UIImage(systemName: saved ? "checkmark.circle.fill" : "plus.circle")
        config.baseBackgroundColor = saved ? CineTheme.gold : CineTheme.accent
        config.baseForegroundColor = saved ? UIColor.black : .white
        config.cornerStyle = .capsule
        saveButton.configuration = config
        saveButton.addTarget(self, action: #selector(toggleSave), for: .touchUpInside)
        saveButton.accessibilityIdentifier = "watchlist-button"
    }

    private func loadImage() {
        guard let url = movie.posterURL else { return }
        imageTask = Task { [weak self] in
            let image = await ImageCache.shared.image(for: url)
            guard !Task.isCancelled, let image else { return }
            self?.hero.image = image
        }
    }

    @objc private func toggleSave() {
        watchlist.toggle(movie)
        configureSaveButton()
    }

    @objc private func openStore() {
        guard let string = movie.trackViewUrl, let url = URL(string: string) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
