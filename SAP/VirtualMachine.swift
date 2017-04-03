//
//  VirtualMachine.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation


class VirtualMachine{
    //Dis rih here a virtual machene.
    private(set) var AccessMem = [Int](); //'Memory'.
    private(set) var AccessReg = [Int](); //Registers.
    private(set) var SpReg = ["PRGM":0,"CMPR":0,"STCK":0]; //Special Registers.
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        AccessMem = [Int](repeating:0,count:8);
    }
    
}
