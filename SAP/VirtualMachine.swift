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

    let paramList = [
        0:0,
        1:1,
        2:1,
        3:1,
        11:3,
        28:1,
        36:1,
        37:1,
        38:1,
        39:1,
        40:0,
        41:1,
        42:1,
        43:1,
        44:1,
        45:1,
        46:1,
        49:1,
        50:1,
        52:0,
        55:1,
        56:0,
        57:1]
    
    private(set) var RAM = [Int](); //'Memory'.
    private(set) var Registers = [Int](repeating:0,count:10); //Registers.
    private(set) var SpRegisters = ["PGRM":0,"CMPR":0,"STCK":0]; //Special Registers.
    //                                              ^ 0 = less, 1 = equal, 2 = greater.
    
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        RAM = [Int](repeating:0,count:L);
    }
    
    func loadMem(FullMem Data:[Int]){
        self.setMemoryLength(Length: Data[0]); //Set memory length.
        SpRegisters["PGRM"] = Data[1];               //Set program counter to initial position.
        
        for i in 0..<Data[0]{
            RAM[i] = Data[i + 2];        //Fill Memory.
        }
    }
    
    func checkRegister(_ rNum:Int)->Bool{
        return 0..<10 ~= rNum
    }
    
    func checkMemoryLocation(_ label:Int)->Bool{
        return 0..<RAM.count ~= label
    }
    
    func Execute(){ //Executes the full program.
        print("Starting program.");
        print("RUN:")
        while true{
            let ProgramCounter = SpRegisters["PGRM"]!;
            let Command = RAM[ProgramCounter];
            if cmdSwitch(With:Command){
                if ProgramCounter == SpRegisters["PGRM"]!{
                    break;
                }
            }else{
                break;
            }
        }
    }
    
    func getValue(for l:Int)->Int{ //Returns contents of memory location in the VM.
        return RAM[l];
    }
    
    func mPC(Amount:Int)->[Int]{ //Return inputs and move PGRM counter.
        var Options = [Int]();
        let ProgramCounter = SpRegisters["PGRM"]!
        guard ProgramCounter <= RAM.count else{
            print("OVERFLOW ERROR");
            return [Int]();
        }
        for i in 1...Amount{
            Options.append(getValue(for:ProgramCounter + i));
        }
        SpRegisters["PGRM"] = ProgramCounter + Amount + 1;
        return Options;
    }
    
    func cmdSwitch(With c:Int)->Bool{ //Get command from Int.
        if c == 0{
            print("END OF PROGRAM")
            return false;
        }
        
        guard c > 0 && c <= 57 else{
            print("FATAL ERROR: COMMAND NOT RECOGNIZED");
            return false;
        }
        
        let nParam = paramList[c] || 2;
        
        let Parameters = mPC(Amount:nParam);
        switch(c){
            case 1:
                break;
            case 2:
                break;
            case 5: //moveir
                Registers[Parameters[1]] = Parameters[0];
                guard checkRegister(Parameters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                break;
            case 6:  //moverr.
                guard checkRegister(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Parameters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                Registers[Parameters[1]]=Registers[Parameters[0]]
                break;
            case 8:  //movemr.
                guard checkRegister(Parameters[1]) else{
                    print("FATAL ERROR ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                guard checkMemoryLocation(Parameters[0]) else {
                    print("FATAL ERROR ILLEGAL MEMORY LOCATION: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                Registers[Parameters[1]]=RAM[Parameters[0]]
                break;
            case 9: //
                break;
            case 12: //addir.
                guard checkRegister(Parameters[1]) else{
                    print("FATAL ERROR ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                Registers[Parameters[1]] += Parameters[0];
                break;
            case 13: //addrr.
                guard checkRegister(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Parameters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                Registers[Parameters[1]] = Registers[Parameters[1]] + Registers[Parameters[0]];
                break;
            case 34: //cmprr.
                guard checkRegister(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Parameters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[1]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                if Registers[Parameters[0]] > Registers[Parameters[1]]{
                    SpRegisters["CMPR"] = 2;
                }else if Registers[Parameters[0]] < Registers[Parameters[1]]{
                    SpRegisters["CMPR"] = 0;
                }else{
                    SpRegisters["CMPR"] = 1;
                }
                break;
            case 45: //outcr.
                guard checkRegister(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                print(Character(UnicodeScalar(Registers[Parameters[0]])!),terminator:"");
                break;
            case 49: //printi
                guard checkRegister(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                print(Registers[Parameters[0]],terminator:"");
                break;
            case 55: //outs.
                guard checkMemoryLocation(Parameters[0]) else{
                    print("FATAL ERROR: ILLEGAL MEMORY LOCATION: \(Parameters[0]) PC: \(SpRegisters["PGRM"]!)")
                    break;
                }
                let Str = RAM[Parameters[0] + 1...(Parameters[0] + 2 + RAM[Parameters[0]])]; //Get the string as an array of ints.
                print(Str.map{String(Character(UnicodeScalar($0)!))}.reduce("",+),terminator:"")
                break;
            case 57: //jumpne
                if (SpRegisters["CMPR"]! != 1){ //Not equal.
                    SpRegisters["PGRM"] = Parameters[0] //Set PGRM counter to location in memory : PGRM + 1
                }
                break;
            default:
                print("\(c) : Not found in listings.");
                break;
        }
        return true;
    }
    
}
