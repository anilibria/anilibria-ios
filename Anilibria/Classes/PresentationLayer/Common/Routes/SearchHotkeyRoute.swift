import UIKit

/// Shared helper for view controllers that want to expose a Cmd+F
/// keyboard shortcut (macOS / iPad with hardware keyboard) that triggers search.
///
/// Adopt this protocol and call `searchHotkeyCommand()` from your `keyCommands`
/// override, providing an action to perform when the shortcut fires.
protocol SearchHotkeyProviding: UIViewController {
    func searchHotkeyCommand(action: Selector) -> UIKeyCommand
}

extension SearchHotkeyProviding {
    func searchHotkeyCommand(action: Selector) -> UIKeyCommand {
        let command = UIKeyCommand(
            input: "f",
            modifierFlags: [.command],
            action: action
        )
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            command.wantsPriorityOverSystemBehavior = true
        }
        command.discoverabilityTitle = L10n.Common.Search.byName
        return command
    }
}
