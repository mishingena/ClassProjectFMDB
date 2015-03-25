//
//  ViewController.swift
//  ClassProjectFMDB
//
//  Created by Gena on 18.03.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var fruits: [FruitModel]?
    var totalCount: Int! = 0
    var selectedCellId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.fruits == nil {
            self.reloadData()
        }
        if let index = self.selectedCellId {
            DatabaseManager.sharedInstance.getFruitAtIndex(index, completion: { (fruit: FruitModel!) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.fruits![index] = fruit
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func reloadData() {
        DatabaseManager.sharedInstance.getFruitsArray(10, offset: 0) { (result: DBResult!) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.fruits = result.objects
                self.totalCount = result.totalCount
                self.tableView.reloadData()
            })
        }
    }
    
    func loadMore() {
        if self.totalCount == self.fruits!.count {
            return
        }
        DatabaseManager.sharedInstance.getFruitsArray(10, offset: 0) { (result: DBResult!) -> () in
                for obj in result.objects {
                    self.fruits!.append(obj)
                }
                self.totalCount = result.totalCount
                self.tableView.reloadData()
        }
    }
    
    //MARK: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalCount!
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var fruit: FruitModel = self.fruits![indexPath.row]
        var cell: FruitCell = tableView.dequeueReusableCellWithIdentifier("FruitCell") as FruitCell
        cell.nameLabel!.text = fruit.name
        cell.fruitImageView!.sd_setImageWithURL(fruit.thumbURL)
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.fruits!.count - 1 {
            self.loadMore()
        }
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow()!
        var detail: DetailViewController = segue.destinationViewController as DetailViewController
        detail.fruit = self.fruits![indexPath.row]
        self.selectedCellId = indexPath.row
    }
}

