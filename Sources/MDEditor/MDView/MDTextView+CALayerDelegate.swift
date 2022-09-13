//
//  View+CALayerDelegate.swift
//  
//
//  Created by seeu on 2022/9/7.
//

import QuartzCore

#if os(macOS)
extension MDTextView: CALayerDelegate {
    /// layer relayout
    func layoutSublayers(of layer: CALayer) {
        assert(layer == self.layer)
        textLayoutManager.textViewportLayoutController.layoutViewport()
        updateContentSizeIfNeeded()
    }
}
#else
extension MDTextView {
    override func layoutSublayers(of layer: CALayer) {
        assert(layer == self.layer)
        textLayoutManager.textViewportLayoutController.layoutViewport()
        updateContentSizeIfNeeded()
    }

}

#endif
