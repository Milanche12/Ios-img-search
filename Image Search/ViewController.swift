//
//  ViewController.swift
//  Image Search
//
//  Created by Milan Bogdanovic on 07/03/2021.
//

import UIKit

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Results]
}
struct Results: Codable {
    let id: String
    let urls: URLS
}
struct URLS: Codable {
    let regular : String
}

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {


    var results: [Results] = []
    
    private var collectionView: UICollectionView?
    
    let searchBar = UISearchBar()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.addSubview(searchBar)
        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
        
    }
    
    func fetchPhotos(query : String){
        guard let url = URL(string: "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(query)&client_id=wsndJL2X6CsxZRq5pkhK0KR9AN1XWbsYXW2bdHTj2FE") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {[weak self] (data, _, error) in
            guard let data = data, error == nil else{
                return
            }
            do {
                let decoder = JSONDecoder()
                
                let jsonResutls = try decoder.decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.results = jsonResutls.results
                    self?.collectionView?.reloadData()
                }
            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        let imageURLString = results[indexPath.row].urls.regular
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ImageCollectionViewCell.identifier , for: indexPath) as? ImageCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.configure(with: imageURLString)
        //print(imageURLString)
        return cell
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let text = searchBar.text{
            results = []
            collectionView?.reloadData()
            
            fetchPhotos(query: text)
        }
    }

}

