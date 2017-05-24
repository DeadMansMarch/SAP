//
//  Debug.swift
//  SAP
//
//  Created by Liam Pierce on 4/10/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

public func fit(_ s:String, _ size:Int, right:Bool = true)->String{
    var result = "";
    let sSize = s.characters.count;
    if sSize == size { return s }
    var count = 0;
    if size < sSize{
        for c in s.characters{
            if count < size { result.append(c) } ;
            count += 1;
        }
        return result;
    }
    result = s;
    var addon = "";
    let num = size - sSize;
    for _ in 0..<num{addon.append(" ");}
    if right{ return result + addon }
    return addon + result;
}

public func fitI(_ i:Int, _ size:Int, right:Bool = false)->String{
    let iAsString = "\(i)"
    let newLength = iAsString.characters.count
    return fit(iAsString,newLength > size ? newLength : size,right:right);
}

extension Dictionary where Value: Equatable {
    func firstKey(forValue val: Value) -> Key? {
        let filter = self.filter{$1 == val}.map {$0.0}
        return filter.isEmpty ? nil : filter[0];
    }
}

extension String{
    func rep(x:String,with:String)->String{
        return self.replacingOccurrences(of: x, with: with, options: NSString.CompareOptions.literal, range:nil)
    }
}

class Debugger{
    let commandListing = VirtualMachine.commandListing;
    let virtualMachine:VirtualMachine;
    
    init(_ with:VirtualMachine){ //This process will assume control of the VM when attached.
        self.virtualMachine = with;
        loadST();
        controller();
    }
    
    func printCommand(_ PGRM:Int, _ Message:String = ""){
        let command = virtualMachine.RAM[PGRM];
        let len = virtualMachine.paramList[command] ?? 2;
        if len > 0, let cmd = commandListing.firstKey(forValue:command){
            let options = virtualMachine.RAM[PGRM + 1 ... PGRM + len];
            print("\(Message)\(cmd)\(options.reduce("",{"\($0) \($1)"}))")
        }else{
            if let cmd = commandListing.firstKey(forValue:command){
                print("\(Message)\(cmd)");
            }
        }
    }
    
    func loadST(){
        print(self.virtualMachine.fName)
        guard let ST = saveFile(withName: self.virtualMachine.fName, FileEnding: ".map").read() else{
            print("Mapping file not processed.");
            return;
        }
        
        let Splits = ST.rep(x:"\t", with: "").rep(x:": ",with:":").trimmingCharacters(in: .whitespaces)
        let Listings = Splits.characters.split(separator: "\n");
        Listings.forEach{
            let LS = $0.split(separator:":").map{String($0)}
            if (LS.count > 1){ self.virtualMachine.st(LS[0],Int(LS[1])!); }
        }
    }
    
    func cmdHelp(){
        print("Debugger Commands:");
        print("Note: <address> can be symbolic or numeric");
        print("\tHelp - Print this menu."); //*
        print("\tsetbk <address> - set breakpoint at <address>");
        print("\trmbk <address> - remove breakpoint at <address>");
        print("\tclrbk - clear all break points");
        print("\tdisbk - disable all break points");
        print("\tenbk - enable all break points");
        print("\tpbk - print all break points");
        print("\tpreg - print the value of all registers"); //*
        print("\tareg - print the value of all registers and special registers"); //*
        print("\twreg <number> <value> - write <value> to register <number>");
        print("\twpc <value> - write <value> to the program counter");
        print("\tpmem <start address> <end address> - print memory from <start address> to <end address>");
        print("\tdeas <start address> <end address> - disassemble program from <start address> to <end address>");
        print("\twmem <address> <value> - change value of memory address <address> to <value>");
        print("\tpst - print symbol table");
        print("\tg - continue program operation");
        print("\ts - single step"); //*
        print("\texit - terminate virtual machine"); //*
    }
    
