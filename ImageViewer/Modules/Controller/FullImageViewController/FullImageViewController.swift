//
//  FullImageViewController.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    var viewState: ViewState? {
        didSet {
            viewStateChanged()
        }
    }
    
    var photo: Photo?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        self.viewState = .loading
        if let photo = photo {
            ImageManager.shared.downloadImage(imageURL: photo.originalImageURL) {[weak self] (imageURL, image) in
                DispatchQueue.main.async {
                    self?.viewState = .loaded
                    if let image = image {
                        self?.displayImageView.image = image
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK:- UIHelper
extension FullImageViewController {
    func configureView() {
        
    }
    
    func viewStateChanged() {
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self, let viewState = self?.viewState else {
                return
            }
            switch viewState {
            case .loaded:
                strongSelf.activityIndicatorView.isHidden = true
            case .loading:
                strongSelf.activityIndicatorView.startAnimating()
                strongSelf.activityIndicatorView.isHidden = false
            }
        }
    }
    
}

// MARK: - ZommImageDelegate Methods
extension FullImageViewController: ZoomImageDelegate {
    func zoomingImageView(for transition: ImageTransition) -> UIImageView? {
        return displayImageView
    }
    
}


