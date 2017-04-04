//
//  Assembler.swift
//  SAP
//
//  Created by Liam Pierce on 4/4/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

//Crude attempt at an assembler.

class Assembler{
    
    private(set) var program:String? = "";
    
    func load(Program:String){
        self.program = Program;
    }
    
    func Assemble(){
        guard let PGRM = self.program else{
            print("FATAL ASSEMBLY ERROR : No Program Loaded.")
            return;
        }
        
        let Lines = PGRM.characters.split(separator: "\n");
        
    }
}
