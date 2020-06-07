//
//  HeaderView.swift
//  Corona Data Muncher
//
//  Created by Colin Wilson on 07/06/2020.
//  Copyright © 2020 Colin Wilson. All rights reserved.
//

import Cocoa

class HeaderView: NSView {
    
    override func awakeFromNib() {
        layer?.backgroundColor = NSColor.black.cgColor
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
