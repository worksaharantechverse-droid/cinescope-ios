import Foundation
import UIKit

final class ImageCache {
    static let shared = ImageCache()

    private let memory = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    func image(for url: URL) async -> UIImage? {
        let key = NSString(string: url.absoluteString)
        if let cached = memory.object(forKey: key) { return cached }
        if let disk = readDisk(url: url) {
            memory.setObject(disk, forKey: key)
            return disk
        }
        guard let (data, response) = try? await URLSession.shared.data(from: url),
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let image = UIImage(data: data) else { return nil }
        writeDisk(data: data, url: url)
        memory.setObject(image, forKey: key)
        return image
    }

    private func directory() -> URL? {
        try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CineScopeImages", isDirectory: true)
    }

    private func fileURL(for url: URL) -> URL? {
        guard let directory = directory() else { return nil }
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("\(url.absoluteString.hashValue).jpg")
    }

    private func readDisk(url: URL) -> UIImage? {
        guard let fileURL = fileURL(for: url),
              let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    private func writeDisk(data: Data, url: URL) {
        guard let fileURL = fileURL(for: url) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
