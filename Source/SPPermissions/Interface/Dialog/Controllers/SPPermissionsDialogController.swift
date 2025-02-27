// The MIT License (MIT)
// Copyright © 2019 Ivan Vorobei (ivanvorobei@icloud.com)
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

#if os(iOS)
/**
 Controller for Dialog interface.
 */
public class SPPermissionsDialogController: UIViewController, SPPermissionsControllerProtocol {
    
    public weak var dataSource: SPPermissionsDataSource?
    public weak var delegate: SPPermissionsDelegate?
    
    public var titleText: String = SPPermissionsText.titleText
    public var headerText: String = SPPermissionsText.subtitleShortText
    public var footerText: String = SPPermissionsText.commentText
    
    var dialogView = SPPermissionsDialogView()
    var backgroundView = SPPermissionsGradeBlurView()
    
    private var permissions: [SPPermission]
    
    init(_ permissions: [SPPermission]) {
        self.permissions = permissions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        
        dialogView.titleLabel.text = titleText
        dialogView.subtitleLabel.text = headerText.uppercased()
        
        dialogView.alpha = 0
        dialogView.tableView.dataSource = self
        dialogView.tableView.delegate = self
        dialogView.tableView.register(SPPermissionsDialogFooterCommentView.self, forHeaderFooterViewReuseIdentifier: SPPermissionsDialogFooterCommentView.id)
        dialogView.tableView.register(SPPermissionTableViewCell.self, forCellReuseIdentifier: SPPermissionTableViewCell.id)
        dialogView.closeButton.addTarget(self, action: #selector(self.dimissWithDialog), for: .touchUpInside)
        view.addSubview(dialogView)
        
        animator = UIDynamicAnimator(referenceView: view)
        snapBehavior = UISnapBehavior(item: dialogView, snapTo: dialogCenter)
        
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handleGesture(sender:)))
        panGesture.maximumNumberOfTouches = 1
        dialogView.addGestureRecognizer(panGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        dialogView.layout(in: view)
        snapBehavior.snapPoint = dialogCenter
    }
    
