// ASCollectionView. Created by Apptek Studios 2019

import DifferenceKit
import UIKit

@available(iOS 13.0, *)
class ASDiffableDataSourceTableView<SectionID: Hashable>: ASDiffableDataSource<SectionID>, UITableViewDataSource
{
	/// The type of closure providing the cell.
	public typealias Snapshot = ASDiffableDataSourceSnapshot<SectionID>
	public typealias CellProvider = (UITableView, IndexPath, ASCollectionViewItemUniqueID) -> ASTableViewCell?

	private weak var tableView: UITableView?
	private let cellProvider: CellProvider

	public init(tableView: UITableView, cellProvider: @escaping CellProvider)
	{
		self.tableView = tableView
		self.cellProvider = cellProvider
		super.init()

		tableView.dataSource = self
	}

	/// The default animation to updating the views.
	public var defaultRowAnimation: UITableView.RowAnimation = .automatic

	private var firstLoad: Bool = true

	func applySnapshot(_ newSnapshot: Snapshot, animated: Bool = true, completion: (() -> Void)? = nil)
	{
		let changeset = StagedChangeset(source: currentSnapshot.sections, target: newSnapshot.sections)
		let shouldDisableAnimation = firstLoad || !animated

		guard let tableView = tableView else { return }

		firstLoad = false
		
		CATransaction.begin()
		if shouldDisableAnimation
		{
			CATransaction.setDisableActions(true)
		}
		CATransaction.setCompletionBlock(completion)
		tableView.reload(using: changeset, with: shouldDisableAnimation ? .none : defaultRowAnimation) { newSections in
			self.currentSnapshot.sections = newSections
		}
		CATransaction.commit()
	}

	func reloadItems(_ indexPaths: Set<IndexPath>, animated: Bool = true)
	{
		guard let tableView = tableView else { return }
		guard !indexPaths.isEmpty else { return }
		CATransaction.begin()
		if !animated
		{
			CATransaction.setDisableActions(true)
		}
		indexPaths.forEach {
			(tableView.cellForRow(at: $0) as? ASTableViewCell)?.prepareForSizing()
			}
		tableView.performBatchUpdates(nil, completion: nil)
		CATransaction.commit()
	}

	func numberOfSections(in tableView: UITableView) -> Int
	{
		currentSnapshot.sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		currentSnapshot.sections[section].elements.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let itemIdentifier = identifier(at: indexPath)
		guard let cell = cellProvider(tableView, indexPath, itemIdentifier) else
		{
			fatalError("ASTableView dataSource returned a nil cell for row at index path: \(indexPath), tableView: \(tableView), itemIdentifier: \(itemIdentifier)")
		}
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	{
		true
	}
}