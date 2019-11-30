//
//  NewPlaceViewController.swift
//  myPlaces
//
//  Created by Alexey Meleshkevich on 26/10/2019.
//  Copyright © 2019 Alexey Meleshkevich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var savePlaceButton: UIBarButtonItem!
    @IBOutlet weak var locationPlaceField: UITextField!
    @IBOutlet weak var placeNameField: UITextField!
    @IBOutlet weak var placeTypeField: UITextField!
    @IBOutlet weak var ratingControl: PlaceRating!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1))
        savePlaceButton.isEnabled = false
        placeNameField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    
    
    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let libraryIcon = UIImage(named: "photo")
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera",
                                       style: .default) { _ in
                                        self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let photo = UIAlertAction(title: "Photo",
                                      style: .default) { _ in
                                        self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(libraryIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Cancel", style: .default)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
            
            
        } else {
            view.endEditing(true)
        }
    }
    
    func savePlace() {
        
        var image: UIImage?
        
        if imageIsChanged {
            image = imageOfPlace.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeNameField.text!,
                             location: locationPlaceField.text!,
                             type: placeTypeField.text!,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        
        if currentPlace != nil{
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
        DataManager.saveObject(newPlace)
        }
         
    }
    
    private func setupEditScreen(){
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            placeNameField.text = currentPlace?.name
            locationPlaceField.text = currentPlace?.location
            placeTypeField.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    func setupNavigationBar(){
        
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        savePlaceButton.isEnabled = true
    }
    
    
    @IBAction func cancelBarAction(_ sender: Any) {
        dismiss(animated: true)
        }
    }





// MARK: text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(){
        if placeNameField.text?.isEmpty == false {
            savePlaceButton.isEnabled = true
        }
        else {
            savePlaceButton.isEnabled = false
        }
    }
}

// MARK: work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source){
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}