    /**
     Call this method for present controller on other controller.
     In this method controller configure.
     
     - parameter controller: Controller, on which need present `SPPermissions` controller.
     */
    public func present(on controller: UIViewController) {
        animator.removeAllBehaviors()
        dialogView.transform = .identity
        dialogView.center = CGPoint.init(x: dialogCenter.x, y: dialogCenter.y * 1.2)
        modalPresentationStyle = .overCurrentContext
        controller.present(self, animated: false, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.setGradeAlpha(0.07)
                self.backgroundView.setBlurRadius(4)
            }, completion: nil)
            UIView.animate(withDuration: 0.3, delay: 0.21, animations: {
                self.dialogView.alpha = 1
            }, completion: nil)
            SPPermissionsDelay.wait(0.21, closure: {
                self.animator.addBehavior(self.snapBehavior)
            })
        })
    }
    
    /**
     Dismiss animated.
     
     - parameter withDialog: Add dismiss animation also content area.
     */
    public func dismiss(withDialog: Bool) {
        if withDialog {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
                self.animator.removeAllBehaviors()
                self.dialogView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
                self.dialogView.alpha = 0
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.setGradeAlpha(0)
            self.backgroundView.setBlurRadius(0)
        }, completion: { finished in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func dimissWithDialog() {
        dismiss(withDialog: true)
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: {
            completion?()
            self.delegate?.didHide?()
        })
    }
    
    /**
     Update buttons when app launch again. No need call manually.
     */
    @objc func applicationDidBecomeActive() {
        for cell in dialogView.tableView.visibleCells {
            if let permissionCell = cell as? SPPermissionTableViewCell {
                permissionCell.button.update()
            }
        }
    }
    
    private var dialogCenter: CGPoint {
        let width = view.frame.width - view.layoutMargins.left - view.layoutMargins.right
        let height = view.frame.height - view.layoutMargins.top - view.layoutMargins.bottom
        return CGPoint(x: view.layoutMargins.left + width / 2, y: view.layoutMargins.top + height / 2)
    }
    
    /**
     Process tap permission button.
     */
    @objc func process(button: SPPermissionActionButton) {
        let permission = button.permission
        permission.request {
            button.update()
            let isAuthorized = permission.isAuthorized
            if isAuthorized {
                SPPermissionsHaptic.impact(.light)
            }
            isAuthorized ? self.delegate?.didAllow?(permission: permission) : self.delegate?.didDenied?(permission: permission)
            
            /**
             Update `.locationWhenInUse` if allowed `.locationAlwaysAndWhenInUse`
             */
            if permission == .locationAlwaysAndWhenInUse {
                if self.permissions.contains(.locationWhenInUse) {
                    if let index = self.permissions.firstIndex(of: .locationWhenInUse) {
                        if let cell = self.dialogView.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? SPPermissionTableViewCell {
                            cell.button.update()
                        }
                    }
                }
            }
            
            /**
             Check if all permissions allowed
             */
            let allowedPermissions = self.permissions.filter { $0.isAuthorized }
            if allowedPermissions.count == self.permissions.count {
                SPPermissionsDelay.wait(0.2, closure: {
                    self.dismiss(withDialog: true)
                })
            }
            
            /**
             Show alert with propose go to settings and allow permission. Can disable it in `SPPermissionsDataSource`.
             */
            if permission.isDenied {
                let data = self.dataSource?.data(for: permission)
                if (data?.showAlertOpenSettingsWhenPermissionDenied ?? true) {
                    let alertController = UIAlertController.init(
                        title: data?.alertOpenSettingsDeniedPermissionTitle ?? SPPermissionsText.alertOpenSettingsDeniedPermissionTitle,
                        message: data?.alertOpenSettingsDeniedPermissionDescription ?? SPPermissionsText.alertOpenSettingsDeniedPermissionDescription,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction.init(
                        title: data?.alertOpenSettingsDeniedPermissionCancelTitle ?? SPPermissionsText.alertOpenSettingsDeniedPermissionCancelTitle,
                        style: UIAlertAction.Style.cancel,
                        handler: nil)
                    )
                    alertController.addAction(UIAlertAction.init(
                        title: data?.alertOpenSettingsDeniedPermissionButtonTitle ?? SPPermissionsText.alertOpenSettingsDeniedPermissionButtonTitle,
                        style: UIAlertAction.Style.default,
                        handler: { (action) in
                            SPPermissionsOpener.openSettings()
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - Animator
    var animator = UIDynamicAnimator()
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    
    @objc func handleGesture(sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: view)
        let boxLocation = sender.location(in: dialogView)
        
        switch sender.state {
        case .began:
            animator.removeAllBehaviors()
            let centerOffset = UIOffset(horizontal: boxLocation.x - dialogView.bounds.midX, vertical: boxLocation.y - dialogView.bounds.midY);
            attachmentBehavior = UIAttachmentBehavior(item: dialogView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            animator.addBehavior(attachmentBehavior)
        case .changed:
            attachmentBehavior.anchorPoint = location
        case .ended:
            animator.removeBehavior(attachmentBehavior)
            animator.addBehavior(snapBehavior)
            let translation = sender.translation(in: view)
            if translation.y > 100 {
                animator.removeAllBehaviors()
                gravityBehaviour = UIGravityBehavior(items: [dialogView])
                gravityBehaviour.gravityDirection = CGVector.init(dx: 0, dy: 10)
                animator.addBehavior(gravityBehaviour)
                dismiss(withDialog: false)
            }
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

extension SPPermissionsDialogController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SPPermissionTableViewCell.id, for: indexPath) as! SPPermissionTableViewCell
        let permission = permissions[indexPath.row]
        cell.set(dataSource?.data(for: permission), permission: permission)
        cell.button.addTarget(self, action: #selector(self.process(button:)), for: .touchUpInside)
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true
        cell.layoutMargins = UIEdgeInsets.zero
        cell.contentView.layoutMargins = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        if indexPath.row == permissions.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 100000, bottom: 0, right: 0)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SPPermissionsDialogFooterCommentView.id) as! SPPermissionsDialogFooterCommentView
        view.titleLabel.text = footerText
        view.contentView.backgroundColor = tableView.backgroundColor
        return view
    }
}
#endif
