//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

// I have a save file class we can use for read/write stuff, but for now:
let MemeDoublerProgram = [79,43,0,30,10,26,65,32,80,114,111,103,114,97,109,32,84,111,32,80,114,105,110,116,32,68,111,117,98,108,101,115,12,32,68,111,117,98,108,101,100,32,105,115,32,8,0,8,8,1,9,8,2,0,55,3,45,0,6,8,1,13,8,1,49,8,55,30,49,1,45,0,34,8,9,12,1,8,57,56,0]
let shitProgram = [58, 50, 45, 84, 104, 101, 32, 77, 105, 116, 111, 99, 104, 111, 110, 100, 114, 105, 97, 32, 73, 115, 32, 116, 104, 101, 32, 80, 111, 119, 101, 114, 104, 111, 117, 115, 101, 32, 111, 102, 32, 116, 104, 101, 32, 67, 101, 108, 108, 10, 55, 0, 33, 10, 0, 12, 1, 0, 57, 48]
//print(shitProgram.count)
//print(MemeDoublerProgram.count)
//print("The Mitochondria Is the Powerhouse of the Cell\n".characters.map{String($0).unicodeScalars}.map{$0[$0.startIndex].value})
//print("\("The Mitochondria Is the Powerhouse of the Cell\n".characters.count)\n\n\n\n")
//print(MemeDoublerProgram.count);
var VM = VirtualMachine();

VM.loadMem(FullMem: shitProgram);
VM.Execute()
