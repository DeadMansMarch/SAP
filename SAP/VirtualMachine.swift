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
    let NumOfParamsNeeded = [
        0:0,
        1:1,
        2:1,
        3:1,
        4:2,
        5:2,
        6:2,
        7:2,
        8:2,
        9:2,
        10:2,
        11:3,
        12:2,
        13:2,
        14:2,
        15:2,
        16:2,
        17:2,
        18:2,
        19:2,
        20:2,
        21:2,
        22:2,
        23:2,
        24:2,
        25:2,
        26:2,
        27:2,
        28:1,
        29:2,
        30:2,
        31:2,
        32:2,
        33:2,
        34:2,
        35:2,
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
        47:2,
        48:2,
        49:1,
        50:1,
        51:2,
        52:0,
        53:2,
        54:2,
        55:1,
        56:0,
        57:1
    ];
    private(set) var RAMArray = [Int](); //'Memory'.
    private(set) var RegistersArray = [Int](repeating:0,count:10); //Registers.
    private(set) var SpecialRegisters = ["PGRM":0,"CMPR":0,"STCK":0]; //Special Registers.
    //                                              ^ 0 = less, 1 = equal, 2 = greater.
    
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        RAMArray = [Int](repeating:0,count:L);
    }
    
    func loadMem(FullMem Data:[Int]){
        self.setMemoryLength(Length: 1000); //Set memory length.
        SpecialRegisters["PGRM"] = Data[1];               //Set program counter to initial position.
        for i in 2..<Data.count{
            RAMArray[i-2] = Data[i];        //Fill Memory.
        }
    }
    func checkRegister(_ rNum:Int)->Bool{
        return 0..<10 ~= rNum
    }
    func checkMemoryLocation(_ label:Int)->Bool{
        return 0..<RAMArray.count ~= label
    }
    func Execute(){ //Executes the full program.
        print("Starting program.");
        print("RUN:")
        while true{
            let ProgramCounter = SpecialRegisters["PGRM"]!;
            let Command = RAMArray[ProgramCounter];
            if cmdSwitch(With:Command){
                if ProgramCounter == SpecialRegisters["PGRM"]!{
                    break;
                }
            }else{
                break;
            }
        }
    }
    
    func getValue(for l:Int)->Int{ //Returns contents of memory location in the VM.
        return RAMArray[l];
    }
    
    func movePC_GetParams(Amount:Int)->[Int]{ //Return inputs and move PGRM counter.
        var Options = [Int]();
        let ProgramCounter = SpecialRegisters["PGRM"]!
        guard ProgramCounter <= RAMArray.count else{
            print("OVERFLOW ERROR");
            return [Int]();
        }
        for i in 1...Amount{
            Options.append(getValue(for:ProgramCounter + i));
        }
        SpecialRegisters["PGRM"] = ProgramCounter + Amount + 1;
        return Options;
    }
    
    func cmdSwitch(With c:Int)->Bool{ //Get command from Int.
        if c == 0{
            print("END OF PROGRAM")
            return false;
        }
        guard let NumRAMLocationsInvolved = NumOfParamsNeeded[c] else{
            print("FATAL ERROR: COMMAND NOT RECOGNIZED: \(c) PC: \(SpecialRegisters["PGRM"]!)");
            return false;
        }
        let Paremeters = movePC_GetParams(Amount:NumRAMLocationsInvolved);
        switch(c){
            case 1:
                break;
            case 2:
                break;
            case 6:  //moverr.
                guard checkRegister(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Paremeters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                RegistersArray[Paremeters[1]]=RegistersArray[Paremeters[0]]
                break;
            case 8:  //movemr.
                guard checkRegister(Paremeters[1]) else{
                    print("FATAL ERROR ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                guard checkMemoryLocation(Paremeters[0]) else {
                    print("FATAL ERROR ILLEGAL MEMORY LOCATION: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                RegistersArray[Paremeters[1]]=RAMArray[Paremeters[0]]
                break;
            case 9: //
                break;
            case 12: //addir.
                guard checkRegister(Paremeters[1]) else{
                    print("FATAL ERROR ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                RegistersArray[Paremeters[1]] += Paremeters[0];
                break;
            case 13: //addrr.
                guard checkRegister(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Paremeters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                RegistersArray[Paremeters[1]] = RegistersArray[Paremeters[1]] + RegistersArray[Paremeters[0]];
                break;
            case 28://jmp
                guard checkMemoryLocation(Paremeters[0]) else {
                    print("FATAL ERROR ILLEGAL MEMORY LOCATION: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                SpecialRegisters["PGRM"]=Paremeters[0]
            case 33:
                guard checkRegister(Paremeters[1]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                if Paremeters[0] > RegistersArray[Paremeters[1]]{
                    SpecialRegisters["CMPR"] = 2;
                }else if Paremeters[0] < RegistersArray[Paremeters[1]]{
                    SpecialRegisters["CMPR"] = 0;
                }else{
                    SpecialRegisters["CMPR"] = 1;
                }
            case 34: //cmprr.
                guard checkRegister(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                guard checkRegister(Paremeters[1]) else {
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[1]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                if RegistersArray[Paremeters[0]] > RegistersArray[Paremeters[1]]{
                    SpecialRegisters["CMPR"] = 2;
                }else if RegistersArray[Paremeters[0]] < RegistersArray[Paremeters[1]]{
                    SpecialRegisters["CMPR"] = 0;
                }else{
                    SpecialRegisters["CMPR"] = 1;
                }
                break;
            case 45: //outcr.
                guard checkRegister(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                print(Character(UnicodeScalar(RegistersArray[Paremeters[0]])!));
                break;
            case 49: //printi
                guard checkRegister(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL REGISTER #: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                print(RegistersArray[Paremeters[0]]);
                break;
            case 55: //outs.
                guard checkMemoryLocation(Paremeters[0]) else{
                    print("FATAL ERROR: ILLEGAL MEMORY LOCATION: \(Paremeters[0]) PC: \(SpecialRegisters["PGRM"]!)")
                    break;
                }
                let Str = RAMArray[Paremeters[0] + 1...(Paremeters[0] + 2 + RAMArray[Paremeters[0]])]; //Get the string as an array of ints.
                print(Str.map{String(Character(UnicodeScalar($0)!))}.reduce("",+))
                break;
            case 57: //jumpne
                if (SpecialRegisters["CMPR"]! != 1){ //Not equal.
                    SpecialRegisters["PGRM"] = Paremeters[0] //Set PGRM counter to location in memory : PGRM + 1
                }
                break;
            default:
                print("\(c) : Not found in listings.");
                break;
        }
        return true;
    }
    
}
