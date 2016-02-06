 //
//  ViewController.swift
//  MOVinfo
//
//  Created by 吕凌晟 on 16/1/6.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit
import AFNetworking
import EZLoadingActivity

class ViewController: UIViewController,UICollectionViewDelegate,UISearchBarDelegate {

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
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()

        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        moviecollection.insertSubview(refreshControl, atIndex: 0)
        // Do any additional setup after loading the view, typically from a nib.
        moviecollection.dataSource=self
        moviecollection.delegate=self
        searchbar.delegate=self
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock{(status: AFNetworkReachabilityStatus?)          in
            
            switch status!.hashValue{
            case AFNetworkReachabilityStatus.NotReachable.hashValue:
                print("Not reachable")
                EZLoadingActivity.show("No Networking", disableUI: true)
            case AFNetworkReachabilityStatus.ReachableViaWiFi.hashValue , AFNetworkReachabilityStatus.ReachableViaWWAN.hashValue :
                print("Reachable")
                EZLoadingActivity.hide()
                //EZLoadingActivity.showWithDelay("Networking Connect", disableUI: true, seconds: 2)
                //println(MyClass.sharedInstance.description)  // Seems to cause error
            default:
                print("Unknown status")
            }
        }
        EZLoadingActivity.show("Loading...", disableUI: true)
        let apiKey = "5b7969a9527bf5b7ec4a5b434db4fd89"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
        //EZLoadingActivity.hide(success: true, animated: true)
        task.resume()
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
            //self.movies=storedmovies
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
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
        //EZLoadingActivity.hide(success: true, animated: true)
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

        
//        if let myString = movies![indexPath.item]["backdrop_path"] as? String{
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["title"], forKey: "moviename")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["vote_average"], forKey: "movierate")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["overview"], forKey: "overview")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["backdrop_path"], forKey: "backdrop_path")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["poster_path"], forKey: "posterpath")
//        }else if let myString = movies![indexPath.item]["backdrop_path"] as? String{
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["title"], forKey: "moviename")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["vote_average"], forKey: "movierate")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["overview"], forKey: "overview")
//            NSUserDefaults.standardUserDefaults().setObject("No image", forKey: "backdrop_path")
//            NSUserDefaults.standardUserDefaults().setObject(movies![indexPath.item]["poster_path"], forKey: "posterpath")
//        }
    }

    


}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies=movies{
            return movies.count
        }else{
            return 0
        }
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Moviecell", forIndexPath: indexPath) as! Moviecell
        let movie=movies![indexPath.item]
        print(indexPath.item)
        let title=movie["title"] as! String
        let baseURL="http://image.tmdb.org/t/p/w500"
        
        
//        if let myString = movies![indexPath.item]["poster_path"] as? String{
//            let postpath=movie["poster_path"] as! String
//            let imageURL=NSURL(string: baseURL + postpath)
//            cell.postpic.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
//                
//                
//                if imageResponse != nil {
//                    print("fade om Image")
//                    cell.postpic.alpha = 0.0
//                    cell.postpic.image = image
//                    UIView.animateWithDuration(0.8, animations: { () -> Void in
//                        cell.postpic.alpha = 1.0
//                    })
//                } else {
//                    print("Image was cached ")
//                    cell.postpic.image = image
//                }
//                }, failure: { (imageRequest, imageResponse, error) -> Void in
//            })
//        }
//        else{
//            cell.postpic.image = UIImage(named: "NO Image")
//        }
//        cell.Moviename.text=title
        
        
        let smallImagebaseURL="https://image.tmdb.org/t/p/w45"
        let largeImagebaseURL="https://image.tmdb.org/t/p/original"
        
        
        
        if let myString = movies![indexPath.item]["poster_path"] as? String{
            let postpath=movie["poster_path"] as! String
            let smallImageURL=smallImagebaseURL + postpath
            let largeImageURL=largeImagebaseURL + postpath
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageURL)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageURL)!)
            cell.postpic.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                
                if smallImageResponse != nil {
                    print("fade om Image")
                    cell.postpic.alpha = 0.0
                    cell.postpic.image = smallImage
                    UIView.animateWithDuration(0.8, animations: { () -> Void in
                    cell.postpic.alpha = 1.0
                    })
                    } else {
                    print("Image was cached ")
                    cell.postpic.image = smallImage
                    }

                // smallImageResponse will be nil if the smallImage is already available
                // in cache (might want to do something smarter in that case).
//                cell.postpic.alpha = 0.0
//                cell.postpic.image = smallImage;
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    cell.postpic.alpha = 1.0
                    
                    }, completion: { (sucess) -> Void in
                        
                        // The AFNetworking ImageView Category only allows one request to be sent at a time
                        // per ImageView. This code must be in the completion block.
                        cell.postpic.setImageWithURLRequest(
                            largeImageRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.postpic.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                })
            },
            failure: { (request, response, error) -> Void in
                // do something for the failure condition
                // possibly try to get the large image
            })}
        else{
            cell.postpic.image = UIImage(named: "NO Image")
        }
        cell.Moviename.text=title
        

        
        
        cell.layer.cornerRadius=8
        cell.layer.masksToBounds=true
//        cell.postpic.layer.cornerRadius=8
//        cell.postpic.layer.masksToBounds=true
//        cell.namevisual.layer.cornerRadius=8
//        cell.namevisual.layer.masksToBounds=true
        return cell
    }
}