    func sorter(a:(key:String,value:Int), b:(key:String, value:Int))->Bool{
        return (a.value < b.value);
    }
    
    func addressor(_ Addr:String)->Int{
        if let Mem = Int(Addr){
            return Mem;
        }else{
            return virtualMachine.ST[Addr] ?? -1;
        }
    }
    
    func registrar(_ Addr:String)->Int{
        if let Mem = Int(Addr){
            return Mem;
        }else{
            return Int(String(Addr.characters.dropFirst())) ?? 0
        }
    }
    
    func controller(){
        cmdHelp();
        print("\n -Broken into debugger; Control by command- \n")
        while (true){
            let PGRM = virtualMachine.SpRegisters["PGRM"]!;
            print("Sdb (\(PGRM), \(virtualMachine.RAM[PGRM]))> ",terminator:"")
            if let dbI = readLine(){
                cmdSwitch(dbI:dbI);
            }
        }
    }
    
    func cmdSwitch(dbI:String){
        let split = dbI.characters.split(separator: " ").filter({!$0.isEmpty}).map(String.init)
        guard split.count > 0 else{
            print("Empty line.");
            return;
        }
        switch(split[0]){
        case "exit":
            return;
        case "help":
            cmdHelp();
            break;
        case "pst":
            print("Symbol Table: ")
            virtualMachine.ST.sorted(by:sorter).forEach({
                print("\t\($0.0) : \($0.1)");
            })
            break;
        case "wmem":
            if (split.count >= 3){
                print("Changed.");
                let Mem:Int;
                if let M = Int(split[1]){
                    Mem = M;
                }else{
                    Mem = virtualMachine.ST[split[1]] ?? -1;
                }
                virtualMachine.setMem(Location:Mem,To:Int(split[2])!);
            }
            break;
        case "preg":
            
            for i in 0...9{
                print("r\(i): ",terminator:"");
                print(virtualMachine.Registers[i])
            }
            
            break;
        case "spreg":
            let SP = ["PGRM","CMPR","STCK"]
            SP.forEach({
                print("\($0): ",terminator:"");
                print(virtualMachine.SpRegisters[$0]!)
            });
        case "areg": //Print all registers.
            cmdSwitch(dbI:"spreg")
            cmdSwitch(dbI:"preg")
            break;
        case "s": //Will execute one more command.
            let PGRM = virtualMachine.SpRegisters["PGRM"]!;
            let command = virtualMachine.RAM[PGRM];
            if command == 52{ let _ = virtualMachine.mPC(Amount:0); break }
            let _ = virtualMachine.cmdSwitch(With:command);
            break;
        case "g": //Continue operation.
            return;
        case "nextc":
            printCommand(virtualMachine.SpRegisters["PGRM"]!);
            break;
        case "printmem":
            if split.count == 1{
                print(virtualMachine.RAM.reduce("",{"\($0) \($1)"}))
            }else if split.count == 2{
                print(virtualMachine.RAM[Int(split[1])!]);
            }else{
                print(virtualMachine.RAM[Int(split[1])!...Int(split[2])!].reduce("",{"\($0) \($1)"}))
            }
            break;
        case "wreg":
            virtualMachine.wreg(R:registrar(split[1]),Val:Int(split[2])!)
            break;
        case "wpc":
            virtualMachine.aPC(Amount: Int(split[1])!)
            break;
        case "pmem": //Gives the reader a bit of context. Helpful for debugging.
            let Len = addressor(split[2])
            let PG = virtualMachine.SpRegisters["PGRM"]!;
            print("Current Program Counter : \(PG)");
            for i in addressor(split[1])..<Len{
                print("\(i): ",terminator:"");
                if i == PG{
                    print("[\(virtualMachine.RAM[i])] ");
                }else{
                    print("\(virtualMachine.RAM[i]) ");
                    
                }
            }
            break;
        default:
            print("No such debugger command.");
            break;
        }
    }
    
}
