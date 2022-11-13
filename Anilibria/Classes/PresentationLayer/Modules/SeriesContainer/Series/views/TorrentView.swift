import UIKit

public final class TorrentView: UIView {
    @IBOutlet private var mainLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    private let formatter = ByteCountFormatter()

    private var handler: Action<TorrentMetaData>?

    private var torrent: TorrentMetaData?

    func setTap(handler: Action<TorrentMetaData>?) {
        self.handler = handler
    }

    func configure(_ torrent: TorrentMetaData) {
        self.torrent = torrent
        self.mainLabel.text = self.getTitle(from: torrent)
        self.infoLabel.text = self.getInfo(from: torrent)
    }

    private func getTitle(from torrent: TorrentMetaData) -> String {
        let dateFormatter = FormatterFactory.date("dd.MM.yyyy HH:mm").create()
        let date = dateFormatter.string(from: torrent.ctime) ?? ""
        return """
               \(torrent.series) [\(torrent.quality)]

               \(L10n.Screen.Series.addedDate) \(date)
               """
    }

    private func getInfo(from torrent: TorrentMetaData) -> String {
        let size = formatter.string(for: torrent.size) ?? "None"
        return """
               \(size)
               ↑ \(torrent.seeders)
               ↓ \(torrent.leechers)
               ✓ \(torrent.completed)
               """
    }

    @IBAction func tapAction(_ sender: Any) {
        if let value = torrent {
            self.handler?(value)
        }
    }
}
