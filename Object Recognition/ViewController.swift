//
//  ViewController.swift
//  Object Recognition
//
//  Created by David T on 1/12/21.
//

import UIKit
import AVKit
import Vision

final class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private lazy var observationLabel = UILabel()
    private lazy var confidenceLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video)
        else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)
        else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        cameraSetup(previewLayer: previewLayer)
        
        previewLayer.videoGravity = .resizeAspectFill
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model)
        else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
            
            guard let results = finishedRequest.results as? [VNClassificationObservation]
            else { return }
            
            guard let firstObservation = results.first
            else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.observationLabel.text = firstObservation.identifier
                self.confidenceLabel.text =  String(firstObservation.confidence * 100) + "%"
            }
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    fileprivate func cameraSetup(previewLayer: CALayer) {
        
        view.backgroundColor = #colorLiteral(red: 0.2455837131, green: 0.2441301048, blue: 0.2467051446, alpha: 1)
        let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurBackground.translatesAutoresizingMaskIntoConstraints = false
        blurBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurBackground.contentView)
        
        blurBackground.contentView.fillSuperview()
        
        let videoFrame = UIView()
        videoFrame.frame = CGRect(x: 0, y: 0, width: view.frame.width - 20, height: view.frame.height / 2 )
        videoFrame.backgroundColor = .clear
        
        let aboveView = UIView()
        aboveView.backgroundColor = .clear
        aboveView.layer.borderWidth = 1
        aboveView.layer.borderColor = UIColor.white.cgColor
        
        view.addSubview(videoFrame)

        videoFrame.center = CGPoint(x: view.frame.width / 2, y: (view.frame.height / 2) - 130)
        
        videoFrame.layer.addSublayer(previewLayer)
        
        previewLayer.frame = CGRect(x: 0, y: 0, width: videoFrame.frame.size.width, height: videoFrame.frame.size.height)
        
        videoFrame.addSubview(aboveView)
        
        aboveView.frame = CGRect(x: 0, y: 0, width: videoFrame.frame.size.width, height: videoFrame.frame.size.height)
        mutatingData(string: "gg", videoFrame: videoFrame)
    }
    
    fileprivate func mutatingData(string: String, videoFrame: UIView) {
        
        let sideLine = UIView()
        sideLine.backgroundColor = .white
        
        let sideLine1 = UIView()
        sideLine1.backgroundColor = .white
        
        let subLabel = UILabel()
        subLabel.textAlignment = .left
        subLabel.font = .systemFont(ofSize: 14)
        subLabel.textColor = #colorLiteral(red: 0.7059562802, green: 0.7017617226, blue: 0.7091819644, alpha: 1)
        subLabel.text = "Object"
        
        observationLabel.textAlignment = .left
        observationLabel.textColor = .white
        observationLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        
        let accuracySubLabel = UILabel()
        accuracySubLabel.textAlignment = .left
        accuracySubLabel.font = .systemFont(ofSize: 14)
        accuracySubLabel.textColor = #colorLiteral(red: 0.7059562802, green: 0.7017617226, blue: 0.7091819644, alpha: 1)
        accuracySubLabel.text = "Confidence"
        
        confidenceLabel.textAlignment = .left
        confidenceLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        confidenceLabel.textColor = .white
        
        view.addSubview(sideLine)
        sideLine.layout(top: videoFrame.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 14, left: 14, bottom: 0, right: 0), size: .init(width: 2, height: 42))
        
        view.addSubview(subLabel)
        view.addSubview(observationLabel)
        
        subLabel.layout(top: sideLine.topAnchor, leading: sideLine.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 10, bottom: 0, right: 0), size: .init(width: 80, height: 18))
        observationLabel.layout(top: subLabel.bottomAnchor, leading: subLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 4, left: 0, bottom: 0, right: 17), size: .init(width: 0, height: 22))
        
        view.addSubview(sideLine1)
        view.addSubview(accuracySubLabel)
        view.addSubview(confidenceLabel)
        
        sideLine1.layout(top: sideLine.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 14, bottom: 0, right: 0), size: .init(width: 2, height: 42))
        
        accuracySubLabel.layout(top: sideLine1.topAnchor, leading: sideLine1.trailingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 0), size: .init(width: 60, height: 18))
        confidenceLabel.layout(top: accuracySubLabel.bottomAnchor, leading: accuracySubLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 4, left: 0, bottom: 0, right: 17), size: .init(width: 0, height: 22))
        
        let sessionPresset = UIButton()
        sessionPresset.translatesAutoresizingMaskIntoConstraints = false
        sessionPresset.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18)
        sessionPresset.setTitle("Session preset .photo", for: .normal)
        sessionPresset.setTitleColor(.white, for: .normal)
        sessionPresset.backgroundColor = .clear
        sessionPresset.layer.borderWidth = 1.3
        sessionPresset.layer.borderColor = UIColor.white.cgColor
        sessionPresset.layer.cornerRadius = 8
        
        view.addSubview(sessionPresset)
        sessionPresset.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sessionPresset.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -14).isActive = true
        sessionPresset.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sessionPresset.widthAnchor.constraint(equalToConstant: 180).isActive = true
    }
}



extension UIView {
    
    func fillSuperview() {
        layout(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorDimension(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func xyAnchors(x: NSLayoutXAxisAnchor?, y: NSLayoutYAxisAnchor?, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let x = x {
            centerXAnchor.constraint(equalTo: x).isActive = true
        }
        
        if let y = y {
            centerYAnchor.constraint(equalTo: y).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
    
    func layout(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
}
