//
//  AssemblerBetter.swift
//  SAP
//
//  Created by Charlie Mirabile on 5/8/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation
enum TokenType{
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
struct Tuple : CustomStringConvertible{
    let CS:Int
    let IC:Int
    let NS:Int
    let OC:Int
    let DR:Int
    init?(_ s:String){
        let split = s.characters.split{$0==" "||$0=="\t"}.map{String($0)}
        guard split.count == 5 else {
            return nil
        }
        guard let CS = Int(split[0]) else {
            return nil
        }
        guard split[1].characters.count == 1 else {
            return nil
        }
        guard let NS = Int(split[2]) else {
            return nil
        }
        guard split[3].characters.count == 1 else {
            return nil
        }
        guard split[4].lowercased()=="r" || split[4].lowercased()=="l" else {
            return nil
        }
        self.CS = CS
        self.IC = Int(split[1][split[1].startIndex].unicodeScalarCodePoint())
        self.NS = NS
        self.OC = Int(split[3][split[1].startIndex].unicodeScalarCodePoint())
        self.DR = split[4]=="r" ? 1 : -1
    }
    var description: String{
        return "|\(CS)|\(IC)|\(NS)|\(OC)|\(DR)|"
    }
}
struct Token : CustomStringConvertible{
    let type:TokenType
    let intValue:Int?
    let stringValue:String?
    let tupleValue:Tuple?
    init(type:TokenType){
        self.type=type
        self.intValue=nil
        self.stringValue=nil
        self.tupleValue=nil
    }
    init(type:TokenType,intValue:Int?){
        self.type=type
        self.intValue=intValue
        self.stringValue=nil
        self.tupleValue=nil
    }
    init(type:TokenType,stringValue:String?){
        self.type=type
        self.intValue=nil
        self.stringValue=stringValue
        self.tupleValue=nil
    }
    init(type:TokenType,tupleValue:Tuple?){
        self.type=type
        self.intValue=nil
        self.stringValue=nil
        self.tupleValue=tupleValue
    }
    var description: String{
        return "|\(type):\(intValue),\(stringValue),\(tupleValue)|"
    }
}
class AssemblerBetter{
    let commandListing = VirtualMachine.commandListing;
    private(set) var pointers:[String:Int] = [:];
    private(set) var program:String? = "";
    func getASCI(Char:Character)->Int{
        let S = String(Char).unicodeScalars;
        return Int(S[S.startIndex].value);
    }
    
    func load(Program:String){
        self.program = Program;
    }
    func assemble(){
        guard let realP = program else {
            print("Assembly Failed, No program Loaded")
            return
        }
        let lines = realP.characters.split{$0=="\n"||$0=="\r"}.map{String($0)}
        let tokens = lines.map{tokenLine($0)}
        for tl in tokens {
            print(tl)
        }
    }
    private func tokenLine(_ line:String)->[Token]{
        if line == "" {return []}
        if line.characters.first == ";" {return []}
        
        let commentSplit = line.characters.split{$0==";"}.map{String($0)}
        
        let labelSplit = commentSplit[0].characters.split{$0==":"}.map{String($0)}
        
        if labelSplit.count == 1{
            let tokenStrings = labelSplit[0].characters.split{$0==" "||$0=="\t"}.map{String($0)}
            var tokens:[Token] = Array()
            tokenIterator: for i in 0..<tokenStrings.count{ //iterate tokenStrings
                let token = tokenize(tokenStrings[i]) //make a token for each one
                tokens.append(token) // put on end of array
                if token.type == .Directive { //however, if the one we just put on was a directive
                    if token.stringValue == Optional("Tuple") || token.stringValue == Optional("String"){ // and it was for a string or tuple
                        tokens.append(tokenize(String(tokenStrings[i+1..<tokenStrings.count].reduce(""){"\($0) "+$1}.characters.dropFirst()))) // mash together the
                        break tokenIterator
                    }
                }
            }
            return tokens
        }
        if labelSplit.count == 2{
            let label = Token(type:.LabelDefinition,stringValue:labelSplit[0])
            
            let tokenStrings = labelSplit[1].characters.split{$0==" "||$0=="\t"}.map{String($0)}
            
            var tokens:[Token] = [label] //initialize array with just the label
            
            tokenIterator: for i in 0..<tokenStrings.count{ //iterate tokenStrings
                let token = tokenize(tokenStrings[i]) //make a token for each one
                tokens.append(token) // put on end of array
                if token.type == .Directive { //however, if the one we just put on was a directive
                    if token.stringValue == Optional("Tuple") || token.stringValue == Optional("String"){ // and it was for a string or tuple
                        tokens.append(tokenize(String(tokenStrings[i+1..<tokenStrings.count].reduce(""){$0+" \($1)"}.characters.dropLast()))) // mash together the remaining pieces of line and make token
                        break tokenIterator
                    }
                }
            }
            return tokens
            
        }
        return [Token(type:.BadToken,stringValue:line)]
    }
    private func tokenize(_ tokenString:String)->Token{
        if commandListing.keys.contains(tokenString){
            return Token(type:.Instruction,intValue:commandListing[tokenString]!)
        }
        if tokenString.characters.first == "#" {
            return Token(type:.ImmediateInteger,intValue:Int(String(tokenString.characters.dropFirst())))
        }
        if tokenString.characters.first == "\\" && tokenString.characters.last=="\\" {
            return Token(type:.ImmediateTuple,tupleValue:Tuple(String(tokenString.characters.dropFirst().dropLast())))
        }
        if tokenString.characters.first == "\"" && tokenString.characters.last=="\"" {
            return Token(type:.ImmediateString,stringValue:String(tokenString.characters.dropFirst().dropLast()))
        }
        if tokenString.characters.first == "." {
            return Token(type:.Directive,stringValue:String(tokenString.characters.dropFirst()))
        }
        
        if tokenString.characters.first == "r" {
            if let reg = Int(String(tokenString.characters.dropFirst())){
                return Token(type:.Register,intValue:reg)
            }
        }
        return Token(type:.Label,stringValue:tokenString)
    }
}
