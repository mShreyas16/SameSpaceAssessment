//
//  ViewController.swift
//  SamespaceAssignment
//
//  Created by Shreyas Mandhare on 16/01/24.
//

import UIKit
import AVFoundation
import Kingfisher



//MARK: TableView Cell Class
class SongListCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var img_SongThumbNail: UIImageView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_BandName: UILabel!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}



class ViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var lbl_ForYou: UILabel!
    @IBOutlet weak var img_ForYou: UIImageView!
    @IBOutlet weak var lbl_TopTracks: UILabel!
    @IBOutlet weak var img_TopTracks: UIImageView!
    @IBOutlet weak var view_StipBackGround: UIView!
    @IBOutlet weak var imgSong_Strip: UIImageView!
    @IBOutlet weak var lbl_currentSongNameStrip: UILabel!
    @IBOutlet weak var img_PlayPauseStrip: UIImageView!
    @IBOutlet weak var tblView_SongList: UITableView!
    @IBOutlet weak var height_Strip: NSLayoutConstraint!
    @IBOutlet weak var view_imgStrip: UIView!
    
    
    //MARK: Properties
    var songListData : SongListModel?
    var viewModel = SongListViewModel()
    var audioPlayer: AVAudioPlayer?
    let coverImageBaseUrl = "https://cms.samespace.com/assets/"
    var imageArray = [UIImage]()
    var play = true
    var mediaViewC: MediaViewController?
    var currentTabSelected = 1
    var topTracks: SongListModel?
    var forYouData: SongListModel?
    var currentSongIndex = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpDirectory()
        getData()
        setupTabs()
        bindThedata()
        
    }
    
    
    func setupUI() {
        height_Strip.constant = 0
        lbl_currentSongNameStrip.alpha = 0
        lbl_currentSongNameStrip.isHidden = true
        imgSong_Strip.layer.cornerRadius = view_imgStrip.frame.height/2 + 5
    }
    
    
    func bindThedata() {
        viewModel.bindData = { serviceResponse in
            if serviceResponse == .success {
                self.songListData = self.viewModel.songListData
                self.forYouData = self.viewModel.songListData
                self.topTracks = self.viewModel.songListData
                
                let temp = self.topTracks?.data.filter{
                    $0.topTrack == true
                }
                self.topTracks?.data = temp ?? [Datum]()
                DispatchQueue.main.async {
                    self.tblView_SongList.reloadData()
                }
            } else {
                print("Going to Show Alert here.")
            }
            
        }
    }
    
    
    func setupTabs() {
        if currentTabSelected == 1{
            lbl_ForYou.textColor = .white
            lbl_TopTracks.textColor = .gray
            img_ForYou.alpha = 1
            img_ForYou.isHidden = false
            img_TopTracks.alpha = 0
            img_TopTracks.isHidden = true
        } else {
            lbl_ForYou.textColor = .gray
            lbl_TopTracks.textColor = .white
            img_ForYou.alpha = 0
            img_ForYou.isHidden = true
            img_TopTracks.alpha = 1
            img_TopTracks.isHidden = false
        }
    }
    
    func setUpDirectory() {
        setupDelegate()
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent("tSong.mp3")
        
    }
    
    func setUpSongStrip() {
        print("insidee")
        height_Strip.constant = 60
        lbl_currentSongNameStrip.alpha = 1
        lbl_currentSongNameStrip.isHidden = false
        let imageURL = URL(string: "\(coverImageBaseUrl)\(songListData?.data[currentSongIndex].cover ?? "")")
        self.imgSong_Strip.kf.setImage(with: imageURL)
        self.lbl_currentSongNameStrip.text = songListData?.data[currentSongIndex].name
    }
    
    func setupDelegate() {
        tblView_SongList.delegate = self
        tblView_SongList.dataSource = self
        
    }
    
    func getData() {
        viewModel.getData()
    }
    
    
    func playPauseTapped() {
        if play {
            audioPlayer?.pause()
            mediaViewC?.img_PlayPause.image = UIImage(named: "Playbtn")
            play.toggle()
        } else {
            audioPlayer?.play()
            mediaViewC?.img_PlayPause.image = UIImage(named: "Pause")
            play.toggle()
        }
        mediaViewC?.resetTimer(isNewSong: false)
    }
    
    func playTheSong(songUrl:String) {
        
        if !songUrl.isEmpty{
            checkBookFileExists(withLink: songUrl){ [weak self] downloadedURL in
                guard let self = self else {
                    
                    return
                }
                play(url: downloadedURL)
            }
        }
        
    }
    
   
    
    
    
    
    
    @IBAction func tabForYouTapped(_ sender: Any) {
        
        songListData = forYouData
        currentTabSelected = 1
        tblView_SongList.reloadData()
        setupTabs()
        
    }
    
    @IBAction func tabTopPickstapped(_ sender: Any) {
        
        songListData = topTracks
        currentTabSelected = 2
        tblView_SongList.reloadData()
        setupTabs()
    }
    
    @IBAction func playPauseButtonTappedStrip(_ sender: Any) {
        if play {
            audioPlayer?.pause()
            mediaViewC?.img_PlayPause.image = UIImage(named: "Playbtn")
            img_PlayPauseStrip.image = UIImage(named: "Playbtn")
            play.toggle()
        } else {
            audioPlayer?.play()
            mediaViewC?.img_PlayPause.image = UIImage(named: "Pause")
            img_PlayPauseStrip.image = UIImage(named: "Pause")

            play.toggle()
        }
    }
    
    @IBAction func tappedOnStrip(_ sender: Any) {
        let mediaVC = storyboard?.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        
        mediaVC.songsListObject = songListData
        mediaVC.selectedSongIndex = currentSongIndex
        mediaVC.imageArray = self.imageArray
        mediaVC.songListDelegate = self
        mediaViewC = mediaVC
        mediaVC.modalPresentationStyle = .fullScreen
        self.present(mediaVC, animated: true)
        audioPlayer?.play()
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songListData?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongListCell", for: indexPath) as! SongListCell
        
        cell.img_SongThumbNail.backgroundColor = UIColor.red
        cell.img_SongThumbNail.layer.cornerRadius = cell.img_SongThumbNail.frame.height/2
        cell.img_SongThumbNail.clipsToBounds = true
        
        cell.lbl_Title.text = songListData?.data[indexPath.row].name
        cell.lbl_BandName.text = songListData?.data[indexPath.row].artist
        let imageURL = URL(string: "\(coverImageBaseUrl)\(songListData?.data[indexPath.row].cover ?? "")")
        cell.img_SongThumbNail.kf.setImage(with: imageURL)
        imageArray.append(cell.img_SongThumbNail.image ?? UIImage())
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let mediaVC = storyboard?.instantiateViewController(withIdentifier: "MediaViewController") as! MediaViewController
        
        mediaVC.songsListObject = songListData
        mediaVC.selectedSongIndex = indexPath.row
        mediaVC.imageArray = self.imageArray
        mediaVC.songListDelegate = self
        mediaViewC = mediaVC
        mediaVC.modalPresentationStyle = .fullScreen
        self.present(mediaVC, animated: true)
        
        let songURL = songListData?.data[indexPath.row].url ?? ""
        playTheSong(songUrl: songURL)
        mediaViewC?.figureOutProgress()
        
    }
    
}


