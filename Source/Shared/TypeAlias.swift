#if os(macOS)
import Cocoa
public typealias CollectionView = NSCollectionView
public typealias CollectionViewDataSource = NSCollectionViewDataSource
public typealias TableView = NSTableView
public typealias TableViewDataSource = NSTableViewDataSource
public typealias View = NSView
public typealias ViewController = NSViewController
#else
import UIKit
public typealias CollectionView = UICollectionView
public typealias CollectionViewDataSource = UICollectionViewDataSource
public typealias TableView = UITableView
public typealias TableViewDataSource = UITableViewDataSource
public typealias View = UIView
public typealias ViewController = UIViewController
#endif
