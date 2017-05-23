//
//  saveFile.swift
//  SAP
//
//  Created by Liam Pierce on 4/3/17.
//  Copyright © 2017 Liam Pierce. All rights reserved.
//

import Foundation

class saveFile{
    let Name:String;
    var url:URL;
    var anl = "\n" //Default to newline for append.
    
    init(withName n:String, FileEnding:String = ".txt", Documents:Bool=true){ //Create a file with path ~/Documents/n.txt, where n can also contain a path.
        self.Name = n;
        let Loc = FileManager.default.urls(for: ((Documents==true) ? .documentDirectory : .desktopDirectory), in: .userDomainMask)[0];
        
        url = URL.init(fileURLWithPath: "\(Loc.path)/\(n)\(FileEnding)");
    }
    
    init(withUrl u:URL){
        self.Name = u.path;
        self.url = u;
    }
    
    public func write(Data:String)->String?{ //Writes a full file, full override.
        
        do{
            try Data.write(to: url, atomically:true,encoding:String.Encoding.utf8);
        }catch let error as NSError{
            return url.description + " " + error.localizedDescription;
        }
        return nil;
    }
    
    public func appendDelimit(with:String){
        self.anl = with;
    }
    
    public func append(Data:String)->String?{ //Adds text to the bottom of a file.
        let dataEnc = ("\(anl)\(Data)").data(using: String.Encoding.utf8, allowLossyConversion: false)!
        if !FileManager.default.fileExists(atPath: url.path){
            return self.write(Data:Data);
        }
        
        let hndl = try? FileHandle(forWritingTo: url)
        hndl?.seekToEndOfFile()
        hndl?.write(dataEnc)
        hndl?.closeFile()
        return nil;
    }
    
    public func read()->String?{ //Reads full file.
        return try? String(contentsOfFile:url.path, encoding:String.Encoding.utf8);
    }
    
    public func remove(){ //Deletes file from disk.
        try? FileManager.default.removeItem(atPath:url.path);
    }
    
    func changePath(Path:String){
        let Documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
        
        url = URL.init(fileURLWithPath: "\(Documents.path)/\(Path).txt");
        
    }
}