//Audio Download
extension ViewController: AVAudioPlayerDelegate {
    
    
    
    func play(url: URL) {
        print("playing \(url)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            let percentage = (audioPlayer?.currentTime ?? 0)/(audioPlayer?.duration ?? 0)
            DispatchQueue.main.async {
                
                print(percentage, "PErcentageggg")
            }
            
        } catch let error {
            audioPlayer = nil
        }
        
    }
    
    
    
    func downloadFile(withUrl url: URL, andFilePath filePath: URL, completion: @escaping ((_ filePath: URL)->Void)){
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: filePath, options: .atomic)
                print("saved at \(filePath.absoluteString)")
                DispatchQueue.main.async {
                    completion(filePath)
                }
            } catch {
                print("an error happened while downloading or saving the file")
            }
        }
    }
    
    
    func checkBookFileExists(withLink link: String, completion: @escaping ((_ filePath: URL)->Void)) {
        let urlString = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        if let url  = URL.init(string: urlString ?? ""){
            let fileManager = FileManager.default
            if let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: false){
                
                let filePath = documentDirectory.appendingPathComponent(url.lastPathComponent, isDirectory: false)
                
                do {
                    if try filePath.checkResourceIsReachable() {
                        print("file exist")
                        completion(filePath)
                        
                    } else {
                        print("file doesnt exist")
                        downloadFile(withUrl: url, andFilePath: filePath, completion: completion)
                    }
                } catch {
                    print("file doesnt exist")
                    downloadFile(withUrl: url, andFilePath: filePath, completion: completion)
                }
            }else{
                print("file doesnt exist")
            }
        }else{
            print("file doesnt exist")
        }
    }
    
}

