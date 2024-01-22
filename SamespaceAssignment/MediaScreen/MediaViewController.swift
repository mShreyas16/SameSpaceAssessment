//
//  MediaViewController.swift
//  SamespaceAssignment
//
//  Created by Shreyas Mandhare on 20/01/24.
//

import UIKit
import Kingfisher
import FSPagerView


class MediaViewController: UIViewController {
    
    
    //MARK: Outlets
    @IBOutlet weak var pageControl: FSPagerView!
    @IBOutlet weak var img_PlayPause: UIImageView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var lbl_SongName: UILabel!
    @IBOutlet weak var lbl_ArtistNAme: UILabel!
    @IBOutlet weak var lbl_currentTime: UILabel!
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    //MARK: Properties
    let coverImageBaseUrl = "https://cms.samespace.com/assets/"
    var selectedSongIndex = 0
    var songsListObject : SongListModel?
    var imageArray = [UIImage]()
    var songListDelegate: ViewController?
    var gradient = CAGradientLayer()
    var currentColor : UIColor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        
        lbl_SongName.text = songsListObject?.data[selectedSongIndex].name
        lbl_ArtistNAme.text = songsListObject?.data[selectedSongIndex].artist

        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = [.down]
            self.view.addGestureRecognizer(swipeGesture)
        
        pageControl.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.delegate = self
        pageControl.dataSource = self
        pageControl.transformer = FSPagerViewTransformer(type: .overlap)
        
        pageControl.itemSize = CGSize(width: (pageControl.frame.width - 50), height: pageControl.frame.height)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            pageControl.scrollToItem(at: selectedSongIndex, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.setGradient()
            }
            
        }
        
        
}
    
    func getTime(currenTime: Bool = false) -> String {
        let durartionSecond = Int((currenTime ? songListDelegate?.audioPlayer?.currentTime : songListDelegate?.audioPlayer?.duration) ?? 0)
            let second = durartionSecond % 60
            let secondString = second < 10 ? "0\(second)" : "\(second)"
            let minute = durartionSecond / 60
            return "\(minute):\(secondString)"
        }
    
    var timer: Timer?
    
    func figureOutProgress() {
            
        let totalDuration =  songListDelegate?.audioPlayer?.duration
        lbl_TotalTime.text = getTime()
            
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timerCurrent in
                guard let self = self else { return }
                let currentDuration = songListDelegate?.audioPlayer?.currentTime
                let percentageDuration = (currentDuration ?? 0.0) * 100 / (totalDuration ?? 0.0)
                progressBar.progress = Float(percentageDuration) / 100
               
                timer = timerCurrent
                lbl_currentTime.text = getTime(currenTime:true)
            }
        }
    
    func resetTimer(isNewSong: Bool = true) {
            
            if isNewSong {
                
                timer?.invalidate()
                lbl_currentTime.text = "0:0"
                lbl_TotalTime.text = "0:0"
                timer = nil
                
            } else {
            
                if songListDelegate?.play == true {
                    figureOutProgress()
                } else {
                    timer?.invalidate()
                }
            }
            
        }
    
    
    
    @objc func handleSwipe() {
        resetTimer()
        dismiss(animated: true) {
            self.songListDelegate?.currentSongIndex = self.selectedSongIndex
            self.songListDelegate?.setUpSongStrip()
            
            if self.songListDelegate?.play == true {
                self.songListDelegate?.img_PlayPauseStrip.image = UIImage(named: "Pause")
                
            } else {
                self.songListDelegate?.img_PlayPauseStrip.image = UIImage(named: "Playbtn")
            }
            self.songListDelegate?.stripColor = self.currentColor
            self.songListDelegate?.view_StipBackGround.backgroundColor = self.currentColor
        }
    }
    
    
    func setGradient() {

        var color1 = getColor(iscolor1: true)
        self.view.backgroundColor = color1
        currentColor = color1
        return
        var color2 = getColor(iscolor1: false)
        print(color1, "gfchgcj")
        
        gradient.removeFromSuperlayer()
        gradient.colors = [color1, color2]
        gradient.locations = [0.0 , 1.0]
                            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
                            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
    }
    
    
    func getColor(iscolor1: Bool) -> UIColor {
        let cell = pageControl.cellForItem(at: selectedSongIndex)
        var color: UIColor?
        
        if let imageView = cell?.imageView, 
            let image = imageView.image {
            let colo = image.getPixelColor(pos: iscolor1 ?  CGPoint(x: 5, y: 5) : CGPoint(x: imageView.frame.width - 10, y: imageView.frame.height - 10) )
            color = colo
            print("colorr", colo, "colorr")
        }
        return color ?? .brown
    }
    
    
    func popTheVC() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func playButtonTapped(_ sender: Any) {
        songListDelegate?.playPauseTapped()
    }
    
    
    @IBAction func backwardButtonTappped(_ sender: Any) {
        if selectedSongIndex != 0 {
            pageControl.scrollToItem(at: selectedSongIndex - 1, animated: true)
            selectedSongIndex = selectedSongIndex - 1
            songListDelegate?.playTheSong(songUrl: songsListObject?.data[selectedSongIndex].url ?? "")
            lbl_SongName.text = songsListObject?.data[selectedSongIndex].name
            lbl_ArtistNAme.text = songsListObject?.data[selectedSongIndex].artist
            figureOutProgress()
            if songListDelegate?.play == false {
                songListDelegate?.play = true
                img_PlayPause.image = UIImage(named: "Pause")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.setGradient()
            }
            resetTimer()
        }
    }
    
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if selectedSongIndex < songsListObject?.data.count ?? 0 {
            
            pageControl.scrollToItem(at: selectedSongIndex + 1, animated: true)
            selectedSongIndex = selectedSongIndex + 1
            songListDelegate?.playTheSong(songUrl: songsListObject?.data[selectedSongIndex].url ?? "")
            lbl_SongName.text = songsListObject?.data[selectedSongIndex].name
            lbl_ArtistNAme.text = songsListObject?.data[selectedSongIndex].artist
            figureOutProgress()
            if songListDelegate?.play == false {
                songListDelegate?.play = true
                img_PlayPause.image = UIImage(named: "Pause")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.setGradient()
            }
            resetTimer()

        }
        
    }
    
   
}



extension MediaViewController : FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        songsListObject?.data.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let imageURL = URL(string: "\(coverImageBaseUrl)\(songsListObject?.data[index].cover ?? "")")
        cell.imageView?.kf.setImage(with: imageURL)
        return cell
    }
    
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        selectedSongIndex = pagerView.currentIndex
        songListDelegate?.playTheSong(songUrl: songsListObject?.data[selectedSongIndex].url ?? "")
        lbl_SongName.text = songsListObject?.data[selectedSongIndex].name
        lbl_ArtistNAme.text = songsListObject?.data[selectedSongIndex].artist
        figureOutProgress()
        if songListDelegate?.play == false {
            songListDelegate?.play = true
            img_PlayPause.image = UIImage(named: "Pause")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.setGradient()
        }    }
    
    
}


extension UIImage {
      
      func getPixelColor(pos: CGPoint) -> UIColor? {
          
          
          if let pixelData = self.cgImage?.dataProvider?.data {
              let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
              
              let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
              
              let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
              let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
              let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
              let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
              
              return UIColor(red: r, green: g, blue: b, alpha: a)
          }
          
          return nil
      }
  }

