//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

let PGRMloc = ["/SAP/Programs","/School/Programming/Random/SAP/Programs"]

var Program:String = "";
for i in 0..<PGRMloc.count{
    let Loc = "\(PGRMloc[i])/Turing";
    print(Loc)
    let Pgrm = saveFile(withName:Loc);
    if let toLoad = Pgrm.read(){
        Program = toLoad;
        break;
    }
}

let Assemble = Assembler();
Assemble.load(Program:Program);
let PGRM = Assemble.Assemble();
print(PGRM);
print();
var VM = VirtualMachine();

VM.loadMem(FullMem: PGRM);
VM.Execute()
