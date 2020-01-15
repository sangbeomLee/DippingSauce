//
//  PeopleTableViewController.swift
//  DippingSauce
//
//  Created by 이상범 on 2020/01/04.
//  Copyright © 2020 이상범. All rights reserved.
//

import UIKit

class PeopleTableViewController: UITableViewController, UISearchResultsUpdating {
    var users:[User] = []
    var searchResult:[User] = []
    // nil을 준 이유는 같은 view에서 처리 할 것이기 때문에 nil을 주었다.
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBarController()
        setupNavigationBar()
        observeUsers()
        setTableView()
    }
    
    func setTableView(){
        tableView.tableFooterView = UIView()
    }
    func setupSearchBarController(){
        searchController.searchResultsUpdater = self
        // 회색으로 표시되면서 클릭 못하게 하는거 false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Sarch users..."
        searchController.searchBar.tintColor = .white
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    func setupNavigationBar(){
        navigationItem.title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let location = UIBarButtonItem(image: UIImage(named: IMAGE_ICON_LOCATION), style: .plain, target: self, action: #selector(locationButtonDidTapped))
        self.navigationItem.leftBarButtonItem = location
    }
    
    @objc func locationButtonDidTapped(){
        // switch to UserAroundVC
        let storyboard = UIStoryboard(name: STORYBOARD_NAME_AROUND, bundle: nil)
        let aroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USER_AROUND) as! UserAroundViewController
        
        self.navigationController?.pushViewController(aroundVC, animated: true)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText == nil || searchText!.isEmpty{
            view.endEditing(true)
        }else{
            let textLowercasted = searchText!.lowercased()
            filterContent(for: textLowercasted)
        }
        tableView.reloadData()
    }
    
    func filterContent(for searchText: String){
        searchResult = self.users.filter({ (user) -> Bool in
            return user.username.lowercased().range(of: searchText) != nil
        })
    }
    
    func observeUsers(){
        Api.User.observeUsers { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? searchResult.count : users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS, for: indexPath) as! UserTableViewCell

        cell.controller = self
        // 지렸누;;
        let user = searchController.isActive ? searchResult[indexPath.row] : users[indexPath.row]
        cell.loadData(user)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell{
            let storyboard = UIStoryboard.init(name: "Message", bundle: nil)
            let chatVC = storyboard.instantiateViewController(identifier: IDENTIFIER_CHAT) as! ChatViewController
            
            chatVC.imagePartner = cell.avatarImageView.image!
            chatVC.partnerUsername = cell.usernameLabel.text
            chatVC.partnerUserId = cell.user.uid 
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        
        
    }

}
