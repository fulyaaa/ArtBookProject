//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by fulya akan on 12.06.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveText: UITextField!
    
    @IBOutlet weak var saveBut: UIButton!
    
    var choosenPainting = ""
    var choosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenPainting != "" {
            
            saveBut.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
        
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = choosenPaintingId?.uuidString
            //yazdıgımız kosula gore bulup getirecek, predicate
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            saveText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
            
        } else {
            saveBut.isHidden = false
            saveBut.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            saveText.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        view.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveBut.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        //bir nesnenin başka bir nesnesine aktarabilmesi
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text! , forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        newPainting.setValue(UUID(), forKey: "id")
        
        if let year = Int(saveText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        //diger gozlemcilere msj yolluyoruz, veriyi kaydettikten sonra listede görünmesini sagliyoruz
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        //verileri cektikten sonra bir onceki viewcontrollera dönme
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    
   

}
