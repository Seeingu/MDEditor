//
//  MDTextLayoutFragmentLayer.swift
//  
//
//  Created by seeu on 2022/9/6.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

class MDTextLayoutFragmentLayer: MDBaseLayer {
    var layoutFragment: NSTextLayoutFragment!
    var padding: CGFloat

    func updateGeometry() {
        bounds = layoutFragment.renderingSurfaceBounds

        var typographicBounds = layoutFragment.layoutFragmentFrame
        typographicBounds.origin = .zero
        bounds = bounds.union(typographicBounds)
        // The (0, 0) point in layer space should be the anchor point.
        anchorPoint = CGPoint(x: -bounds.origin.x / bounds.size.width, y: -bounds.origin.y / bounds.size.height)
        position = layoutFragment.layoutFragmentFrame.origin
        position.x += padding
    }

    init(layoutFragment: NSTextLayoutFragment, padding: CGFloat) {
        self.layoutFragment = layoutFragment
        self.padding = padding
        super.init()
        contentsScale = 2
        updateGeometry()
        setNeedsDisplay()
    }

    override init(layer: Any) {
        let tlfLayer = layer as! MDTextLayoutFragmentLayer
        layoutFragment = tlfLayer.layoutFragment
        padding = tlfLayer.padding
        super.init(layer: layer)
        updateGeometry()
        setNeedsDisplay()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(in ctx: CGContext) {
        layoutFragment.draw(at: .zero, in: ctx)
    }
}
