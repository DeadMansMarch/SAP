//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

let PGRMloc = ["SAP_PROGRAMS","/School/Programming/Random/SAP/Programs"];

var Program:String = "";
var Location:String = "";
for i in 0..<PGRMloc.count{
    let Loc = "\(PGRMloc[i])/Turing";
    let Pgrm = saveFile(withName:Loc);
    if let toLoad = Pgrm.read(){
        Program = toLoad;
        Location = PGRMloc[i];
        break;
    }
}

let Assemble = AssemblerBetter();
//Assemble.load(Program:Program);
Assemble.Location = ""
Assemble.Name = "Turing"
Assemble.assemble()
//print(Location)
//let PGRM = Assemble.Assemble(Location:Location + "/Assembled",Name:"Turing");
//print(PGRM);
//print();
//var VM = VirtualMachine();
//
//VM.loadMem(FullMem: PGRM);
//VM.Execute()
