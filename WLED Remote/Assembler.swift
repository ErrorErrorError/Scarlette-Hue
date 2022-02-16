//
//  Assembler.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/15/22.
//

import Foundation

protocol Assembler: AnyObject,
                    GatewaysAssembler,
                    AppAssembler,
                    DevicesAssembler,
                    DiscoverDeviceAssembler{
    
}

final class DefaultAssembler: Assembler {
    
}
