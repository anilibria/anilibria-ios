import UIKit

// MARK: - Router

protocol PlayerRoutable: BaseRoutable, BackRoute, ActionSheetRoute, PlaylistItemSelectionRoute {}

final class PlayerRouter: BaseRouter, PlayerRoutable {}
