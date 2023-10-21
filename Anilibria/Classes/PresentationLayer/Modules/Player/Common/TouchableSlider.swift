//
//  TouchableSlider.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.10.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import UIKit

public final class TouchableSlider: UISlider {
    private var firstLocation: CGPoint?

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }

        self.firstLocation = touch.location(in: self)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)

        if floor(location.x) != floor(self.firstLocation?.x ?? 0) {
            return
        }

        let thumbWidth = self.currentThumbImage?.size.width ?? 0
        let percent = Float((location.x - thumbWidth/2) / (self.frame.width - thumbWidth))
        self.setValue(percent * self.maximumValue, animated: false)
        self.sendActions(for: .touchDown)
        self.sendActions(for: .touchUpInside)
    }
}
