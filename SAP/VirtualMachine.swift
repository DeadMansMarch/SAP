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
    private(set) var AccessMem = [Int](); //'Memory'.
    private(set) var AccessReg = [Int](); //Registers.
    private(set) var SpReg = ["PGRM":0,"CMPR":0,"STCK":0]; //Special Registers.
    //                                  ^ 0 = less, 1 = equal, 2 = great.
    
    func setMemoryLength(Length L:Int){ //Resets memory to certain size.
        AccessMem = [Int](repeating:0,count:8);
    }
    
    func loadMem(FullMem Dat:[Int]){
        self.setMemoryLength(Length: Dat[0]);
    }
    
    func cmdSwitch(With c:Int){ //Get command from Int.
        switch(c){
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
            case 8:  //movemr.
                break;
            case 12: //addir.
                break;
            case 13: //addrr.
                break;
            case 34: //cmprr.
                break;
            case 45: //outcr.
                break;
            case 49: //printi
                break;
            case 55: //outs.
                break;
            case 57: //jumpne
                if (SpReg["CMPR"] != 1){ //Not equal.
                    SpReg["PGRM"] = AccessMem[SpReg["PGRM"]! + 1]; //Set PGRM counter to location in memory : PGRM + 1
                }
                break;
            default:
                break;
        }
    }
    
}
