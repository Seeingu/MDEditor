//
//  MDTextView+NSTextViewportLayoutControllerDelegate.swift
//  
//
//  Created by seeu on 2022/9/7.
//

import AppKit

extension MDTextView: NSTextViewportLayoutControllerDelegate {
    func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        let overdrawRect = preparedContentRect
        let visibleRect = self.visibleRect
        var minY: CGFloat = 0
        var maxY: CGFloat = 0
        if overdrawRect.intersects(visibleRect) {
                // Use preparedContentRect for vertical overdraw and ensure visibleRect is included at the minimum,
                // the width is always bounds width for proper line wrapping.
            minY = min(overdrawRect.minY, max(visibleRect.minY, 0))
            maxY = max(overdrawRect.maxY, visibleRect.maxY)
        } else {
                // We use visible rect directly if preparedContentRect does not intersect.
                // This can happen if overdraw has not caught up with scrolling yet, such as before the first layout.
            minY = visibleRect.minY
            maxY = visibleRect.maxY
        }
        return CGRect(x: bounds.minX, y: minY, width: bounds.width, height: maxY - minY)
    }

    func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        contentLayer.sublayers = nil
        CATransaction.begin()
    }

    private func animate(_ layer: CALayer, from source: CGPoint, to destination: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = source
        animation.toValue = destination
        animation.duration = 0.3
        layer.add(animation, forKey: nil)
    }

    private func findOrCreateLayer(_ textLayoutFragment: NSTextLayoutFragment) -> (MDTextLayoutFragmentLayer, Bool) {
        if let layer = fragmentLayerMap.object(forKey: textLayoutFragment) as? MDTextLayoutFragmentLayer {
            return (layer, false)
        } else {
            let layer = MDTextLayoutFragmentLayer(layoutFragment: textLayoutFragment, padding: padding)
            fragmentLayerMap.setObject(layer, forKey: textLayoutFragment)
            return (layer, true)
        }
    }

    func textViewportLayoutController(_ controller: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {
        let (layer, layerIsNew) = findOrCreateLayer(textLayoutFragment)
        if !layerIsNew {
            let oldPosition = layer.position
            let oldBounds = layer.bounds
            layer.updateGeometry()
            if oldBounds != layer.bounds {
                layer.setNeedsDisplay()
            }
            if oldPosition != layer.position {
                animate(layer, from: oldPosition, to: layer.position)
            }
        }

        contentLayer.addSublayer(layer)
    }

    func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        CATransaction.commit()
        updateContentSizeIfNeeded()
        adjustViewportOffsetIfNeeded()
        updateSelectionHighlights()
    }
}
