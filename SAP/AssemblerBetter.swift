//
//  AssemblerBetter.swift
//  SAP
//
//  Created by Charlie Mirabile on 5/8/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//
import Foundation

public enum TokenType{
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

public enum Instructions:Int{
    case halt = 0
    case clrr = 1
    case clrx = 2
    case clrm = 3
    case clrb = 4
    case movir = 5
    case movrr = 6
    case movrm = 7
    case movmr = 8
    case movxr = 9
    case movar = 10
    case movb = 11
    case addir = 12
    case addrr = 13
    case addmr = 14
    case addxr = 15
    case subir = 16
    case subrr = 17
    case submr = 18
    case subxr = 19
    case mulir = 20
    case mulrr = 21
    case mulmr = 22
    case mulxr = 23
    case divir = 24
    case divrr = 25
    case divmr = 26
    case divxr = 27
    case jmp = 28
    case sojr = 29
    case sojnz = 30
    case aojz = 31
    case aojnz = 32
    case cmpir = 33
    case cmprr = 34
    case cmpmr = 35
    case jmpn = 36
    case jmpz = 37
    case jmpp = 38
    case jsr = 39
    case ret = 40
    case push = 41
    case pop = 42
    case stackc = 43
    case outci = 44
    case outcr = 45
    case outcx = 46
    case outcb = 47
    case readi = 48
    case printi = 49
    case readc = 50
    case readln = 51
    case brk = 52
    case movrx = 53
    case movxx = 54
    case outs = 55
    case nop = 56
    case jmpne = 57
}
let commands = [
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
public let commandInputs = [
    0:[],
    1:[TokenType.Register],
    2:[TokenType.Register],
    3:[TokenType.Label],
    4:[TokenType.Register,TokenType.Register],
    5:[TokenType.Register,TokenType.ImmediateInteger],
    6:[TokenType.Register,TokenType.Register],
    7:[TokenType.Register,TokenType.Label],
    8:[TokenType.Label,TokenType.Register],
    9:[TokenType.Register,TokenType.Register],
    10:[TokenType.Label,TokenType.Register],
    11:[TokenType.Register,TokenType.Register,TokenType.Register],
    12:[TokenType.ImmediateInteger,TokenType.Register],
    13:[TokenType.Register,TokenType.Register],
    14:[TokenType.Label,TokenType.Register],
    15:[TokenType.Register,TokenType.Register],
    16:[TokenType.ImmediateInteger,TokenType.Register],
    17:[TokenType.Register,TokenType.Register],
    18:[TokenType.Label,TokenType.Register],
    19:[TokenType.Register,TokenType.Register],
    20:[TokenType.ImmediateInteger,TokenType.Register],
    21:[TokenType.Register,TokenType.Register],
    22:[TokenType.Label,TokenType.Register],
    23:[TokenType.Register,TokenType.Register],
    24:[TokenType.ImmediateInteger,TokenType.Register],
    25:[TokenType.Register,TokenType.Register],
    26:[TokenType.Label,TokenType.Register],
    27:[TokenType.Register,TokenType.Register],
    28:[TokenType.Label],
    29:[TokenType.Register,TokenType.Label],
    30:[TokenType.Register,TokenType.Label],
    31:[TokenType.Register,TokenType.Label],
    32:[TokenType.Register,TokenType.Label],
    33:[TokenType.ImmediateInteger,TokenType.Register],
    34:[TokenType.Register,TokenType.Register],
    35:[TokenType.Label,TokenType.Register],
    36:[TokenType.Label],
    37:[TokenType.Label],
    38:[TokenType.Label],
    39:[TokenType.Label],
    40:[],
    41:[TokenType.Register],
    42:[TokenType.Register],
    43:[TokenType.Register],
    44:[TokenType.ImmediateInteger],
    45:[TokenType.Register],
    46:[TokenType.Register],
    47:[TokenType.Register,TokenType.Register],
    48:[TokenType.Register],
    49:[TokenType.Register],
    50:[TokenType.Register],
    51:[],
    52:[],
    53:[TokenType.Register,TokenType.Register],
    54:[TokenType.Register,TokenType.Register],
    55:[TokenType.Label],
    56:[],
    57:[TokenType.Label]
]

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
    private let commandListing = VirtualMachine.commandListing;
    var Location:String?
    var Name:String?
    private func getASCI(Char:Character)->Int{
        let S = String(Char).unicodeScalars;
        return Int(S[S.startIndex].value);
    }
    func assemble(){
        if Location == nil || Name == nil {
            print("Cannot assemble: no program available")
            return
        }
        let FullLocation = "\(Location!)/\(Name!)";
        let Program = saveFile(withName:FullLocation,FileEnding:".txt");        //Location of all assembler files.
        let Mapping = saveFile(withName:FullLocation,FileEnding:".map");        //
        let Binaries = saveFile(withName:FullLocation,FileEnding:".bin");       //
        let Associations = saveFile(withName:FullLocation,FileEnding:".lst");   //
        guard let program = Program.read() else {
            print("Cannot assemble: cannot access program")
            return
        }
        let stringLines = program.characters.split{$0=="\n"||$0=="\r"}.map{String($0)}
        let tokenizedLines = stringLines.map{tokenLine($0)}
        tokenizedLines.map{print($0)}
        var error = false;
        Associations.write(Data:"");
        errorCheck: for i in 0..<tokenizedLines.count {
            var message = ""
            let tokenizedLine = tokenizedLines[i]
            if tokenizedLine.isEmpty {
                continue errorCheck
            }
            if !(tokenizedLine[0].type == .LabelDefinition || tokenizedLine[0].type == .Instruction || tokenizedLine[0].type == .Directive) {
                error = true
                message += "Illegal Line start, line must begin with Label Instruction or Directive|"
            }
            tokenChecking: for i in 0..<tokenizedLine.count{
                let token = tokenizedLine[i]
                if token.type == .Instruction{
                    if let inst = token.intValue{
                        let params = commandInputs[inst]!
                        checkParams: for j in 0..<params.count{
                            guard i+j+1 < tokenizedLine.count else{
                                error = true
                                message += "Missing parameter for instruction|"
                                break checkParams
                            }
                            if tokenizedLine[i+j+1].type != params[j]{
                                error = true
                                message += "Incorrect parameter type|"
                            }
                        }
                    } else {
                        error = true
                        message += "Bad Instruction|"
                    }
                }
                if token.type == .BadToken{
                    error = true
                    message += "Bad Token Found "
                }
                goodDirective: if token.type == .Directive{
                    guard let type = token.stringValue else{
                        error = true
                        message += "Bad Directive Found|"
                        break goodDirective
                    }
                    let validTypes = ["integer","string","tuple","start","end"]
                    guard validTypes.contains(type) else {
                        error = true
                        message += "Illegal Directive Type|"
                        break goodDirective
                    }
                }
                if token.type == .ImmediateInteger {
                    if token.intValue == nil {
                        error = true
                        message += "Bad Immediate Integer|"
                    }
                }
                if token.type == .ImmediateTuple {
                    if token.tupleValue == nil {
                        error = true
                        message += "Bad Immediate Tuple|"
                    }
                }
                if token.type == .ImmediateString{
                    if token.stringValue == nil {
                        error = true
                        message += "Bad Immediate String|"
                    }
                }
                if token.type == .Register {
                    if let i = token.intValue{
                        if !(i > -1 && i < 10) {
                            error = true
                            message += "Bad Register|"
                        }
                    } else {
                        error = true
                        message += "Bad Register|"
                    }
                }
                if token.type == .LabelDefinition{
                    if let label = token.stringValue {
                        if "0123456789".characters.contains(label.characters[label.startIndex]){
                            error = true
                            message += "Bad Label Definition, Label cannot start with number|"
                        }
                        charCheck: for c in label.characters{
                            if !"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.contains(c) {
                                error = true
                                message += "Bad Label Definition, Label cannot contain non-alphanumeric characters|"
                                break charCheck
                            }
                        }
                    }
                }
                
            }
            Associations.append(Data: stringLines[i])
            if message != "" {
                Associations.append(Data: ".......\(String(message.characters.dropLast())).......")
            }
        }
        if error {
            return
        }
        var numbers:[[Int]] = Array()
        var count = 0
        var labels:[String:Int] = Dictionary()
        var labelFix:[Int:String] = Dictionary()
        tokensToRam: for tokenizedLine in tokenizedLines{
            var nums = [Int]()
            tokenToInt: for token in tokenizedLine{
                switch token.type{
                case .Register:
                    guard let i = token.intValue else{
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1;
                case .LabelDefinition:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    labels[s.lowercased()]=count
                case .Label:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    nums.append(0)
                    count += 1
                    labelFix[count]=s.lowercased()
                case .ImmediateString:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    for c in s.characters{
                        nums.append(getASCI(Char: c))
                        count += 1
                    }
                case .ImmediateInteger:
                    guard let i = token.intValue else{
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1
                case .ImmediateTuple:
                    guard let t = token.tupleValue else{
                        continue tokenToInt
                    }
                    nums += [t.CS,t.IC,t.NS,t.OC,t.DR]
                    count += 5
                case .Instruction:
                    guard let i = token.intValue else {
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1
                case .Directive: continue tokenToInt
                case .BadToken: continue tokenToInt
                }
            }
            numbers.append(nums)
        }
        count=0
        numbers = Array()
        //run it twice to ensure the labels all exist the second time
        tokensToRam: for tokenizedLine in tokenizedLines{
            var nums = [Int]()
            tokenToInt: for token in tokenizedLine{
                switch token.type{
                case .Register:
                    guard let i = token.intValue else{
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1;
                case .LabelDefinition:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    labels[s.lowercased()]=count
                case .Label:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    nums.append(0)
                    count += 1
                    labelFix[count]=s.lowercased()
                case .ImmediateString:
                    guard let s = token.stringValue else {
                        continue tokenToInt
                    }
                    for c in s.characters{
                        nums.append(getASCI(Char: c))
                        count += 1
                    }
                case .ImmediateInteger:
                    guard let i = token.intValue else{
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1
                case .ImmediateTuple:
                    guard let t = token.tupleValue else{
                        continue tokenToInt
                    }
                    nums += [t.CS,t.IC,t.NS,t.OC,t.DR]
                    count += 5
                case .Instruction:
                    guard let i = token.intValue else {
                        continue tokenToInt
                    }
                    nums.append(i)
                    count += 1
                case .Directive: continue tokenToInt
                case .BadToken: continue tokenToInt
                }
            }
            numbers.append(nums)
        }
        var pos = 0
        for i in 0 ..< numbers.count{
            for j in 0 ..< numbers[i].count{
                pos += 1
                if labelFix[pos] != nil{
                    if let ll = labels[labelFix[pos]!]{
                        numbers[i][j]=ll
                    }
                }
            }
        }
        Associations.write(Data:"")
        var ramLocation = 0
        for i in 0..<numbers.count{
            let numArray = numbers[i]
            let line = stringLines[i]
            var associatedLine = "\(fit("\(ramLocation)",5)):"
            associatedLine += fit(String(numArray.reduce(""){ramLocation+=1;return "\($0)"+"\($1) "}.characters.dropLast()),75)
            associatedLine += "  |  "
            associatedLine += fit(line,75)
            Associations.append(Data:associatedLine)
        }
        Mapping.write(Data:labels.reduce(""){$0+"\n\($1.0) : \($1.1)"})
        Binaries.write(Data:numbers.joined().reduce(""){$0+"\n\($1)"})
        
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
                    if token.stringValue == Optional("tuple") || token.stringValue == Optional("string"){ // and it was for a string or tuple
                        tokens.append(tokenize(String(tokenStrings[i+1..<tokenStrings.count].reduce(""){"\($0) "+$1}.characters.dropFirst()))) // mash together the remaining pieces of line and make token
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
                    if token.stringValue == Optional("tuple") || token.stringValue == Optional("string"){ // and it was for a string or tuple
                        tokens.append(tokenize(String(tokenStrings[i+1..<tokenStrings.count].reduce(""){"\($0) "+$1}.characters.dropFirst()))) // mash together the remaining pieces of line and make token
                        break tokenIterator
                    }
                }
            }
            return tokens
            
        }
        return [Token(type:.BadToken,stringValue:line)]
    }
    private func tokenize(_ tokenString:String)->Token{
        if commands.keys.contains(tokenString){
            return Token(type:.Instruction,intValue:commands[tokenString]!)
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
            return Token(type:.Directive,stringValue:String(tokenString.characters.dropFirst()).lowercased())
        }
        
        if tokenString.characters.first == "r" {
            if let reg = Int(String(tokenString.characters.dropFirst())){
                return Token(type:.Register,intValue:reg)
            }
        }
        return Token(type:.Label,stringValue:tokenString)
    }
}
