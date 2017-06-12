//
//  VirtualMachine.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation


class VirtualMachine{
    
    public static let commandListing = [
        "halt":0,
        "clrr":1,
        "clrx":2,
        "clrm":3,
        "clrb":4,
        "movir":5,
        "movrr":6,
        "movrm":7,
        "movmr":8,
        "movxr":9,
        "movar":10,
        "movb":11,
        "addir":12,
        "addrr":13,
        "addmr":14,
        "addxr":15,
        "subir":16,
        "subrr":17,
        "submr":18,
        "subxr":19,
        "mulir":20,
        "mulrr":21,
        "mulmr":22,
        "mulxr":23,
        "divir":24,
        "divrr":25,
        "divmr":26,
        "divxr":27,
        "jmp":28,
        "sojr":29,
        "sojnz":30,
        "aojz":31,
        "aojnz":32,
        "cmpir":33,
        "cmprr":34,
        "cmpmr":35,
        "jmpn":36,
        "jmpz":37,
        "jmpp":38,
        "jsr":39,
        "ret":40,
        "push":41,
        "pop":42,
        "stackc":43,
        "outci":44,
        "outcr":45,
        "outcx":46,
        "outcb":47,
        "readi":48,
        "printi":49,
        "readc":50,
        "readln":51,
        "brk":52,
        "movrx":53,
        "movxx":54,
        "outs":55,
        "nop":56,
        "jmpne":57]

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
    
    private(set) var STACK = [Int](repeating:0,count:400);
    private(set) var fName:String = "";
    private(set) var ST = [String:Int]()
    private(set) var LST:String = "";
    private(set) var dbkProcess:Debugger? = nil;
    private(set) var RAM = [Int](); //'Memory'.
    private(set) var Registers = [Int](repeating:0,count:10); //Registers.
    private(set) var SpRegisters = ["PGRM":0,"CMPR":0,"STCK":0]; //Special Registers.
    //                                              ^ 0 = less, 1 = equal, 2 = greater.
    //                                              ^ x < y -> true? x - y is neg. 0 is neg, 2 is pos, 1 is eq.
    
    public var breakPointAccrd = [Int](); //The VM needs to know what the breakpoint replaced.
    public var Accord = false;
    
    func verify()->Bool{
        let SP = SpRegisters["STCK"]!;
        return SP < STACK.count && SP >= 0;
    }
    
    func pop()->Int{
        guard verify() else{
            print("STACK UNDERFLOW");
            return 0;
        }
        SpRegisters["STCK"]! -= 1;
        
        return STACK[SpRegisters["STCK"]! + 1];
    }
    
    func push(Val:Int){
        SpRegisters["STCK"]! += 1;
        guard verify() else{
            print("STACK OVERFLOW");
            return;
        }
        STACK[SpRegisters["STCK"]!] = Val;
    }
    
