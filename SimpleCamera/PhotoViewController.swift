//
//  PhotoViewController.swift
//  SimpleCamera
//
//  Created by Pablo Mateo Fernández on 02/02/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Action methods
    
    @IBAction func save(sender: UIButton) {
        guard let imageToSave = image else { return  }
        
        UIImageWriteToSavePhotosAlbum(imageToSave, nil, nil, nil)
        dismiss(animated: true, completion: nil)
    }

}
