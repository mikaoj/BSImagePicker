// The MIT License (MIT)
//
// Copyright (c) 2021 Mithilesh Parmar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

protocol AutorizationStatusHeaderViewDelegate: class {
    func didTapManageButton(for status: PHAuthorizationStatus)
}

class AutorizationStatusHeaderView : UICollectionReusableView {
    static let id = "PHAutorizationHeaderView"
    
    weak var delegate: AutorizationStatusHeaderViewDelegate?
    
    @UsesAutoLayout
    private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 3
        return lbl
    }()
    
    @UsesAutoLayout
    private var manageButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    var buttonText: String? {
        didSet{
            manageButton.setTitle(buttonText, for: .normal)
        }
    }
    
    var buttonTextColor: UIColor? {
        didSet{
            manageButton.setTitleColor(buttonTextColor, for: .normal)
        }
    }
    
    
    
    var permissionDeniedText: String?
    var permissionDeniedBackgroundColor: UIColor?
    var permissionDeniedTextColor: UIColor?
    
    var limitedPermissionGrantedText: String?
    var limitedPermissionBackgroundColor: UIColor?
    var limitedPermissionTextColor: UIColor?
    
    var authorizationStatus: PHAuthorizationStatus?{
        didSet {
            guard let status = authorizationStatus else { return }
            switch status {
            case .denied:
                titleLabel.text = permissionDeniedText
                titleLabel.textColor = permissionDeniedTextColor
                backgroundColor = permissionDeniedBackgroundColor
                layoutIfNeeded()
                break
            case .limited:
                titleLabel.text = limitedPermissionGrantedText
                titleLabel.textColor = limitedPermissionTextColor
                backgroundColor = limitedPermissionBackgroundColor
                layoutIfNeeded()
                break
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        constraintLayout()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        addSubview(titleLabel)
        addSubview(manageButton)
    }
    
    private func constraintLayout(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.manageButton.leadingAnchor, constant: -8),
            
            manageButton.topAnchor.constraint(equalTo: self.topAnchor),
            manageButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            manageButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 8),
            manageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            manageButton.widthAnchor.constraint(greaterThanOrEqualToConstant: manageButton.runtimeSize().width)
            
            
        ])
    }
    
    private func addTargets(){
        manageButton.addTarget(self, action: #selector(didTapManage), for: .touchUpInside)
    }
    
    @objc func didTapManage(){
        guard let status = authorizationStatus else { return }
        delegate?.didTapManageButton(for: status)
    }
    
}
