//
//  QuranPageCollectionViewCell.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/22/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import UIKit
import AVFoundation

private let imageHeightDiff: CGFloat = 34

protocol QuranPageCollectionCellDelegate: class {
    func quranPageCollectionCell(_ collectionCell: QuranPageCollectionViewCell, didSelectAyahTextToShare ayahText: String)
}

class QuranPageCollectionViewCell: UICollectionViewCell, HighlightingViewDelegate {

    @IBOutlet weak var juzLabel: UILabel!
    @IBOutlet weak var suraLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!

    @IBOutlet weak var highlightingView: HighlightingView!
    @IBOutlet weak var mainImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!
    weak var cellDelegate: QuranPageCollectionCellDelegate?

    var page: QuranPage? {
        didSet {
            highlightingView.page = page?.pageNumber ?? 0
        }
    }
    var sizeConstraints: [NSLayoutConstraint] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.backgroundColor = UIColor.readingBackground()
        self.highlightingView.delegate = self
        setupLongPressGestureRecognizer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.contentOffset = CGPoint.zero
        highlightingView.reset()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        sizeConstraints.forEach { mainImageView.removeConstraint($0) }
        sizeConstraints.removeAll()

        let imageViewHeight: CGFloat
        if let imageSize = mainImageView.image?.size, bounds.width > bounds.height {
            // add fill height
            imageViewHeight = bounds.width * (imageSize.height / imageSize.width)

        } else {
            // add fit height
            imageViewHeight = bounds.height - imageHeightDiff
        }
        sizeConstraints.append(mainImageView.addHeightConstraint(imageViewHeight))

        let imageViewSize = CGSize(width: bounds.width, height: imageViewHeight)
        if let imageSize = mainImageView.image?.size {
            let scale: CGFloat
            if imageSize.width / imageSize.height < imageViewSize.width / imageViewSize.height {
                scale = imageViewSize.height / imageSize.height
            } else {
                scale = imageViewSize.width / imageSize.width
            }
            let deltaX = (imageViewSize.width - (scale * imageSize.width)) / 2
            let deltaY = (imageViewSize.height - (scale * imageSize.height)) / 2
            highlightingView.setScaleInfo(scale, xOffset: deltaX, yOffset: deltaY)
            scrollToHighlightedAyat()
        }
    }

    func setAyahInfo(_ ayahInfoData: [AyahNumber: [AyahInfo]]?) {
        highlightingView.ayahInfoData = ayahInfoData
        scrollToHighlightedAyat()
    }

    func highlightAyat(_ ayat: Set<AyahNumber>) {
        highlightingView.highlights[.reading] = ayat
        scrollToHighlightedAyat()
    }

    fileprivate func scrollToHighlightedAyat() {
        guard let rectangles = highlightingView.highlightingRectangles[.reading], !rectangles.isEmpty else {
            return
        }

        layoutIfNeeded()

        var union = rectangles[0]
        rectangles.forEach { union = union.union($0) }

        let contentOffset = max(0, min(union.minY - 60, scrollView.contentSize.height - scrollView.bounds.height))
        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
    }

    // MARK: - Gesture recognizer -
    fileprivate func setupLongPressGestureRecognizer() {

        // Long press gesture on verses to select
        self.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:))))
    }

    func onLongPress(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {
            let touchLocation = sender.location(in: self.highlightingView)
            _ = self.highlightingView.highlightVerseAtLocation(touchLocation)
        }
    }

    // MARK: - HighlightingViewDelegate -
    func highlightingView(_ highlightingView: HighlightingView, didShareAyahText ayahText: String) {
        if let delegate = self.cellDelegate {
            delegate.quranPageCollectionCell(self, didSelectAyahTextToShare: ayahText)
        }
    }
}
