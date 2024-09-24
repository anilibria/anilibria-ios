import UIKit

public final class TorrentView: UIView {
    @IBOutlet private var mainLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!

    private var handler: Action<Torrent>?

    private var torrent: Torrent?

    func setTap(handler: Action<Torrent>?) {
        self.handler = handler
    }

    func configure(_ torrent: Torrent) {
        self.torrent = torrent
        self.mainLabel.text = self.getTitle(from: torrent)
        self.infoLabel.text = self.getInfo(from: torrent)
    }

    private func getTitle(from torrent: Torrent) -> String {
        let dateFormatter = FormatterFactory.date("dd.MM.yyyy HH:mm").create()
        let date = dateFormatter.string(from: torrent.ctime) ?? ""
        return """
               \(torrent.series) [\(torrent.quality)]

               \(L10n.Screen.Series.addedDate) \(date)
               """
    }

    private func getInfo(from torrent: Torrent) -> String {
        let size = round((torrent.size / pow(1024, 3)) * 100) / 100
        return """
               \(size) GB
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
