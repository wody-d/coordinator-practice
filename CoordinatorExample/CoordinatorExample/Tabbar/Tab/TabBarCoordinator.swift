//
//  TabBarCoordinator.swift
//  CoordinatorExample
//
//  Created by Wody on 2022/01/11.
//

import UIKit

protocol TabCoordinatorProtocol: Coordinator {
  var tabBarController: UITabBarController { get set }
  func showDetailViewController()
}

class TabCoordinator: NSObject, TabCoordinatorProtocol {
  
  var tabBarController: UITabBarController
  
  var finishDelegate: CoordinatorFinishDelegate?
  
  var navigationController: UINavigationController
  
  var childCoordinators = [Coordinator]()
  
  required init(_ navigationController: UINavigationController) {
    self.navigationController = navigationController
    self.tabBarController = MainTabBarController.init()
  }
  
  func start() {
    let pages: [TabBarPage] = [.home, .list, .mypage]
      .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
    
    let controllers: [UINavigationController] = pages.map({ getTabController($0) })
    
    prepareTabBarController(withTabControllers: controllers)
  }
  
  deinit {
    print("TabCoordinator deinit")
  }
  
  private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
    tabBarController.delegate = self
    tabBarController.setViewControllers(tabControllers, animated: true)
    tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
    navigationController.viewControllers = [tabBarController]
  }
  
  private func getTabController(_ page: TabBarPage) -> UINavigationController {
    let navigationController = UINavigationController()
    navigationController.setNavigationBarHidden(false, animated: false)
    
    switch page {
    case .home:
      // 홈만 따로 코디네이터를 만들어준 경우
      let coordi = HomeCoordinator(navigationController)
      coordi.finishDelegate = self
      childCoordinators.append(coordi)
      coordi.start()
    case .list:
      let secondVC = ListViewController()
      navigationController.pushViewController(secondVC, animated: true)
    case .mypage:
      let thirdVC = MypageViewController()
      thirdVC.didSendEventClosure2TabCoordi = { [weak self] event in
        switch event {
        case .logout:
          // 레퍼런스들을 모두 지워주기 위해 finish해주어야 합니다.
          self?.childCoordinators.forEach {
            $0.finish()
          }
          self?.finish()
        }
      }
      
      navigationController.pushViewController(thirdVC, animated: true)
    }
    
    return navigationController
  }
  
  func showDetailViewController() {
    let detail = DetailViewController()
    navigationController.pushViewController(detail, animated: true)
  }
  
  
}

extension TabCoordinator: CoordinatorFinishDelegate, UITabBarControllerDelegate {
  func coordinatorDidFinish(childCoordinator: Coordinator) {
    childCoordinators = childCoordinators.filter({ $0 !== childCoordinator })
  }
}
