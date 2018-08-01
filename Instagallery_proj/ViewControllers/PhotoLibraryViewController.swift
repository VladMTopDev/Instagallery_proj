//
//  PhotoLibraryViewController.swift
//


import UIKit
import AlamofireImage

class PhotoLibraryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    public var photos = [Photo]()
    public var selectedPhoto: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.startAnimating()
        
        registerCell()
        toAddGestureOnAvatar()
        didTapOnImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        numberOfImagesLabel.text = String("<\(selectedPhoto!)/\(photos.count)>")
        collectionView.scrollToItem(at: IndexPath(row: selectedPhoto - 1, section: 0), at: .centeredHorizontally, animated: false)
        loadingView.isHidden = true
    }
    
    //MARK: - Private Methods
    private func toAddGestureOnAvatar() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage))
        collectionView.addGestureRecognizer(gesture)
    }
    
    // Register photoCollectionViewCell for collectionView
    private func registerCell() {
        collectionView.register(R.nib.photoCollectionViewCell)
    }
}

//MARK: - Action
extension PhotoLibraryViewController {

    // Close photo full screen mode
    @IBAction func didTapCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // Add animation for didTapOnImage
    @objc private func didTapOnImage() {

        topView.animationView()
        bottomView.animationView()

        if topView.isHidden {
            topView.isHidden = false
            bottomView.isHidden = false
            collectionView.backgroundColor = .white
            view.backgroundColor = topView.backgroundColor
            UIApplication.shared.statusBarStyle = .default
        } else {
            topView.isHidden = true
            bottomView.isHidden = true
            collectionView.backgroundColor = .black
            view.backgroundColor = .black
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
}

//MARK: - Collection View Delegate Flow Layout
extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.bounds.size.height
        let width = collectionView.bounds.size.width
        return CGSize(width: width, height: height)
    }
}

//MARK: - Collection View Data Source
extension PhotoLibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.photoCollectionViewCell, for: indexPath)
        
        let photo = photos[indexPath.row]
        if let photoUrl = photo.lowResolutionPhotos?.url, let url = URL(string: photoUrl) {
            cell?.imageView.af_setImage(withURL: url)
        }
        cell?.imageView.contentMode = .scaleAspectFit
        cell?.scrollView.isUserInteractionEnabled = true
        
        return cell ?? UICollectionViewCell()
    }
}

//MARK: - Scroll View Delegate
extension PhotoLibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let index = scrollView.contentOffset.x / scrollView.bounds.size.width
        numberOfImagesLabel.text = String("<\(Int(index+1))/\(photos.count)>")
    }
}

