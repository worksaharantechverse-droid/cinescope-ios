import UIKit

final class MovieCell: UICollectionViewCell {
    static let reuseID = "MovieCell"

    private let poster = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        poster.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }

    private func setup() {
        contentView.backgroundColor = CineTheme.surface()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        poster.contentMode = .scaleAspectFill
        poster.clipsToBounds = true
        poster.backgroundColor = UIColor(red: 0.16, green: 0.12, blue: 0.16, alpha: 1)
        poster.image = UIImage(systemName: "film.stack")?.withRenderingMode(.alwaysTemplate)
        poster.tintColor = CineTheme.accent.withAlphaComponent(0.5)

        titleLabel.font = CineTheme.font(14, weight: .semibold)
        titleLabel.textColor = CineTheme.primaryText()
        titleLabel.numberOfLines = 2

        metaLabel.font = CineTheme.font(11, weight: .medium)
        metaLabel.textColor = CineTheme.secondaryText()

        let stack = UIStackView(arrangedSubviews: [poster, titleLabel, metaLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            poster.heightAnchor.constraint(equalTo: poster.widthAnchor, multiplier: 1.45)
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.trackName
        metaLabel.text = "\(movie.year) · \(movie.genre)"
        accessibilityIdentifier = "movie-cell-\(movie.trackId)"
        guard let url = movie.posterURL else { return }
        imageTask = Task { [weak self] in
            let image = await ImageCache.shared.image(for: url)
            guard !Task.isCancelled, let image else { return }
            self?.poster.image = image
        }
    }
}
