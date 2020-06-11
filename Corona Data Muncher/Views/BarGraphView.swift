//
//  BarGraphView.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 09/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa

class BarGraphBar {
    let valuex: Double
    let label: String
    let color: NSColor
    let population: Double
    
    func getValue (adjusted: Bool) -> Double  { adjusted ? valuex / population : valuex }
    
    init (label: String, value: Double, color: NSColor, population: Double) {
        self.label = label
        self.valuex = value
        self.color = color
        self.population = population
    }
}

class BarGraphView: NSView {
    
    var maxY: Int = 1000
    var yUnits: Double = 100
    
    
    func initialize (maxY: Int, yUnits: Double, adjusted: Bool) {
        self.maxY = maxY
        self.yUnits = yUnits
    }
    
    var bars: [BarGraphBar]? {
        didSet {
            redraw()
        }
    }
    
    var adjusted: Bool = false {
        didSet {
            if bars != nil {
                redraw ()
            }
        }
    }
    
    private func redraw () {
        var maxValue : Double = 0
        if let bars = bars, bars.count > 0 {
            for bar in bars {
                let value = bar.getValue(adjusted: adjusted)
                if value > maxValue {
                    maxValue = value
                }
            }
        }
        
        if maxValue >= 0 {
            let digits = trunc (log10(maxValue))
            let scale = Int (pow (10, digits))
            
            maxY = scale <= 0 ? 1 : Int ((Double (maxValue) + Double (scale)) / Double (scale)) * scale
            yUnits = Double (scale)
            
            if adjusted {
                yUnits = Double (maxY)
            } else {
                while Double (maxY) / (yUnits/2) <= 10 {
                    let yu = yUnits / 2
                    if yu != Double (Int (yu)) {
                        break
                    }
                    yUnits = yu
                }
                if yUnits == 0 {
                    yUnits = 1
                }
            }
            
            
        } else {
            yUnits = 100
            maxY = 1000
        }
        
        self.needsDisplay = true
    }
    
    private func YDisplayString (y: Double)  -> String{
        if maxY >= 10 {
            return String (Int (y))
        } else {
            return String (y)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let st = YDisplayString (y: Double (maxY)) + "  "
        let nameTextAttributes = [
            NSAttributedString.Key.font: NSFont.labelFont(ofSize: 10),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: NSColor.systemGray]
        let labelTextSize = st.size (withAttributes: nameTextAttributes)

        let path = NSBezierPath ()
        
        let bottomMargin = CGFloat (20)
        let topMargin = CGFloat (0)
        let height = bounds.height - topMargin - bottomMargin
        
        let labelMargin = CGFloat (8)
        let leftMargin = labelTextSize.width + labelMargin
        let rightMargin = CGFloat (0)
        let width = bounds.width - leftMargin - rightMargin
        
        let bottomLeft = CGPoint (x:bounds.origin.x+leftMargin, y:bounds.origin.y+bottomMargin)
        let bottomRight = CGPoint (x: bounds.origin.x+leftMargin+width, y: bounds.origin.y+bottomMargin)

        path.lineWidth = 2
        path.move(to: bottomLeft)
        path.line(to: bottomRight)
        NSColor.systemGray.setStroke()
        path.stroke()

        if !adjusted {
            path.lineWidth = 0

            let labelHeightOffset = labelTextSize.height/2+1
            for gridY in stride(from: yUnits, to: Double (maxY+1), by: yUnits) {
                let y = CGFloat (height-labelHeightOffset) * CGFloat (gridY) / CGFloat (maxY)

                let xp = bottomLeft.x
                let yp = bottomLeft.y + y

                path.move(to: NSPoint (x: xp, y: yp))
                path.line(to: NSPoint (x: xp + width, y: yp))

                let st = YDisplayString(y: gridY)
                let labelTextRect = NSRect (origin: CGPoint (x: xp - labelTextSize.width - labelMargin, y: yp - labelTextSize.height/2),  size: labelTextSize)
                st.draw (in: labelTextRect, withAttributes: nameTextAttributes)

            }
            path.stroke()
        }
        guard let bars = bars else {
            return
        }
        
        let barWidth : CGFloat = (bounds.width - leftMargin - rightMargin) / CGFloat (bars.count)
        let yScale = height / CGFloat (maxY)
        var barOrigin = bottomLeft
        for bar in bars {
            let path = NSBezierPath ()
            path.move(to: barOrigin)
            let topY = barOrigin.y + CGFloat (bar.getValue (adjusted: adjusted)) * yScale
            path.line(to: CGPoint (x: barOrigin.x + barWidth, y: barOrigin.y))
            path.line(to: CGPoint (x: barOrigin.x + barWidth, y: topY))
            path.line(to: CGPoint (x: barOrigin.x, y: topY))
            path.close()

            bar.color.setFill()
            path.fill()
            path.stroke()
            
            let legendTextRect = NSRect (origin: CGPoint (x:barOrigin.x, y:barOrigin.y-bottomMargin), size: CGSize (width: barWidth, height: bottomMargin))
            let st = bar.label
            st.draw (in: legendTextRect, withAttributes: nameTextAttributes)

            barOrigin.x += barWidth

        }
        

    }
    
}
