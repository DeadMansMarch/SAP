//
//  Assembler.swift
//  SAP
//
//  Created by Liam Pierce on 4/4/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

//Crude attempt at an assembler.

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

class Assembler{
    let commandListing = VirtualMachine.commandListing;
    
    private(set) var mapping:[String:Int] = [:]; // Pointer mappings
    private(set) var mapTo:[String:[Int]] = [:]; // Mapping locations
    private(set) var program:String? = "";       // Program data from load() call.
    
    static func getASCI(Char:Character)->Int{
        let S = String(Char).unicodeScalars;
        return Int(S[S.startIndex].value);
    }
    
    func split(_ spt:String, By cr:Character)->[String.CharacterView]{
        return spt.characters.split(separator: cr);
    }
    
    
    func load(Program:String){
        self.program = Program;
    }
    
    func Assemble(Location:String,Name:String)->[Int]{
        guard let PGRM = program else{
            print("Program not loaded.");
            return [Int]()
        }
        
        var BIN = [Int]();
        let FullLocation = "\(Location)/\(Name)";                               //Location of all assembler files.
        let Mapping = saveFile(withName:FullLocation,FileEnding:".map");        //
        let Binaries = saveFile(withName:FullLocation,FileEnding:".bin");       //
        let Associations = saveFile(withName:FullLocation,FileEnding:".lst");
        
        let Lines = split(PGRM, By:"\n").map{String($0)};
        var AssociatedLines = [(String,String)]();
        var START:String = "NOSTART";
       
        
        for Line in Lines { //Go through each line.
            let ColonBreaker = Line.characters.split(separator: ":")
            let CInd = ColonBreaker.count - 1;
            let MemoryLocation = BIN.count;
            guard ColonBreaker.count <= 2 else{
                print("Assebler error. Too many colons.");
                return [Int]()
            }
            var lineData = "\(BIN.count):"
            let Options = String(ColonBreaker[CInd]).characters.split(separator: " ")
                                                    .filter({!$0.isEmpty})
                                                    .map{String($0)};
            
            let Command = (Options.count > 0) ? Options[0] : "";
            
            if let cmdInt = commandListing[Command]{
                BIN.append(cmdInt);
                lineData += " \(cmdInt)"; //if we got a number here, put it next
                if Options.count > 1{
                    for i in 1...Options.count - 1{ //For each option.
                        if let asInt = Int(Options[i]){
                            BIN.append(asInt)
                            lineData += " \(asInt)";
                        }else if Options[i].characters.first == "r" && Options[i].characters.count == 2{
                            BIN.append(Int(String(Options[i].characters.dropFirst()))!);
                            lineData += " \(String(Options[i].characters.dropFirst()))"
                        }else if Options[i].characters.first == "#" && i >= 1{
                            BIN.append(Int(String(Options[i].characters.dropFirst()))!);
                            lineData += " \(String(Options[i].characters.dropFirst()))"
                        }else if Options[i].characters.first == ";"{
                            break;
                        }else{
                            let LOW = Options[i].lowercased()
                            if mapTo[LOW] != nil{
                                mapTo[LOW]!.append(BIN.count);
                            }else{
                                mapTo[LOW] = [BIN.count];
                            }
                            lineData += " #\(BIN.count)" // append a place holder to be replaced by real pointer
                            BIN.append(0); //Append a placeholder to be replaced by the pointer on 2nd pass.
                        }
                    }
                }
            
                if CInd > 0{
                    mapping[String(ColonBreaker[0]).lowercased()] = MemoryLocation;
                }
            }else{
                switch(Command){
                    case ".Integer":
                        guard Options.count > 1 else{
                            print("Error : .Integer takes at least 1 option.");
                            break;
                        }
                        BIN.append(Int(String(Options[1].characters.dropFirst()))!)
                        lineData += "\(String(Options[1].characters.dropFirst()))"
                        break;
                    case ".String":
                        guard Options.count > 1 else{
                            print("Error : .String takes at least 1 option.");
                            return [Int]();
                        }
                        
                        let QSplit = Line.characters.split(separator: "\"");
                        
                        guard QSplit.count >= 2 else{
                            print("Syntax error: .String call without quotations.");
                            return [Int]();
                        }
                        
                        let STR = QSplit[1]; //"first of string" "part of quote" "end quote, blank."
                        BIN.append(Int(STR.count));
                        lineData += " \(STR.count)"
                        STR.map(Assembler.getASCI)
                            .forEach({BIN.append($0); lineData += " \($0)";});
                        break;
                    case ".Character":
                        let QSplit = Line.characters.split(separator: "\'");
                        guard QSplit.count >= 2 else{
                            print("Syntax error: .String call without quotations.");
                            return [Int]();
                        }
                        BIN.append(Assembler.getASCI(Char:QSplit[1].first!));
                        lineData += " \((Assembler.getASCI(Char:QSplit[1].first!)))"
                    
                    case ".Tuple":
                        print(Options)
                        guard Options.count >= 5 else{
                            print("Tuple length invalid.");
                            return [Int]();
                        }
                        guard let InState = Int(String(Options[1])) else{
                            print("InState is not a valid number.");
                            return [Int]();
                        }
                        
                        let InChar = Assembler.getASCI(Char:Options[2].characters.first!)
                        
                        guard let OutState = Int(String(Options[3])) else{
                            print("OutState is not a valid number.")
                            return [Int]();
                        }
                        
                        let OutChar = Assembler.getASCI(Char:Options[4].characters.first!)
                        guard Options[5]=="r" || Options[5]=="l" else {
                            print("Direction is not \'l\' or \'r\'")
                            return [Int]();
                        }
                        let Dir = (String(Options[5]) == "l") ? -1 : 1; //If not l, it will be r.
                        
                        BIN.append(InState); //Input State
                        BIN.append(InChar); //InChar
                        BIN.append(OutState); //OutState
                        BIN.append(OutChar); //OutChar
                        BIN.append(Dir) //OutDir;
                        lineData += " \(InState) \(InChar) \(OutState) \(OutChar) \(Dir)"
                        break;
                    case ".Start":
                        print("Start established at location: \(Options[1].lowercased()).")
                        START = Options[1].lowercased();
                        break;
                    case ".end":
                        print("Program assembled.")
                        break;
                    case "": //Empty line.
                        break;
                    default:
                        if (Command.characters.first != ";"){
                            print("This command did not exist. \(Command)");
                        }
                        break;
                }
                
                if CInd > 0{
                    mapping[String(ColonBreaker[0]).lowercased()] = MemoryLocation;
                }
            }
            AssociatedLines.append((lineData,Line));
        }
        print("\(Mapping.write(Data:"Full Maping Table: ") ?? "No error in writing mapping file")");
        var pointerFile = [Int:String]();
        for (k,v) in mapping{
            if let local = mapTo[k]{
                for location in local {
                    BIN[location] = v;
                }
                pointerFile[v] = k;
            }else if START != k{
                print("Pointer not used : \(k)");
            }
        }
        Associations.write(Data: "")
        for (data,line) in AssociatedLines{
            var tempLine = "";
            if data.range(of:"#") == nil{
                tempLine += fit(data,20);
            } else {
                var modifiedLine = ""
                for p in data.characters.split(separator: " "){
                    if p[p.startIndex] != "#" {
                        modifiedLine += "\( String(p)) ";
                    } else {
                        modifiedLine += "\(BIN[Int(String(p.dropFirst()))!]) ";
                    }
                }
                tempLine += fit(modifiedLine,20);
            }
            tempLine += fit(line,80);
            Associations.append(Data:tempLine)
        }
        let _ = pointerFile.keys.sorted().map{($0,pointerFile[$0])}.forEach({
            Mapping.append(Data:"\t\($0.1!): \($0.0)");
        })
        
        BIN.insert(BIN.count, at: 0);
        BIN.insert(mapping[START] ?? 0,at:1);
        print("\(Binaries.write(Data:BIN.description) ?? "No error in writing data file")");
        return BIN;
    }
}










