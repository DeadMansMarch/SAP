//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

let Program = saveFile(withName:"/SAP/SAP/Turing");
print(Program);
let toLoad = Program.read()!;

let Assemble = Assembler();
Assemble.load(Program:toLoad);
let PGRM = Assemble.Assemble();
print(PGRM);
print();
var VM = VirtualMachine();

VM.loadMem(FullMem: PGRM);
VM.Execute()
