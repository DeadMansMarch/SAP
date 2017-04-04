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
    let Options = [
        0:0,
        6:2,
        8:2,
        12:2,
        13:2,
        34:2,
        45:1,
        49:1,
        55:1,
        57:1
    ];
    private(set) var AccessMem = [Int](); //'Memory'.
    private(set) var AccessReg = [Int](repeating:0,count:10); //Registers.
    private(set) var SpReg = ["PGRM":0,"CMPR":0,"STCK":0]; //Special Registers.
    //                                  ^ 0 = less, 1 = equal, 2 = great.
    
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        AccessMem = [Int](repeating:0,count:L);
    }
    
    func loadMem(FullMem Dat:[Int]){
        self.setMemoryLength(Length: Dat[0]); //Set memory length.
        SpReg["PGRM"] = Dat[1];               //Set program counter to initial position.
        
        for i in 0..<Dat[0]{
            AccessMem[i] = Dat[i + 2];        //Fill Memory.
        }
    }
    
    func Execute(){ //Executes the full program.
        print("Starting program.");
        while true{
            let PG = SpReg["PGRM"]!;
            let Command = AccessMem[PG];
            if cmdSwitch(With:Command){
                if PG == SpReg["PGRM"]!{
                    break;
                }
            }else{
                break;
            }
        }
    }
    
    func getValue(for l:Int)->Int{ //Prints out a memory location in the VM.
        return AccessMem[l];
    }
    
    func moveBy(Inputs:Int)->[Int]{ //Return inputs and move PGRM counter.
        var Options = [Int]();
        let PG = SpReg["PGRM"]!
        guard PG <= AccessMem.count else{
            print("OVERFLOW ERROR");
            return [Int]();
        }
        SpReg["PGRM"] = PG + Inputs + 1;
        
        for i in 1...Inputs{
            Options.append(getValue(for:PG + i));
        }
        return Options;
    }
    
    func cmdSwitch(With c:Int)->Bool{ //Get command from Int.
        guard c != 0 else{
            print("Program finished.")
            return false;
        }
        guard let nOpt = Options[c] else{
            print("FATAL ERROR.");
            return false;
        }
        
        let oSet = moveBy(Inputs:nOpt);
        
        switch(c){
            case 1:
                break;
            case 2:
                break;
            case 6:  //moverr.
                AccessReg[oSet[1]] = AccessReg[oSet[0]]
                break;
            case 8:  //movemr.
                AccessReg[oSet[1]] = AccessMem[oSet[0]];
                break;
            case 9: //
                break;
            case 12: //addir.
                AccessReg[oSet[1]] += oSet[0];
                break;
            case 13: //addrr.
                AccessReg[oSet[1]] = AccessReg[oSet[1]] + AccessReg[oSet[0]];
                break;
            case 34: //cmprr.
                if AccessReg[oSet[0]] > AccessReg[oSet[1]]{
                    SpReg["CMPR"] = 2;
                }else if AccessReg[oSet[0]] < AccessReg[oSet[1]]{
                    SpReg["CMPR"] = 0;
                }else{
                    SpReg["CMPR"] = 1;
                }
                break;
            case 45: //outcr.
                print(Character(UnicodeScalar(AccessReg[oSet[0]])!));
                break;
            case 49: //printi
                print(AccessReg[oSet[0]]);
                break;
            case 55: //outs.
                let Str = AccessMem[oSet[0] + 2...oSet[0] + 2 + AccessMem[oSet[0]]]; //Get the string as an array of ints.
                print(Str.map{Character(UnicodeScalar($0)!)}.reduce("",{
                    var S = $0
                    S.append($1);
                    return S;
                }))
                break;
            case 57: //jumpne
                if (SpReg["CMPR"] != 1){ //Not equal.
                    SpReg["PGRM"] = oSet[0] //Set PGRM counter to location in memory : PGRM + 1
                }
                break;
            default:
                print("\(c) : Not found in listings.");
                break;
        }
        return true;
    }
    
}
