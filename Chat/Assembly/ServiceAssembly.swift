import Foundation

final class ServiceAssembly {
    
    private let fileManagerService: FileManagerService = FileManagerServiceImpl()
    private let coreDataService: CoreDataService = CoreDataServiceImpl()
    private let chatTransportService: ChatTransportService = ChatTransportServiceImpl()
    private let sseTransportService: SSETransportService = SSETransportServiceImpl()
    
    func makeNetworkService() -> NetworkService {
        NetworkServiceImpl(fileManagerService: fileManagerService)
    }
    
    func makeThemesService() -> ThemesService {
        ThemesServiceImpl()
    }
    
    func makeProfileService() -> ProfileService {
        ProfileServiceImpl(coreDataService: coreDataService,
                           fileManagerService: fileManagerService)
    }
    
    func makePhotoLoaderService() -> PhotoLoaderService {
        PhotoLoaderServiceImpl(networkService: makeNetworkService())
    }
    
    func makeDataService() -> DataService {
        DataServiceImpl(coreDataService: coreDataService,
                        chatTransportService: chatTransportService,
                        sseTransportService: sseTransportService)
    }
}
