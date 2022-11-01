//
//  DetailViewController.swift
//  Project1
//
//  Created by Edwin Przeźwiecki Jr. on 18/11/2021.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    var selectedPictureNumber = 0
    var totalPictures = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedImage != nil, "It appears an image has not been selected!")
        
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    // Project 27, challenge 3:
    func watermarked(image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let stringAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle,
            .strokeColor: UIColor.black,
            .backgroundColor: UIColor.white
        ]
        
        let renderedImage = renderer.image { ctx in
            let watermark = "From Storm Viewer"
            let attributedWatermark = NSAttributedString(string: watermark, attributes: stringAttributes)
            
            image.draw(at: CGPoint(x: 0, y: 0))
            
            attributedWatermark.draw(with: CGRect(x: 30, y: 30, width: 150, height: 30), options: .usesLineFragmentOrigin, context: nil)
        }
        return renderedImage
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
            
        // Project 27, challenge 3:
        let watermarkedImage = watermarked(image: image)
            
        let vc = UIActivityViewController(activityItems: [watermarkedImage, selectedImage!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
