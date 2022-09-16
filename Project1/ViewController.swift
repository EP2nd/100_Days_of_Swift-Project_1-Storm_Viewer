import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var numberOfViews = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(recommendApp))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let defaults = UserDefaults.standard
        
        if let savedData = defaults.object(forKey: "numberOfViews") as? Data, let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                numberOfViews = try jsonDecoder.decode([String: Int].self, from: savedData)
                pictures = try jsonDecoder.decode([String].self, from: savedPictures)
            } catch {
                print("Failed to load saved data.")
            }
        } else {
            performSelector(inBackground: #selector(loadImages), with: nil)
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        //tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        //cell.textLabel?.text = pictures[indexPath.row]
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture
        cell.detailTextLabel?.text = "Views: \(numberOfViews[picture]!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = storyboard?. dreViewController(withIdentifier: "Detail") as? DetailViewController {
            detailVC.selectedImage = pictures[indexPath.row]
            detailVC.selectedPictureNumber = indexPath.row + 1
            detailVC.totalPictures = pictures.count
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
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
                numberOfViews[item] = 0
                pictures.append(item)
            }
        }
        pictures.sort()
    }
    
    @objc func recommendApp() {
        let recommend = "Check out my first app!"
        
        let vc = UIActivityViewController(activityItems: [recommend], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(numberOfViews), let savedPictures = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "numberOfViews")
            defaults.set(savedPictures, forKey: "pictures")
        } else {
            print("Failed to save the number of views.")
        }
    }
}
