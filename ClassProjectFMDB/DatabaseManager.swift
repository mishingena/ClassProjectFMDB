//
//  DatabaseManager.swift
//  ClassProjectFMDB
//
//  Created by Gena on 19.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

//import Cocoa


class DBResult: NSObject {
    var objects: [FruitModel]
    var totalCount: Int
    
    init(arr: [FruitModel], count: Int) {
        objects = arr
        totalCount = count
    }
}


class DatabaseManager: NSObject {
    
    var database: FMDatabase?
    var queue: dispatch_queue_t?
    
    class var sharedInstance: DatabaseManager {
        struct Static {
            static var instance: DatabaseManager?
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DatabaseManager()
        }
        return Static.instance!
    }
    
    override init() {
        if let docDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as? String {
            let path = docDir.stringByAppendingPathComponent("db.sqlite")
            self.database = FMDatabase(path: path)
            self.queue = dispatch_queue_create("Database queue", DISPATCH_QUEUE_SERIAL)
        }
        self.database!.open()
    }
    
    deinit {
        self.database!.close()
    }
    
    func getFruitAtIndex(index: Int!, completion: (FruitModel!) -> ()) {
        dispatch_async(queue, { () -> Void in
            if let set: FMResultSet = self.database!.executeQuery("select * from Fruits where id = \(index+1)", withArgumentsInArray: nil) {
                var fruit: FruitModel
                if (set.next()) {
                    fruit = FruitModel(set: set)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(fruit)
                    })
                }
            }
        })
    }
    
    func getFruitsArray(completion: ([FruitModel]) -> ()) {
        dispatch_async(queue, { () -> Void in
            var array: [FruitModel] = []
            if let set: FMResultSet = self.database!.executeQuery("select * from Fruits", withArgumentsInArray: nil) {
                while set.next() {
                    array.append(FruitModel(set: set))
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(array)
            })
        })
    }
    
    func getFruitsArray(limit: Int, offset: Int, completion: (DBResult!) -> ()) {
        dispatch_async(queue, { () -> Void in
            let sql: String = "select * from Fruits limit \(limit) offset \(offset)"
            let set: FMResultSet = self.database!.executeQuery(sql, withArgumentsInArray: nil)
            var array: [FruitModel] = []
            while set.next() {
                array.append(FruitModel(set: set))
            }
            let countSet: FMResultSet = self.database!.executeQuery("select count(*) from Fruits", withArgumentsInArray: nil)
            var count: Int = 0
            if countSet.next() {
                count = countSet.longForColumnIndex(0);
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(DBResult(arr: array, count: count))
            })
        });
    }
    
    //MARK: Migrations
    func migrateDatabaseIfNescessary() {
        dispatch_async(queue, { () -> Void in
            var version: Int = 0
            let versionSet: FMResultSet = self.database!.executeQuery("PRAGMA user_version;", withArgumentsInArray: nil)
            if versionSet.next() {
                version = versionSet.longForColumnIndex(0)
            }
            
            if version == 0 {
                self.database!.executeUpdate("create table IF NOT EXISTS Fruits (id integer primary key autoincrement, name text, thumb_url text, image_url text);", withArgumentsInArray: nil)
                var objectsArray = self.initialData()
                for dictionary in objectsArray {
                    let dict = dictionary as? Dictionary<String,String>
                    self.database!.executeUpdate("insert into Fruits (name, thumb_url, image_url) values (:title, :thumb, :img);", withParameterDictionary: dict)
                }
                version = 1
                let sql = "PRAGMA user_version=\(version);"
                self.database!.executeUpdate(sql, withArgumentsInArray: nil)
            }
            if version == 1 {
                self.database!.executeUpdate("alter table Fruits add column details text default '';", withArgumentsInArray: nil);
                version = 2
                let sql = "PRAGMA user_version=\(version);"
                self.database!.executeUpdate(sql, withArgumentsInArray: nil)
            }
            
        })
        
    }
    
    func saveFruit(fruit: FruitModel!) {
        dispatch_async(queue, { () -> Void in
            let sql = "insert or replace into Fruits (id, name, details, thumb_url, image_url) values (:id, :title, :details, :thumb, :img);"
            self.database!.executeUpdate(sql, withParameterDictionary: fruit!.dictionary())
        })
    }
    
    func initialData() -> [AnyObject] {
        let jsonString = "[{\"title\":\"Ananas\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Ananas_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Ananas.png\"},\n{\"title\":\"Apple\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Apple_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Apple.png\"},\n{\"title\":\"Apricot\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Apricot_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Apricot.png\"},\n{\"title\":\"Banana\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Banana_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Banana.png\"},\n{\"title\":\"Pear\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Pear_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Pear.jpg\"},\n{\"title\":\"Cherry\",\"thumb\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Cherry_tb.png\",\"img\":\"https://dl.dropboxusercontent.com/u/55523423/Images/Cherry.jpg\"}]"
        let jsonData: NSData? = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let jsonObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers | NSJSONReadingOptions.MutableLeaves, error: nil)
        let jsonObjects = jsonObject as? NSArray
        var array: [Dictionary<String,String>] = []
        for i in 1..<10 {
            for obj in jsonObjects! {
                if let dic = obj as? Dictionary<String,String> {
                    array.append(dic)
                }
            }
        }
        return array
    }
    
}
