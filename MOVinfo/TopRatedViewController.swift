//
//  TopRatedViewController.swift
//  MOVinfo
//
//  Created by 吕凌晟 on 16/1/9.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class TopRatedViewController: UIViewController,UICollectionViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchbar: UISearchBar!
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var moviecollection: UICollectionView!
    var movies:[NSMutableDictionary]?
    var storedmovies:[NSMutableDictionary]?
    var filteredData: [NSMutableDictionary]!
    var is_searching: Bool!
    var searchingDataArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EZLoadingActivity.show("Loading...", disableUI: true)
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        moviecollection.insertSubview(refreshControl, atIndex: 0)
        // Do any additional setup after loading the view, typically from a nib.
        moviecollection.dataSource=self
        moviecollection.delegate=self
        searchbar.delegate=self
        
        
        let apiKey = "5b7969a9527bf5b7ec4a5b434db4fd89"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSMutableDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies=responseDictionary["results"] as? [NSMutableDictionary]
                            self.storedmovies=self.movies
                            self.moviecollection.reloadData()
                            EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
        });
        //filteredData=movies
        
        task.resume()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarSearchButtonClicked(searchbar: UISearchBar) {
        searchbar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty{
            is_searching = false
            self.movies=storedmovies
            moviecollection.reloadData()
            //onRefresh()
        } else {
            print(" search text %@ ",searchBar.text! as NSString)
            is_searching = true
            //filteredData.removeAll()
            self.movies=storedmovies
            for var index = 0; index < movies!.count; index++
            {
                let currentString = movies![index]["title"] as! String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    
                    //filteredData[]
                    
                }else{
                    movies?.removeAtIndex(index)
                }
            }
            
            moviecollection.reloadData()
        }
    }
    
    func onRefresh() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        let apiKey = "5b7969a9527bf5b7ec4a5b434db4fd89"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                            //NSLog("response: \(responseDictionary)")
                            
                            
                            self.movies=responseDictionary["results"] as? [NSMutableDictionary]
                            
                            self.moviecollection.reloadData()
                            EZLoadingActivity.hide(success: true, animated: true)
                    }
                }
        });
        task.resume()
        EZLoadingActivity.hide(success: true, animated: true)
        self.refreshControl.endRefreshing()
        print("success fresh")
        
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        searchbar.resignFirstResponder()
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Selected cell number: \(indexPath.item)")
        
        
        if let y = movies![indexPath.item]["backdrop_path"] as? String {
            
            
            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["backdrop_path"], forKey: "backdrop_path")
        }else{
            NSUserDefaults.standardUserDefaults().setObject("No image", forKey: "backdrop_path")
        }
        
        if let y = movies![indexPath.item]["poster_path"] as? String{
            
            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["poster_path"], forKey: "posterpath")
        }else{
            NSUserDefaults.standardUserDefaults().setObject("No image", forKey: "posterpath")
        }
        
        NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["title"], forKey: "moviename")
        NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["vote_average"], forKey: "movierate")
        NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["overview"], forKey: "overview")
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TopRatedViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies=movies{
            return movies.count
        }else{
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TopMoviecell", forIndexPath: indexPath) as! TopMoviecell
        let movie=movies![indexPath.item]
        print(indexPath.item)
        let title=movie["title"] as! String
        let baseURL="http://image.tmdb.org/t/p/w500"
        
        
        if let myString = movies![indexPath.item]["poster_path"] as? String{
            let postpath=movie["poster_path"] as! String
            let imageURL=NSURL(string: baseURL + postpath)
            cell.topratedpost.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                
                
                if imageResponse != nil {
                    print("fade om Image")
                    cell.topratedpost.alpha = 0.0
                    cell.topratedpost.image = image
                    UIView.animateWithDuration(0.8, animations: { () -> Void in
                        cell.topratedpost.alpha = 1.0
                    })
                } else {
                    print("Image was cached ")
                    cell.topratedpost.image = image
                }
                }, failure: { (imageRequest, imageResponse, error) -> Void in
            })
        }
        else{
            cell.topratedpost.image = UIImage(named: "NO Image")
        }
        cell.topratedMoviename.text=title
        
        return cell
    }
}
