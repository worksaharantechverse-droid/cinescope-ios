import UIKit
import Combine

final class MovieListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    private let collectionView: UICollectionView
    private let emptyLabel = UILabel()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let viewModel: MovieListViewModel
    private let watchlist: WatchlistStore
    private let searchController = UISearchController(searchResultsController: nil)
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(viewModel: MovieListViewModel, watchlist: WatchlistStore) {
        self.viewModel = viewModel
        self.watchlist = watchlist
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 4, left: 20, bottom: 20, right: 20)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Discover"
        view.backgroundColor = CineTheme.background()
        setupSearch()
        setupCollection()
        setupStates()
        bind()
        Task { await viewModel.search(query: "marvel") }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupCollection() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseID)
        collectionView.accessibilityIdentifier = "movie-grid"
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStates() {
        emptyLabel.text = "No movies found. Try another title."
        emptyLabel.font = CineTheme.font(15, weight: .medium)
        emptyLabel.textColor = CineTheme.secondaryText()
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        loadingView.color = CineTheme.accent
        loadingView.hidesWhenStopped = true
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bind() {
        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                collectionView.reloadData()
                emptyLabel.text = viewModel.errorMessage ?? "No movies found. Try another title."
                emptyLabel.isHidden = viewModel.isLoading || !viewModel.movies.isEmpty
                if viewModel.isLoading { loadingView.startAnimating() } else { loadingView.stopAnimating() }
            }
            .store(in: &cancellables)
    }

    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.search(query: query)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseID, for: indexPath) as! MovieCell
        cell.configure(with: viewModel.movies[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = MovieDetailViewController(movie: viewModel.movies[indexPath.item], watchlist: watchlist)
        navigationController?.pushViewController(detail, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = traitCollection.horizontalSizeClass == .regular ? 4 : 2
        let spacing: CGFloat = 12
        let insets: CGFloat = 40
        let width = (collectionView.bounds.width - insets - spacing * (columns - 1)) / columns
        return CGSize(width: width, height: width * 1.75)
    }
}
