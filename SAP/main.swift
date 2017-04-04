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


var VM = VirtualMachine();

VM.loadMem(FullMem: PGRM);
VM.Execute()
