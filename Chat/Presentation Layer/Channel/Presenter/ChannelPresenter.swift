import Foundation
import Combine

final class ChannelPresenter {
    
    private enum Constants: String {
        case channelCellSent
        case channelCellReceived
    }
    
    weak var viewInput: ChannelViewInput?
    
    private let dataService: DataService
    private let profileService: ProfileService
    
    private var cancellables = Set<AnyCancellable>()
    
    private let channel: ChannelModel
    private var profile: ProfileModel?
    
    private var sortedMessages: [SortedMessage] = [] {
        didSet {
            viewInput?.updateTableView()
        }
    }
    
    init(dataService: DataService, profileService: ProfileService, channel: ChannelModel) {
        self.dataService = dataService
        self.profileService = profileService
        self.channel = channel
        
        loadProfile()
        dataService.loadMessagesFromNetwork(for: channel.id)
    }
    
    private func getMessages() {
        dataService.messagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self else { return }
                self.sortedMessages = self.groupMessages(messages)
            }
            .store(in: &cancellables)
    }
    
    private func groupMessages(_ messages: [MessageModel]) -> [SortedMessage] {
        messages.daySorted
            .map { SortedMessage(date: $0.key, messages: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }
    
    private func loadProfile() {
        profileService.loadProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
            case .failure:
                fatalError()
            }
        }
    }
}

// MARK: - ChannelViewOutput

extension ChannelPresenter: ChannelViewOutput {
    func didRequestUserId() -> String {
        profile?.id ?? ""
    }
    
    func didRequestNumberOfSections() -> Int {
        sortedMessages.count
    }
    
    func didRequestNumberOfRows(inSection section: Int) -> Int {
        sortedMessages[section].messages.count
    }
    
    func didRequestMessage(for indexPath: IndexPath) -> MessageModel {
        sortedMessages[indexPath.section].messages[indexPath.row]
    }
    
    func didRequestName() -> String {
        channel.name
    }
    
    func didRequestLogoUrl() -> String? {
        channel.logoUrl
    }
    
    func didRequestDate(inSection section: Int) -> Date {
        sortedMessages[section].date
    }
    
    func didSendMessage(text: String) {
        dataService.sendMessage(text: text,
                                channelId: channel.id,
                                userId: profile?.id ?? "",
                                userName: profile?.name ?? "")
    }
    
    func viewIsReady() {
        getMessages()
    }
}