    func st(_ key:String,_ val:Int){
        ST[key] = val;
    }
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        RAM = [Int](repeating:0,count:L);
    }
    
    func loadMem(FullMem Data:[Int]){
        self.setMemoryLength(Length: Data[0]); //Set memory length.
        SpRegisters["PGRM"] = Data[1];               //Set program counter to initial position.
        print(Data.count);
        for i in 0..<Data[0]{
            RAM[i] = Data[i + 2];        //Fill Memory.
        }
    }
    
    func setMem(Location:Int,To:Int){
        RAM[Location] = To;
    }
    
    func setSPREG(Reg:String, Value:Int){
        SpRegisters[Reg] = Value;
    }
    
    func loadMem(FileLoc name:String){
        self.fName = name;
        print("Loading program : fName [\(self.fName)]")
        guard let File = saveFile(withName: name, FileEnding: ".bin").read() else{
            print("File does not exist.");
            return;
        }
        
        loadMem(FullMem: File.characters.dropFirst().dropLast().split(separator: ",").map({String($0).trimmingCharacters(in: .whitespaces)}).map{Int($0)!})
    }
    
    func checkRegister(_ rNum:Int)->Bool{
        let check = 0..<10 ~= rNum
        if (!check){
            print("FATAL ERROR ILLEGAL REGISTER #: \(rNum) PC: \(SpRegisters["PGRM"]!)")
        }
        return check;
    }
    
    func checkMemoryLocation(_ label:Int)->Bool{
        let check = 0..<RAM.count ~= label
        if (!check){
            print("FATAL ERROR ILLEGAL MEMORY LOCATION: \(label) PC: \(SpRegisters["PGRM"]!)")
        }
        return check;
    }
    
    func Execute(){ //Executes the full program.
        print("Starting program.");
        print("RUN:")
        self.dbkProcess = Debugger(self);
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
    
    func aPC(Amount:Int){
        SpRegisters["PGRM"] = Amount;
    }
    
    func wreg(R:Int,Val:Int){
        Registers[R] = Val;
    }
    
    func paramList(With C:Int)->Int{
        if (Accord){
            return self.breakPointAccrd.count - 1; //One command, x inputs, x+1 length.
        }else{
            return self.paramList[C] ?? 2;
        }
    }
    
    func mPC(Amount:Int)->[Int]{ //Return inputs and move PGRM counter.
        var Options = [Int]();
        if (!Accord){
            
            let ProgramCounter = SpRegisters["PGRM"]!
            guard ProgramCounter <= RAM.count else{
                print("OVERFLOW ERROR");
                return [Int]();
            }
            if Amount > 0{
                for i in 1...Amount{
                    Options.append(getValue(for:ProgramCounter + i));
                }
            }
            SpRegisters["PGRM"] = ProgramCounter + Amount + 1;
            return Options;
        }else{
            SpRegisters["PGRM"]! += breakPointAccrd.count - 1;
            Accord = false;
            return (1 ... breakPointAccrd.count - 1).count > 0 ? Array(breakPointAccrd[(1 ... breakPointAccrd.count - 1)]) : Options
        }
    }
    
    func PassRAM(Location:Int)->Int{
        if (Accord && (Location == self.SpRegisters["PGRM"]! || Location < self.SpRegisters["PGRM"]! + breakPointAccrd.count)){
            return breakPointAccrd[Location - self.SpRegisters["PGRM"]!];
        }else{
            return RAM[Location];
        }
    }
    
    func cmdSwitch(With c:Int)->Bool{ //Get command from Int.
        var C = c;
        if (Accord){
            C = breakPointAccrd[0];
        }
        if C == 0{
            print("END OF PROGRAM")
            return false;
        }
        
        guard C > 0 && C <= 57 else{
            print("FATAL ERROR: COMMAND NOT RECOGNIZED");
            return false;
        }
        
        let nParam = paramList(With:C);
        
        let Params = mPC(Amount:nParam);
        Accord = false;
        switch(C){
            case 1: //clrr
                guard checkRegister(Params[0]) else{
                    break;
                }
                Registers[Params[0]] = 0;
                break;
            case 2: //clrx
                guard checkRegister(Params[0]) else{
                    break;
                }
                RAM[Registers[Params[0]]] = 0;
                break;
            case 3: //clrm
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                
                RAM[Params[0]] = 0;
                break;
            case 4: //clrb
                RAM.replaceSubrange(Params[0]...Params[0] + Params[1], with: [Int](repeating:0,count:Params[1]))
                break;
            case 5: //moveir
                Registers[Params[1]] = Params[0];
                guard checkRegister(Params[1]) else {
                    break;
                }
                break;
            case 6:  //moverr.
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                Registers[Params[1]]=Registers[Params[0]]
                break;
            case 7: //moverm
                guard checkRegister(Params[0]) else{
                    break;
                }
            
                RAM[Params[1]] = Registers[Params[0]];
                break;
            case 8:  //movemr.
                guard checkRegister(Params[1]) else{
                    
                    break;
                }
                guard checkMemoryLocation(Params[0]) else {
                    break;
                }
                
                Registers[Params[1]]=RAM[Params[0]]
                break;
            case 9: //movxr
                guard checkRegister(Params[0]) else{
                    break;
                }
                
                guard checkRegister(Params[1]) else{
                    break;
                }
                
                Registers[Params[1]] = RAM[Registers[Params[0]]];
                break;
            case 10: //movar
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                
                guard checkRegister(Params[1]) else{
                    break;
                }
                
                Registers[Params[1]] = Params[0];
                break;
            case 11: //movb
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                
                guard checkMemoryLocation(Params[2]) else{
                    break;
                }
                
                RAM.replaceSubrange(Params[1]...Params[1]+Params[2], with: RAM[Params[0]...Params[0] + Params[2]]);
                break;
            case 12: //addir.
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] += Params[0];
                break;
            case 13: //addrr.
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                Registers[Params[1]] = Registers[Params[1]] + Registers[Params[0]];
                break;
            case 14: //addmr
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] += RAM[Params[0]];
                break;
            case 15: //addxr
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                guard checkMemoryLocation(Registers[Params[0]]) else {
                    break;
                }
                Registers[Params[1]] += RAM[Registers[Params[0]]]
                break;
            case 16: //subir.
                guard checkRegister(Params[1]) else {
                    break;
                }
                Registers[Params[1]] += Params[0];
                break;
            case 17: //subrr.
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                Registers[Params[1]] -= Registers[Params[0]];
                break;
            case 18: //submr
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] -= RAM[Params[0]];
                break;
            case 19: //subxr
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                guard checkMemoryLocation(Registers[Params[0]]) else {
                break;
                }
                Registers[Params[1]] -= RAM[Registers[Params[0]]]
                break;
            case 20: //mulir
                guard checkRegister(Params[1]) else{
                    break;
                }
                
                Registers[Params[1]] *= Params[0];
                break;
            case 21: //mulrr
                guard checkRegister(Params[0]) else{
                    break;
                }
                
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] *= Registers[Params[0]];
                break;
            case 22: //mulmr
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] *= RAM[Params[1]];
                break;
            case 23: //mulxr
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                guard checkMemoryLocation(Registers[Params[0]]) else {
                    break;
                }
                Registers[Params[1]] *= RAM[Registers[Params[0]]]
                break;
            case 24: //divir
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] /= Params[0];
                break;
            case 25: //divrr
                guard checkRegister(Params[0]) else{
                    break;
                }
                
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] /= Registers[Params[0]];
                break;
            case 26: //divmr
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                Registers[Params[1]] /= RAM[Params[1]];
                break;
            case 27: //divxr
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else{
                    break;
                }
                guard checkMemoryLocation(Registers[Params[0]]) else {
                    break;
                }
                Registers[Params[1]] /= RAM[Registers[Params[0]]]
                break;
            case 28:
                SpRegisters["PGRM"] = Params[0];
                break;
            case 29:
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkMemoryLocation(Params[1]) else {
                    break;
                }
                Registers[Params[0]]-=1;
                if Registers[Params[0]]==0{
                    SpRegisters["PGRM"] = Params[1];
                }
                break;
            case 30:
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkMemoryLocation(Params[1]) else {
                    break;
                }
                Registers[Params[0]]-=1;
                if Registers[Params[0]] != 0{
                    SpRegisters["PGRM"] = Params[1];
                }
                break;
            case 31:
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkMemoryLocation(Params[1]) else {
                    break;
                }
                Registers[Params[0]]+=1;
                if Registers[Params[0]]==0{
                    SpRegisters["PGRM"] = Params[1];
                }
                break;
            case 32:
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkMemoryLocation(Params[1]) else {
                    break;
                }
                Registers[Params[0]]+=1;
                if Registers[Params[0]] != 0{
                    SpRegisters["PGRM"] = Params[1];
                }
                break;

            case 33:
                guard checkRegister(Params[1]) else{
                    break;
                }
                if Params[0] > Registers[Params[1]]{
                    SpRegisters["CMPR"] = 2;
                }else if Params[0] < Registers[Params[1]]{
                    SpRegisters["CMPR"] = 0;
                }else{
                    SpRegisters["CMPR"] = 1;
                }
                break;
            case 34: //cmprr.
                guard checkRegister(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                if Registers[Params[0]] > Registers[Params[1]]{
                    SpRegisters["CMPR"] = 2;
                }else if Registers[Params[0]] < Registers[Params[1]]{
                    SpRegisters["CMPR"] = 0;
                }else{
                    SpRegisters["CMPR"] = 1;
                }
                break;
            case 35: //cmpmr
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                if RAM[Params[0]] > Registers[Params[1]]{
                    SpRegisters["CMPR"] = 2;
                }else if RAM[Params[0]] < Registers[Params[1]]{
                    SpRegisters["CMPR"] = 0;
                }else{
                    SpRegisters["CMPR"] = 1;
                }
                break;
            case 36: //jmpn
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                
                if (SpRegisters["CMPR"] == 0){
                    SpRegisters["PGRM"] = Params[0];
                }
                
                break;
            case 37: //jmpz
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                if (SpRegisters["CMPR"] == 1){
                    SpRegisters["PGRM"] = Params[0];
                }
                break;
            case 38: //jmpp
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                if (SpRegisters["CMPR"] == 2){
                    SpRegisters["PGRM"] = Params[0];
                }
                break;
            case 39://jsr
                push(Val:SpRegisters["PGRM"]!);
                
                for i in 0...5{
                    push(Val:Registers[i]);
                }
                break
            case 40: //ret
                push(Val:SpRegisters["PGRM"]!);
                
                for i in (0...5).reversed(){
                    Registers[i] = pop();
                }
                SpRegisters["PGRM"] = pop();
                break
            case 41: //push
                push(Val:Params[1]);
                break;
            case 42: //pop
                Registers[Params[1]] = pop();
                break;
            case 43: //stackc
                break;
            case 44: //outci
                print(String(Character(UnicodeScalar(Params[0])!)),terminator:"");
                break;
            case 45: //outcr.
                guard checkRegister(Params[0]) else{
                    break;
                }
                print(Character(UnicodeScalar(Registers[Params[0]])!),terminator:"");
                break;
            case 46: //outcx
                guard checkMemoryLocation(Params[0]) else {
                    break;
                }
                print(Character(UnicodeScalar(RAM[Params[0]])!),terminator:"");
                break;
            case 47:
                guard checkRegister(Params[0]) else {
                    break;
                }
                guard checkRegister(Params[1]) else {
                    break;
                }
                var temp = ""
                for i in 0..<Params[1]{
                    temp+="\(String(Character(UnicodeScalar(RAM[Params[0]+i])!)))"
                }
                print(temp);
                break;
            //case 48 missing becuase I don't know how stulin wants us to do user input / what the error codes would be
            case 49: //printi
                guard checkRegister(Params[0]) else{
                    break;
                }
                print(Registers[Params[0]],terminator:"");
                break;
            //case 50-51 missing becuase same reason as 48
            case 52: //brk : Attach debugger process to machine.
                self.dbkProcess?.controller();
                break;
            case 53: //movrx
                guard checkRegister(Params[0]) else{
                    break;
                }
                
                guard checkMemoryLocation(Registers[Params[1]]) else{
                    break;
                }
                
                RAM[Registers[Params[1]]] = Registers[Params[0]];
                break;
            case 54: //movxx
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                
                guard checkMemoryLocation(Params[1]) else{
                    break;
                }
                
                RAM[Registers[Params[1]]] = RAM[Registers[Params[0]]]
                break;
            case 55: //outs.
                guard checkMemoryLocation(Params[0]) else{
                    break;
                }
                let Str = RAM[Params[0] + 1...(Params[0] + RAM[Params[0]])]; //Get the string as an array of ints.
                print(Str.map{String(Character(UnicodeScalar($0)!))}.reduce("",+),terminator:"")
                break;
            case 56://nop
                break;
            case 57: //jumpne
                if (SpRegisters["CMPR"]! != 1){ //Not equal.
                    SpRegisters["PGRM"] = Params[0] //Set PGRM counter to location in memory : PGRM + 1
                }
                break;
            default:
                print("\(C) : Not found in listings.");
                break;
        }
        return true;
    }
    
}
