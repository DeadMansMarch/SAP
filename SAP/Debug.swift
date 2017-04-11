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

class Debugger{
    let commandListing = VirtualMachine.commandListing;
    let virtualMachine:VirtualMachine;
    
    init(_ with:VirtualMachine){ //This process will assume control of the VM when attached.
        self.virtualMachine = with;
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
    
    func controller(){
        print("\n -Broken into debugger; Control by command- \n")
        while (true){
            print("Input Debugger Command: ")
            if let dbI = readLine(){
                let split = dbI.characters.split(separator: " ").filter({!$0.isEmpty}).map(String.init)
                switch(split[0]){
                    case "exit":
                        return;
                    case "preg":
                        print("|  r0  |  r1  |  r2  |  r3  |  r4  |  r5  |  r6  |  r7  |  r8  |  r9  |");
                        for i in 0...9{
                            print("|\(fitI(virtualMachine.Registers[i],6,right:true))",terminator:"");
                        }
                        print("|")
                        break;
                    case "spreg":
                        let SP = ["PGRM","CMPR","STCK"]
                        SP.forEach({print("|\($0)",terminator:"")});
                        print("|");
                    
                        SP.forEach({print("|\(fitI(virtualMachine.SpRegisters[$0]!,4))",terminator:"")})
                        print("|");
                    case "reg":
                        let SP = ["PGRM","CMPR","STCK"]
                        SP.forEach({print("|\($0)",terminator:"")});
                        print("|");
                        
                        SP.forEach({print("|\(fitI(virtualMachine.SpRegisters[$0]!,4))",terminator:"")})
                        print("|");
                        print("");
                        print("|  r0  |  r1  |  r2  |  r3  |  r4  |  r5  |  r6  |  r7  |  r8  |  r9  |");
                        for i in 0...9{
                            print("|\(fitI(virtualMachine.Registers[i],6,right:true))",terminator:"");
                        }
                        print("|")
                        break;

                    case "stepdown": //Will execute one more command.
                        let PGRM = virtualMachine.SpRegisters["PGRM"]!;
                        let command = virtualMachine.RAM[PGRM];
                        let len = virtualMachine.paramList[command] ?? 2;
                        printCommand(PGRM,"Running: ");
                        if command == 52{ let _ = virtualMachine.mPC(Amount:0); break }
                        virtualMachine.cmdSwitch(With:command);
                        printCommand(virtualMachine.SpRegisters["PGRM"]!,"Next: ");
                        if (virtualMachine.SpRegisters["PGRM"] != PGRM + len + 1){
                            print("Program jumped to memory location : \(virtualMachine.SpRegisters["PGRM"]!)");
                        }
                        break;
                    case "steptocommand": //Will excute until reaching a certain command.
                        while(true){
                            let PGRM = virtualMachine.SpRegisters["PGRM"]!;
                            let command = virtualMachine.RAM[PGRM];
                            let len = virtualMachine.paramList[command] ?? 2;
                            printCommand(PGRM);
                            if commandListing.firstKey(forValue: command) == split[1]{
                                break;
                            }else{
                                virtualMachine.cmdSwitch(With: command);
                            }
                        }
                    case "nextc":
                        printCommand(virtualMachine.SpRegisters["PGRM"]!);
                        break;
                    case "printmem":
                        print(virtualMachine.RAM[Int(split[1])!...Int(split[2])!].reduce("",{"\($0) \($1)"}))
                    case "memloc": //Gives the reader a bit of context. Helpful for debugging.
                        let Len = virtualMachine.RAM.count
                        let PG = virtualMachine.SpRegisters["PGRM"]!;
                        print("Current Program Counter : \(PG)");
                        for i in 0..<Len{
                            if i == PG{
                                print("[\(virtualMachine.RAM[i])] ",terminator:"");
                            }else{
                                print("\(virtualMachine.RAM[i]) ",terminator:"");

                            }
                        }
                        print("")
                        break;
                    default:
                        print("No such debugger command.");
                        break;
                }
            }
        }
    }
    
}
