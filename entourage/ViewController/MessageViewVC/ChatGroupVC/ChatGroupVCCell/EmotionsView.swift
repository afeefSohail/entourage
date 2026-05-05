//
//  EmotionView.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/23/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


class EmotionsView: UIView, InputItem, UICollectionViewDataSource , UICollectionViewDelegate{
    
    var inputBarAccessoryView: InputBarAccessoryView?
    
    
    func keyboardSwipeGestureAction(with gesture: UISwipeGestureRecognizer) {
        
    }
    
    
    
    private var emotions = [ChatMessageEmoticon]()
    @IBOutlet weak var emotionsStreakView: UICollectionView!
    public var onClickedCallback: ((_ emotion: ChatMessageEmoticon) -> Void)?
    var parentStackViewPosition: InputStackView.Position?
    
    
    public func updateEmotions(emotions:[ChatMessageEmoticon]){
        
        self.emotions = emotions
        self.emotionsStreakView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emotions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatGroupVCEmotionCell", for: indexPath) as! ChatGroupVCEmotionCell
        let emotion = self.emotions[indexPath.item]
        cell.emotionIV.image = emotion.image
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let callback = self.onClickedCallback else {
            return
        }
        let emotion = self.emotions[indexPath.item]
        callback(emotion)
    }
    
    func textViewDidChangeAction(with textView: InputTextView) {
        
    }
    
    func keyboardEditingEndsAction() {
        
    }
    
    func keyboardEditingBeginsAction() {
        
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
    
    
}
