//
//  Moviedetail.swift
//  MOVinfo
//
//  Created by 吕凌晟 on 16/1/6.
//  Copyright © 2016年 Lingsheng Lyu. All rights reserved.
//

import UIKit

class Moviedetail: UIViewController {

    @IBOutlet weak var topblurimage: UIImageView!
    @IBOutlet weak var coverimage: UIImageView!
    @IBOutlet weak var blurimage: UIImageView!
    @IBOutlet weak var backdropimage: UIImageView!
    @IBOutlet weak var Moviename: UILabel!
    @IBOutlet weak var movierate: UILabel!
    
    @IBOutlet weak var overview: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let movietitle = NSUserDefaults.standardUserDefaults().objectForKey("moviename") as! String
        let ratestring = "\(NSUserDefaults.standardUserDefaults().objectForKey("movierate")!)"
        let overviewstring = "\(NSUserDefaults.standardUserDefaults().objectForKey("overview")!)"
        let baseURL="http://image.tmdb.org/t/p/w600"
        let backdroppath=NSUserDefaults.standardUserDefaults().objectForKey("backdrop_path") as! String
        let posterpath=NSUserDefaults.standardUserDefaults().objectForKey("posterpath") as! String
        
        
        self.title=movietitle
        if(backdroppath == "No image"){
            
        }else{
            let imageURL=NSURL(string: baseURL + backdroppath)
            backdropimage.setImageWithURL(imageURL!)
            blurimage.setImageWithURL(imageURL!)
            topblurimage.setImageWithURL(imageURL!)
        }
        
        
        if(posterpath == "No image"){
            coverimage.image =  UIImage(named: "No Image")
        }else{
            let posterURL=NSURL(string: baseURL + posterpath)
            coverimage.setImageWithURL(posterURL!)

        }
        
        print(ratestring)
        Moviename.text=movietitle
        movierate.text="Rate: " + ratestring + "/10"
        overview.text=overviewstring
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
