//
//  GalleryViewController.swift
//


import UIKit
import PKHUD
import Rswift
import AlamofireImage
import BubbleTransition

class GalleryViewController: UIViewController {

    @IBOutlet weak var galleryCollectionView: UICollectionView!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private let refreshControl = UIRefreshControl()
    private let transition = BubbleTransition()
    private var cellLocation: CGPoint!
    
    fileprivate var isThumbnailsMode = false
    fileprivate var shownIndexes : [IndexPath] = []
    
    var galleryPhotos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.systemActivity)
        let layout = galleryCollectionView.collectionViewLayout as! CollectionLayout
        layout.delegate = self
        setGalleryMode()
        addButtonsToNavigationBar()
        InstagramApiProvider.shared.delegate = self
        InstagramApiProvider.shared.getUserPhotos()
        registerCell()
        styleUI()
        toAddRefreshControll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }

    //MARK: - Private Method
    
    // Adds logout and displaymopde buttons
    private func addButtonsToNavigationBar() {
        let modeButton = UIBarButtonItem(title: R.string.localizable.thumbnail(), style: .plain, target: self, action: #selector(changeGalleryStyle(_:)))
        modeButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let logoutButton = UIBarButtonItem(title: R.string.localizable.logout(), style: .plain, target: self, action: #selector(logoutAction(_:)))
        logoutButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationItem.rightBarButtonItem  = modeButton
        navigationItem.leftBarButtonItem  = logoutButton
    }
    
    //Stylize UI
    private func styleUI() {
        
        activityIndicatorView.startAnimating()
        navigationController?.navigationBar.isHidden = false
        navigationItem.setHidesBackButton(true, animated: false)
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.font:R.font.billabong(size: 33)!]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        title = R.string.localizable.instagram()
        navigationController?.navigationBar.applyNavigationGradient(colors: [UIColor.purpleColor , UIColor.orangeColor])
    }
    
    // Adds refreshContoll to galleryCollectionView
    private func toAddRefreshControll() {
        
        if #available(iOS 10.0, *) {
            galleryCollectionView.refreshControl = refreshControl
        } else {
            galleryCollectionView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    // Register photoCollectionViewCell for galleryCollectionView
    private func registerCell() {
        galleryCollectionView.register(R.nib.photoCollectionViewCell)
    }
    
    // Calculate the haight for item
    private func heightCalculate(_ imageWidth: CGFloat, imageHeight: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let layout = galleryCollectionView.collectionViewLayout as! CollectionLayout
        let numberColums = layout.numberOfColums
        let height = (screenWidth/CGFloat(numberColums)/imageWidth) * imageHeight
        return height
    }
    
    @objc private func refreshData(_ sender: Any) {
        InstagramApiProvider.shared.getUserPhotos()
    }
    
    func setGalleryMode() {
        let layout = galleryCollectionView.collectionViewLayout as! CollectionLayout
        if isThumbnailsMode {
            navigationItem.rightBarButtonItem?.title = R.string.localizable.custom()
            layout.numberOfColums = 4
        } else {
            layout.numberOfColums = 2
            navigationItem.rightBarButtonItem?.title = R.string.localizable.thumbnail()
        }
    }
    
    //MARK: - Actions
    
    @objc func logoutAction(_ sender: Any) {
        InstagramApiProvider.shared.logout()
    }
    
    @objc func changeGalleryStyle(_ sender: Any) {
        if isThumbnailsMode {
            isThumbnailsMode = false
        } else {
            isThumbnailsMode = true
        }
        setGalleryMode()
        galleryCollectionView.reloadData()
        galleryCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}

//MARK: - Collection View Data Source
extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryPhotos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if (shownIndexes.contains(indexPath) == false) {
            shownIndexes.append(indexPath)
        
            cell.transform = CGAffineTransform(translationX: 0, y: 0)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0.02 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCollectionViewCell, for: indexPath)
        let photos = galleryPhotos[indexPath.row]
        var image = photos.lowResolutionPhotos
        if isThumbnailsMode {
            image = photos.thumbnailPhotos
        }
        if let photoUrl = image?.url, let url = URL(string: photoUrl) {
            cell?.imageView.af_setImage(withURL: url)
        }
        
        cell?.scrollView.isUserInteractionEnabled = false
        
        return cell ?? UICollectionViewCell()

    }
}

//MARK: - Collection View Delegate
extension GalleryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let controller = PhotoLibraryViewController()
        controller.photos = galleryPhotos
        controller.selectedPhoto = indexPath.row + 1
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        cellLocation = cell?.center
        present(controller, animated: true)
    }
}

//MARK: - Instagram Api Provider Delegate
extension GalleryViewController: InstagramApiProviderDelegate {
    
    func didFetchedUserPhotos(_ provider: InstagramApiProvider, userPhotos photos: [Photo], requestError error: Error?) {
        HUD.hide()
        if error != nil {
            showAlertWithError(error: error, title: nil)
            return
        }
        refreshControl.endRefreshing()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
        galleryPhotos = photos
        shownIndexes = [IndexPath]()
        galleryCollectionView.reloadData()
        galleryCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func didLogout() {
        if let navigation = navigationController, !navigation.viewControllers.contains(LoginViewController()) {
            navigation.setViewControllers([LoginViewController(), self], animated: false)
        }
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Collection Layout Delegate
extension GalleryViewController: CollectionLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat {
        let photos = galleryPhotos[indexPath.row]
        var image = photos.lowResolutionPhotos
        if isThumbnailsMode {
           image = photos.thumbnailPhotos
        }
        let imageHeight = image?.height
        let imageWidth = image?.width
        let height = heightCalculate(CGFloat(imageWidth!), imageHeight: CGFloat(imageHeight!))
        
        return height
    }

}

//MARK: - UIViewControllerTransitioningDelegate
extension GalleryViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = cellLocation
        presented.view.frame = UIScreen.main.bounds;
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.transitionMode = .dismiss
        transition.startingPoint = cellLocation
        return transition
    }
}
