// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class AS_TableViewController: UIViewController
{
	weak var coordinator: ASTableViewCoordinator?
	{
		didSet
		{
			tableView.coordinator = coordinator
		}
	}

	var style: UITableView.Style

	lazy var tableView: AS_UITableView = {
		let tableView = AS_UITableView(frame: .zero, style: style)
		tableView.coordinator = coordinator
		tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))) // Remove unnecessary padding in Style.grouped/insetGrouped
		tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))) // Remove separators for non-existent cells
		return tableView
	}()

	public init(style: UITableView.Style)
	{
		self.style = style
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	override public func loadView()
	{
		view = tableView
	}

	override public func viewDidLoad()
	{
		super.viewDidLoad()
	}

	override public func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		coordinator?.didUpdateContentSize(tableView.contentSize)
	}
}

@available(iOS 13.0, *)
class AS_UITableView: UITableView
{
	weak var coordinator: ASTableViewCoordinator?
	override func didMoveToWindow()
	{
		if window != nil
		{
			coordinator?.onMoveToParent()
		}
		else
		{
			coordinator?.onMoveFromParent()
		}
	}
}
