import Foundation
import Combine

final class ChannelsListPresenter {
    
    weak var viewInput: ChannelsListViewInput?
    
    private let dataService: DataService
    weak var moduleOutput: ChannelsListModuleOutput?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService, moduleOutput: ChannelsListModuleOutput?) {
        self.dataService = dataService
        self.moduleOutput = moduleOutput
    }
    
    private func getChannels() {
        dataService.channelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] channelModels in
                self?.viewInput?.showChannels(channelModels)
            }
            .store(in: &cancellables)
    }
}

// MARK: - ChannelsListViewOutput

extension ChannelsListPresenter: ChannelsListViewOutput {

    func viewIsReady() {
        getChannels()
    }
    
    func didUpdateChannels() {
        dataService.loadChannelsFromNetwork()
    }
    
    func didCreateChannel(with name: String, and logoUrl: String?) {
        dataService.createChannelInNetwork(name: name, logoUrl: logoUrl) { [weak self] newChannel in
            self?.moduleOutput?.moduleWantsToOpenChannel(with: newChannel)
        }
    }
    
    func didDeleteChannel(with channelModel: ChannelModel) {
        dataService.deleteChannelFromNetwork(with: channelModel.id)
    }
    
    func didSelectChannel(with channelModel: ChannelModel) {
        moduleOutput?.moduleWantsToOpenChannel(with: channelModel)
    }
    
}
