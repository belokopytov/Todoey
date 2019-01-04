//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Mikhail Belokopytov on 03/01/2019.
//  Copyright © 2019 mbel. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryViewController: UITableViewController {

//    let realm = try! Realm()
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }


    // MARK TableView DataSource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories created Yet"
        return cell
    }


    // MARK TableView Data manipulation methods
    
    func save(category: Category) {
        let realm = try! Realm()

        
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
        let realm = try! Realm()
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }


    // MARK - Add new items
    
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
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
