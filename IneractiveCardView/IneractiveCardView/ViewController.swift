//
//  ViewController.swift
//  IneractiveCardView
//
//  Created by RK on 07/02/2021.
//

import UIKit


enum CardState {
    case expanded
    case collapsed
}


class ViewController: UIViewController {

    
    
    var cartViewController = CardViewController.storyboardInstance()
    var visualEffectView = UIVisualEffectView()
    
    let cardHeight : CGFloat = 600
    let cardHandlerAreaHeight : CGFloat = 65

    var cardVisible = false
    var nextState : CardState {
        return cardVisible ? .collapsed : .expanded
    }

    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupCard()
    }

    func setupCard() {

        self.visualEffectView.frame = self.view.frame
        self.view.addSubview(self.visualEffectView)
        
        // setting  here card View controller
        self.addChild(self.cartViewController)
        self.view.addSubview(cartViewController.view)
        
        cartViewController.view.frame = CGRect(x: 0, y: self.view.frame.size.height -  self.cardHandlerAreaHeight, width: self.view.frame.size.width, height: cardHeight)
        
        self.cartViewController.view.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleCardTap(recognizer:)))
        
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handleCardPan(recognizer:)))
        
        
        cartViewController.handlerArea.addGestureRecognizer(tapGesture)
        cartViewController.handlerArea.addGestureRecognizer(panGesture)
        
    }
    
    @objc  func  handleCardTap(recognizer:UITapGestureRecognizer)  {
        
        switch recognizer.state {
        case .ended:
            self.animateTranitionIfNeeded(state: nextState, duration: 0.9)
        default: break
        }
        
    }
    
    @objc  func  handleCardPan(recognizer:UIPanGestureRecognizer)  {
        
        switch recognizer.state {
        case .began:
            // start Transition
            self.startInteractiveTransition(state: nextState, duration: 0.9 )
        
        case .changed:
            // Update Transition
            
            let translation = recognizer.translation(in: self.cartViewController.handlerArea)
            var fractionComplete  = translation.y /  cardHeight
            
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            self.updateInterActiveTransition(fractionCompleted: fractionComplete)
        
        case .ended:
        // Continue Transition
            self.continueInterActiveTransition()
        
        default:break
        
            
        }
        
        
    }
    
    func animateTranitionIfNeeded(state : CardState, duration : TimeInterval) {
            
        if runningAnimations.isEmpty {
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                
                switch state {
                case .expanded :
                    self.cartViewController.view.frame.origin.y =  self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cartViewController.view.frame.origin.y =  self.view.frame.height - self.cardHandlerAreaHeight
                }
                
            }
            
            frameAnimator.addCompletion { (_) in
                
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
                
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                
                switch state {
                case .expanded:
                    
                    self.cartViewController.view.layer.cornerRadius = 12
                    
                case .collapsed:
                    self.cartViewController.view.layer.cornerRadius = 0
                }
                
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimation =  UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    
                case .collapsed:
                    self.visualEffectView.effect = nil
                }

            }
            blurAnimation.startAnimation()
            runningAnimations.append(blurAnimation)
        }
        
        
    }
    
    func startInteractiveTransition(state:CardState, duration : TimeInterval)  {
        
        if runningAnimations.isEmpty {
            //run animations
            animateTranitionIfNeeded(state: state, duration: duration)
        }
        
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted =  animator.fractionComplete
        }
        
     }
    
    func updateInterActiveTransition(fractionCompleted : CGFloat)      {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInterActiveTransition()      {
        
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
    
}

