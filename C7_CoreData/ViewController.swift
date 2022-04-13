//
//  ViewController.swift
//  C7_CoreData
//
//  Created by mac12 on 2022/4/13.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    let app = UIApplication.shared.delegate as! AppDelegate
    var viewContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewContext = app.persistentContainer.viewContext
        print(NSPersistentContainer.defaultDirectoryURL())
        deleteAllUserData()
        insertUserData()
        //queryAllUserData()
        //queryWithPredicate()
        storedFetch()
        insert_oneToMany()
        query_oneToMany()
    }
    
    func insertUserData() {
        var user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "B10715039"
        user.cname = "Roy"
        
        user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "B10715038"
        user.cname = "Ken"
        
        user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "M10715001"
        user.cname = "Kevin"
        
        user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "M10715049"
        user.cname = "Quentin"
        
        app.saveContext()
    }
    
    func queryAllUserData() {
        do {
            let allUsers = try viewContext.fetch(UserData.fetchRequest())
            for user in allUsers as! [UserData] {
                print("\(user.cid!), \(user.cname!)")
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAllUserData() {
        do {
            let allUsers = try viewContext.fetch(UserData.fetchRequest())
            for user in allUsers as! [UserData] {
                viewContext.delete(user)
            }
            app.saveContext()
            print("Successful delete")
        } catch {
            print(error)
        }
        
    }

    func queryWithPredicate() {
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        let predicate = NSPredicate(format: "cname like 'K*'")
        fetchRequest.predicate = predicate
        let sort = NSSortDescriptor(key: "cid", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let allUsers = try viewContext.fetch(fetchRequest)
            for user in allUsers {
                print("\(user.cid!), \(user.cname!)")
            }
        } catch {
            print(error)
        }
    }
    
    func storedFetch() {
        let model = app.persistentContainer.managedObjectModel
        if let fetchRequest = model.fetchRequestTemplate(forName: "FtchRst_cname_BeginsK") {
            do {
                let allUsers = try viewContext.fetch(fetchRequest)
                for user in allUsers as! [UserData] {
                    print("\((user.cid)!), \((user.cname)!)")
                }
            } catch {
                print(error)
            }
        }
    }
    
    func insert_oneToMany() {
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "B10999999"
        user.cname = "Gggg"
        
        var car = NSEntityDescription.insertNewObject(forEntityName: "Car", into: viewContext) as! Car
        car.plate = "123-ABC"
        user.addToOwn(car)
        
        car = NSEntityDescription.insertNewObject(forEntityName: "Car", into: viewContext) as! Car
        car.plate = "ZXC-987"
        user.addToOwn(car)
        app.saveContext()
    }
    
    func query_oneToMany() {
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        let predicate = NSPredicate(format: "cid like 'B10999999'")
        fetchRequest.predicate = predicate
        
        do {
            let allUsers = try viewContext.fetch(fetchRequest)
            for user in allUsers as! [UserData] {
                if user.own == nil {
                    print("\(user.cname!), 沒有車")
                } else {
                    print("\(user.cid!) 有 \((user.own?.count)!)部車")
                    for car in user.own as! Set<Car> {
                        print("車牌是 \((car.plate)!)")
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}

