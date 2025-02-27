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

/**
 Controller for Native interface.
 */
public class SPPermissionsNativeController: NSObject, SPPermissionsControllerProtocol {
    
    public weak var dataSource: SPPermissionsDataSource?
    public weak var delegate: SPPermissionsDelegate?
    
    private var permissions: [SPPermission]
    
    init(_ permissions: [SPPermission]) {
        self.permissions = permissions
        super.init()
    }
    
    /**
     Call this method for present controller on other controller. In this method controller configure.
     
     - parameter controller: Controller, on which need present `SPPermissions` controller. In this func no need pass actual controller, this method need for implement protocol `SPPermissionsControllerProtocol`.
     - warning: `didHide` delegate method not call here.
     */
    public func present(on controller: UIViewController) {
        for permission in permissions {
            permission.request { [weak self] in
                if permission.isAuthorized {
                    self?.delegate?.didAllow?(permission: permission)
                } else {
                    self?.delegate?.didDenied?(permission: permission)
                    
                    /**
                     Show alert with propose go to settings and allow permission.
                     Can disable it in `SPPermissionsDataSource`.
                     */
                    if permission.isDenied {
                        let data = self?.dataSource?.data(for: permission)
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
                            controller.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
