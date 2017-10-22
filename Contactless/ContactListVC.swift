/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology. Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import DZNEmptyDataSet


class ContactListVC: UITableViewController {
  
  let limit = 75.0
  
  var timer: Timer?
  
  // TableView from Interface Builder
  @IBOutlet var tableview: UITableView!
  
  // Contacts array declaration
  var contacts: [Contact] = []
  
  var tableState = TableState.Loading {
    didSet {
      self.tableview.reloadData()
    }
}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    self.getData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if let index = self.tableview.indexPathForSelectedRow {
      self.tableview.deselectRow(at: index, animated: true)
    }
  }
  
  // Creates artificial delay to getData()
  func getData() {
    tableState = .Loading
    timer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(arc4random_uniform(15))), target: self, selector: #selector(retrieve), userInfo: nil, repeats: false)
  }
  
  // Retrieves data
  @objc func retrieve() {
    // Randomly creates an error
    let error = randomBool()
    
    if !error {
      contacts = DataSource.shared.contactArray
      tableState = .Loaded(DataSource.shared.contactArray)
      
      if DataSource.shared.contactArray.isEmpty {
        tableState = .Empty
      }
      
    } else if error {
      contacts = []
      tableState = .Failed
    }
    self.tableview.reloadData()
  }
  
  func randomBool() -> Bool {
    return arc4random_uniform(2) == 0
  }
  
  @IBAction func reloadButtonTapped(_ sender: UIBarButtonItem) {
    getData()
  }
}

extension ContactListVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
  // MARK: - TableView Methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Creates reusable cell
    let cell = tableview.dequeueReusableCell(withIdentifier: "contactCell") as! ContactCell
    let contact = contacts[indexPath.row]
    
    // Displays data to cell
    cell.nameLabel.text = contact.name
    cell.emailLabel.text = contact.email
    cell.phoneLabel.text = contact.phone
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      contacts.remove(at: indexPath.row)
      DataSource.shared.contactArray = contacts
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  // MARK: - Empty Data State
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    
    var str = ""
    switch tableState {
    case .Failed: str = "Cannot Connect"
    case .Loading: str = "Loading"
    default: str = "No Contacts"
    }
    
    let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)]
    return NSAttributedString(string: str, attributes: attrs)
  }

  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    
    var str = ""
    switch tableState {
    case .Failed: str = "There was an error loading your contacts. Please check your connection and try again at a later time."
    case .Loading: str = "We are fetching your contacts from our servers. Please wait..."
    default: str = "Welcome to Contactless! Add your first contact by tapping the button above."
    }
    
    let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attrs)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    switch tableState {
    case .Failed: return #imageLiteral(resourceName: "no_connection")
    case .Loading: return #imageLiteral(resourceName: "loading")
    default: return #imageLiteral(resourceName: "empty")
    }
  }
}


