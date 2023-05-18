import UIKit

final class ChannelsListDataSource: UITableViewDiffableDataSource<Int, ChannelModel> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, _, itemIdentifier in
            let cell = tableView.dequeueReusableCell(cellType: ChannelsListCell.self)
            cell.resetCell()
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
