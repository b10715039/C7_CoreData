//
//  ViewController.swift
//  C7_CoreData
//
//  Created by mac12 on 2022/4/13.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let app = UIApplication.shared.delegate as! AppDelegate
    var viewContext: NSManagedObjectContext!
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var clientName: UITextField!
    @IBOutlet weak var clientId: UITextField!
    @IBOutlet weak var carPlate: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewContext = app.persistentContainer.viewContext
        print(NSPersistentContainer.defaultDirectoryURL())
        //deleteAllUserData()
//        insertUserData()
        //queryAllUserData()
        //queryWithPredicate()
//        storedFetch()
//        insert_oneToMany()
//        query_oneToMany()
        
        //saveImage()
        //loadImage()
        
//        for i in 1...6 {
//            if let image = UIImage(named: "0\(i).jpg") {
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            }
//        }
    }
    
    @IBAction func clearInfo(_ sender: Any) {
        clientName.text = ""
        clientId.text = ""
        carPlate.text = ""
        myImage.image = nil
    }
    
    @IBAction func saveData(_ sender: UIButton) {
        if (clientId.text == "") || (clientName.text == "") || (carPlate.text == "") || (myImage.image == nil) {
            MyAlertController("Error")
        } else {
            let user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
            user.setValue(clientName.text, forKey: "cname")
            user.setValue(clientId.text, forKey: "cid")
            user.setValue(myImage.image?.pngData(), forKey: "cimage")
            let car = NSEntityDescription.insertNewObject(forEntityName: "Car", into: viewContext) as! Car
            car.setValue(carPlate.text, forKey: "plate")
            user.addToOwn(car)
            app.saveContext()
            
            MyAlertController("Successful insert")
            
        }
    }
    @IBAction func loadData(_ sender: UIButton) {
        let fetchId = NSPredicate(format: "cid BEGINSWITH[cd] %@", clientId.text!)
        let fetchName = NSPredicate(format: "cname BEGINSWITH[cd] %@", clientName.text!)
        let fetchCarPlate = NSPredicate(format: "plate == %@", carPlate.text!)
        
        if carPlate.text != "" {
            let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
            var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchCarPlate])
            fetchRequest.predicate = predicate
            do {
                let t_cars = try viewContext.fetch(fetchRequest)
                if t_cars == [] {
                    MyAlertController("Unsuccessful load")
                }
                for t_car in t_cars {
                    let user = t_car.belongto!
                    clientId.text = user.cid
                    clientName.text = user.cname
                    myImage.image = UIImage(data: user.cimage! as Data)
                }
            } catch {
                print(error)
            }
        } else {
            let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
            var predicate = NSCompoundPredicate()
            
            if (clientId.text != "") && (clientName.text == "") {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchId])
            } else if (clientId.text == "") && (clientName.text != "") {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchName])
            } else {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchId, fetchName])
            }
            fetchRequest.predicate = predicate
            
            do {
                let Users = try viewContext.fetch(fetchRequest)
                if Users == [] {
                    MyAlertController("Unsuccessful load")
                }
                
                for user in Users {
                    clientId.text = user.cid
                    clientName.text = user.cname
                    myImage.image = UIImage(data: user.cimage! as Data)
                    for car in user.own as! Set<Car> {
                        carPlate.text = car.plate
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func clickReturn(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func selected(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        show(imagePicker, sender: myImage)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        myImage.image = image
        dismiss(animated: true, completion: nil)
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
                if user.own?.count != 0 {
                    
                }
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
    
    func saveImage() {
        let user = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: viewContext) as! UserData
        user.cid = "M11888999"
        user.cname = "Serena"
        let image = UIImage(named: "03.jpg")
        let imageData = image?.pngData()
        user.cimage = imageData
        app.saveContext()
    }
    
    func loadImage() {
        let fetchRequest: NSFetchRequest<UserData> = UserData.fetchRequest()
        let predicate = NSPredicate(format: "cid like 'M11888999'")
        fetchRequest.predicate = predicate
        
        do {
            let allUsers = try viewContext.fetch(fetchRequest)
            for user in allUsers {
                myImage.image = UIImage(data: user.cimage! as Data)
            }
        } catch {
            print(error)
        }
    }
    
    func MyAlertController(_ result: String) {
        var alert = UIAlertController()
        if result == "Error" {
            alert = UIAlertController(title: "Error", message: "Please enter complete information", preferredStyle: .alert)
        } else if result == "Successful insert" {
            alert = UIAlertController(title: "Successful insert", message: "\(clientName.text!) added finished.", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Unsuccessful load", message: "There is no such data.", preferredStyle: .alert)
        }
        
        let action = UIAlertAction(title: "I got it!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

