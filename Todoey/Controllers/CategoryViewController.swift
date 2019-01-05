//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mikhail Belokopytov on 03/01/2019.
//  Copyright © 2019 mbel. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.separatorStyle = .none
    }


    // MARK TableView DataSource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories created Yet"
        cell.backgroundColor = UIColor(hexString:categories?[indexPath.row].color ?? "4B76EA")

        return cell
    }


    // MARK TableView Data manipulation methods
    
    func save(category: Category) {

        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print (error)
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }

    // MARK Delete data from Swipe 
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryToDelete = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
        
    }

    // MARK - Add new items
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()

            self.tableView.reloadData()
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter category name here"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK TableView Delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

}
