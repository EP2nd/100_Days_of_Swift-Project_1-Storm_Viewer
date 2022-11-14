//
//  ViewController.swift
//  Project1
//
//  Created by Edwin Przeźwiecki Jr. on 18/11/2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    /// Project 12, challenge 1:
    var numberOfViews = [String: Int]()
    /// Project 9, challenge 1:
    var isLoadingFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        
        /// Project 3, challenge 2:
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendApp))
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        /// Loading saved data:
        let defaults = UserDefaults.standard
        
        /// Project 12, challenge 1:
        if let savedData = defaults.object(forKey: "numberOfViews") as? Data, let savedPictures = defaults.object(forKey: "pictures") as? Data {
            
            let jsonDecoder = JSONDecoder()
            
            do {
                numberOfViews = try jsonDecoder.decode([String: Int].self, from: savedData)
                pictures = try jsonDecoder.decode([String].self, from: savedPictures)
            } catch {
                print("Failed to load saved data.")
            }
        } else {
            /// Loading data from the app's bundle:
            /// Project 9, challenge 1:
            performSelector(inBackground: #selector(loadImages), with: nil)
        }
        
        /// Project 9, challenge 1:
        //tableView.reloadData()
        isLoadingFinished = true
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /// Project 9, challenge 1:
        if !isLoadingFinished {
            return 0
        }
        
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        //cell.textLabel?.text = pictures[indexPath.row]
        let picture = pictures[indexPath.row]
        
        cell.textLabel?.text = picture
        /// Project 12, challenge 1:
        cell.detailTextLabel?.text = "Views: \(numberOfViews[picture]!)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            detailVC.selectedImage = pictures[indexPath.row]
            /// Challenge 3:
            detailVC.selectedPictureNumber = indexPath.row + 1
            detailVC.totalPictures = pictures.count
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        /// Project 12, challenge 1:
        let picture = pictures[indexPath.row]
        numberOfViews[picture]! += 1
        
        save()
        tableView.reloadData()
    }
    
    @objc func loadImages() {
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                /// Project 12, challenge 1:
                numberOfViews[item] = 0
                pictures.append(item)
            }
        }
        /// Challenge 2:
        pictures.sort()
    }
    
    /// Project 3, challenge 2:
    @objc func recommendApp() {
        let recommend = "Check out my first app!"
        
        let vc = UIActivityViewController(activityItems: [recommend], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        
        let jsonEncoder = JSONEncoder()
        
        /// Project 12, challenge 1:
        if let savedData = try? jsonEncoder.encode(numberOfViews), let savedPictures = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "numberOfViews")
            defaults.set(savedPictures, forKey: "pictures")
        } else {
            print("Failed to save the number of views.")
        }
    }
}
