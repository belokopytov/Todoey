//
//  ViewController.swift
//  Todoey
//
//  Created by Mikhail Belokopytov on 29/12/2018.
//  Copyright © 2018 mbel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var toDoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let hexColor = selectedCategory?.color  else { fatalError() }

        updateNavBar(withHexCode: hexColor)
        title = selectedCategory?.name
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "FFFFFF")
    }
    
    // MARK Nav Bar color
    
    func updateNavBar (withHexCode colorHexCode : String) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist!") }
        
        guard let color = UIColor(hexString: colorHexCode) else { fatalError() }

        navBar.barTintColor = color
        navBar.tintColor = ContrastColorOf(color, returnFlat: true)
        searchBar.barTintColor = color
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true)]
        
    }
    
    // MARK Tableview Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = toDoItems?[indexPath.row] {

            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: self.selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

            cell.accessoryType = item.done ? .checkmark : .none

        } else {

            cell.textLabel?.text = "No items added yet"
            
        }

        return cell
    }
    
    
    // MARK Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error while saving item: \(error)")
                }
                
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter todo item here"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK Data manipulation methods
    
    func loadItems () {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemToDelete = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting toDoItem \(error)")
            }
        }
        
    }

}

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
