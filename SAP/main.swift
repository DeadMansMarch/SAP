//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

// I have a save file class we can use for read/write stuff, but for now:
let Program = saveFile(withName:"/School/Programming/Random/SAP/programSave");
print(Program);
let toLoad = Program.read()!;

let Assemble = Assembler();
Assemble.load(Program:toLoad);
let PGRM = Assemble.Assemble();
print(PGRM);
let MemeDoublerProgram = [79,43,0,20,10,26,65,32,80,114,111,103,114,97,109,32,84,111,32,80,114,105,110,116,32,68,111,117,98,108,101,115,12,32,68,111,117,98,108,101,100,32,105,115,32,8,0,8,8,1,9,8,2,0,55,3,45,0,6,8,1,13,8,1,49,8,55,30,49,1,45,0,34,8,9,12,1,8,57,56,0]

print("Assembler working? \(MemeDoublerProgram == PGRM)");
if MemeDoublerProgram != PGRM{
    
}


var VM = VirtualMachine();

VM.loadMem(FullMem: PGRM);
VM.Execute()
