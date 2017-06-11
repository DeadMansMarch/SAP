//
//  main.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//
import Foundation

let PGRMloc = ["SAP_PROGRAMS","/School/Programming/Random/SAP/Programs"];
var Directory = "/School/Programming/Random/SAP/Programs";
var Filename = "";

func switcher(Split:[String])->Bool{
    switch(Split[0]){
        case "help":
            print("Commands:");
            print("\tassemble <filename>.txt : Assemble and output assembly files.");
            print("\texecute <program name>.bin : Execute assembled file.");
            print("\tchangedir <dirname> : Change directory to <dirname>");
            print("\texit : Exit SAP.");
            break;
        case "exit":
            doRun = false;
            return false;
        case "changedir":
            
            guard Split.count > 1 else{
                print("No directory given.");
                return true;
            }
            let Dir = Split[1];
            print("Changing directory to /Documents/\(Dir)");
            Directory = Dir;
            break;
        case "assemble":
            print("Choose assembler :");
            print("\t[1] : Tokenizing Assembler");
            print("\t[2] : Non-Tokenizing Assembler");
            print("Assembler >",terminator:"");
            if let Assembler = Int(readLine() ?? ""){
                guard Split.count > 1 else{
                    print("No file given.");
                    break;
                }
                let File = Split[1];
                switch(Assembler){
                case 1:
                    print("Assembling with file path : \(Directory)/\(File).txt");
                    let Assemble = AssemblerBetter();
                    Assemble.Location = Directory;
                    Assemble.Name = File;
                    Assemble.assemble();
                    print("Assembled using Tokenizing Assembler.");
                    break;
                case 2:
                    break
                default:
                    break;
                }
                
            }else{
                print("Option not recognized.");
            }
            
            break;
        case "execute":
            guard Split.count > 1 else{
                print("No file given.");
                break;
            }
            
            let File = Split[1];
            
            let VM = VirtualMachine();
            VM.loadMem(FileLoc: "\(Directory)/Assembled/\(File)");
            VM.Execute()
            break;
        default:
            break;
    }
    return true;
}

var doRun:Bool = true;
let _ = switcher(Split:["help"])
while (doRun){
    print("SAP>",terminator:"");
    let Input:String = readLine() ?? "";
    let Split = Input.characters.split(separator: " ").map({String($0)});
    
    guard (Split.count > 0) else{
        print("Blank Line");
        continue;
    }
    
    doRun = switcher(Split:Split);
}

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
