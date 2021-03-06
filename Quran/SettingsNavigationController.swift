//
//  SettingsNavigationController.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/19/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import UIKit

class SettingsNavigationController: BaseNavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        tabBarItem = UITabBarItem(title: NSLocalizedString("menu_settings", tableName: "Android", comment: ""),
                                  image: UIImage(named: "settings-25"),
                                  selectedImage: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
}
