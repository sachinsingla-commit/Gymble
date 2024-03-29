//
//  GymDetailsViewController.swift
//  Gymble
//
//  Created by Sachin's Macbook Pro on 19/08/20.
//  Copyright © 2020 Sachin's Macbook Pro. All rights reserved.
//
import UIKit
import Alamofire
import Firebase
import FirebaseAuth

class GymDetailsViewController: UIViewController,
UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    var userData: User?
    var gymID: String = ""
    var gymDetails: GymDetails?
    let rightNow = Date()
    let uid = Auth.auth().currentUser?.uid
    fileprivate let buyMembershipButton: LoadingButton = {
        let button = LoadingButton(type: .system)
        button.layer.cornerRadius = 5
        button.tintColor = .white
        button.setTitle("Get membership", for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 20)
        button.setGradientBackground(colorOne: Colors.mainRed, colorTwo: Colors.mainOrange)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(processPayment), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    fileprivate let heroImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.layer.cornerRadius = 5
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = Colors.mainBlack
        cv.register(HeroCollectionViewCell.self, forCellWithReuseIdentifier: "Hero")
        return cv
    }()
    
    fileprivate lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = Colors.mainOrange
        pc.hidesForSinglePage = true
        pc.pageIndicatorTintColor = UIColor.darkGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    fileprivate lazy var gymDetailsMenu: GymDetailsMenuBar = {
        let gymDetailsMenu = GymDetailsMenuBar()
        gymDetailsMenu.gymDetailsCollectionViewMenuController = self
        gymDetailsMenu.translatesAutoresizingMaskIntoConstraints = false
        return gymDetailsMenu
    }()
    
    fileprivate let tabsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isUserInteractionEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.register(OverviewCell.self, forCellWithReuseIdentifier: "Tabs")
        cv.register(AmenitiesCell.self, forCellWithReuseIdentifier: "AmenitiesCell")
        cv.register(TimingsCell.self, forCellWithReuseIdentifier: "TimingsCell")
        cv.register(TrainersCell.self, forCellWithReuseIdentifier: "TrainersCell")
        cv.isPagingEnabled = true
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        view.backgroundColor = .black
        buyMembershipButtonLayout()
        collectionViewDelegates()
        heroCollectionViewLayout()
        gymDetailsMenuLayout()
        tabsCollectionViewLayout()
        fetchGymData()
        setupPageControl()
    }
    
    private func setupPageControl(){
        view.addSubview(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: heroImagesCollectionView.bottomAnchor, constant: -2).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: heroImagesCollectionView.centerXAnchor).isActive = true
    }
    
    func fetchGymData(){
        APIServices.sharedInstance.getGymDetails(gymID: gymID) { (gymDetailsData) in
            self.gymDetails = gymDetailsData
            self.tabsCollectionView.reloadData()
            self.heroImagesCollectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tabsCollectionView{
            gymDetailsMenu.menuBarSliderLeftAnchor?.constant = scrollView.contentOffset.x / 4
        }
        if scrollView == heroImagesCollectionView{
            let scrollPos = scrollView.contentOffset.x / heroImagesCollectionView.frame.width
            pageControl.currentPage = Int(scrollPos)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == tabsCollectionView{
            let scrollToIndex = targetContentOffset.pointee.x / view.frame.size.width
            gymDetailsMenu.gymDetailsCollectionViewMenu.selectItem(at: IndexPath(item: Int(scrollToIndex), section: 0), animated: true, scrollPosition: [])
        }
        
    }
    
    func scrollToGymDetailsMenuIndex(index: Int){
        tabsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: true)
    }
    
    private func collectionViewDelegates(){
        heroImagesCollectionView.delegate = self
        heroImagesCollectionView.dataSource = self
        tabsCollectionView.delegate = self
        tabsCollectionView.dataSource = self
    }
    
    private func heroCollectionViewLayout(){
        view.addSubview(heroImagesCollectionView)
        let height = view.frame.size.width * 9 / 16
        heroImagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        heroImagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        heroImagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        heroImagesCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func tabsCollectionViewLayout(){
        view.addSubview(tabsCollectionView)
        tabsCollectionView.topAnchor.constraint(equalTo: gymDetailsMenu.bottomAnchor, constant: 5).isActive = true
        tabsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabsCollectionView.bottomAnchor.constraint(equalTo: buyMembershipButton.topAnchor, constant: -10).isActive = true
    }
    
    private func gymDetailsMenuLayout(){
        view.addSubview(gymDetailsMenu)
        gymDetailsMenu.topAnchor.constraint(equalTo: heroImagesCollectionView.bottomAnchor).isActive = true
        gymDetailsMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gymDetailsMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gymDetailsMenu.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func buyMembershipButtonLayout(){
        view.addSubview(buyMembershipButton)
        buyMembershipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        buyMembershipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buyMembershipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        buyMembershipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    @objc func processPayment(){
        let membershipListVC = MembershipListViewController()
        membershipListVC.gymID = gymID
        navigationController?.pushViewController(membershipListVC, animated: true)
    }
    
    func fetchUserData(){
        guard let userID = Auth.auth().currentUser?.uid else {return}
        APIServices.sharedInstance.fetchUserData(uid: userID) { (userData) in
            self.userData = userData
        }
    }
}

extension GymDetailsViewController{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = FullScreenImageViewController()
        if collectionView == heroImagesCollectionView{
            fullScreenVC.gymID = gymID
            self.present(fullScreenVC, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tabsCollectionView{
            return 4
        }else{
            if let count = gymDetails?.images_array?.count{
                pageControl.numberOfPages = count
                return count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tabsCollectionView{
            if indexPath.item == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tabs", for: indexPath) as! OverviewCell
                cell.gymDetails = gymDetails
                return cell
            }
            else if indexPath.item == 1{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmenitiesCell", for: indexPath) as! AmenitiesCell
                cell.gymDetails = gymDetails
                return cell
            }
            else if indexPath.item == 3{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimingsCell", for: indexPath) as! TimingsCell
                cell.gymTimings = gymDetails
                return cell
            }
            else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainersCell", for: indexPath) as! TrainersCell
                cell.trainerData = gymDetails
                return cell
            }
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Hero", for: indexPath) as! HeroCollectionViewCell
            if let imageURL = gymDetails?.images_array?[indexPath.item].image{
                cell.heroImageView.loadImageUsingUrlString(urlString: imageURL)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tabsCollectionView{
            
            return CGSize(width: tabsCollectionView.frame.size.width, height: tabsCollectionView.frame.size.height)
        }else{
            return CGSize(width: heroImagesCollectionView.frame.size.width, height: heroImagesCollectionView.frame.size.height)
        }
    }
}

class HeroCollectionViewCell: UICollectionViewCell {
    let heroImageView: CustomImageView = {
        let image = CustomImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 5
        image.backgroundColor = Colors.mainBlack
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        heroImageLayout()
    }
    
    private func heroImageLayout(){
        addSubview(heroImageView)
        heroImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        heroImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        heroImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        heroImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
