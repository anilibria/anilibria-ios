import UIKit

// MARK: - Router

protocol PlayerRoutable: BaseRoutable, BackRoute, ChoiceSheetRoute, PlaylistItemSelectionRoute {}

final class PlayerRouter: BaseRouter, PlayerRoutable {}
