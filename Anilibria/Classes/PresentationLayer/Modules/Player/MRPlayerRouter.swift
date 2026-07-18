import UIKit

// MARK: - Router

protocol PlayerRoutable: BaseRoutable, BackRoute, ActionSheetRoute, PlaylistItemSelectionRoute, SearchRoute {}

final class PlayerRouter: BaseRouter, PlayerRoutable {}
