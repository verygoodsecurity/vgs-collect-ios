//
//  CollectCardDataSwiftUIHostingVC.swift
//  demoapp
//


import Foundation
import SwiftUI

class CollectCardDataSwiftUIHostingVC: UIViewController {
  override func viewDidLoad() {
          super.viewDidLoad()

          let swiftUIView = CardDataCollectionSwiftUI()
          let hostingController = UIHostingController(rootView: swiftUIView)
          addChild(hostingController)
          hostingController.view.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

      hostingController.didMove(toParent: self)
  }
}

