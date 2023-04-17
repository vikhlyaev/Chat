import UIKit

final class ChannelsListDataSource: UITableViewDiffableDataSource<String, ChannelModel> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: ChannelsListCell.identifier,
                                     for: indexPath) as? ChannelsListCell
            else {
                return UITableViewCell()
            }
//            if indexPath.row == self?.dataSource.indexLastCellInSection {
//                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//            }
            cell.resetCell()
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<String, ChannelModel>()
        snapshot.appendSections([""])
        self.apply(snapshot, animatingDifferences: false)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
