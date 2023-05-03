import Foundation

final class ServiceAssembly {
    
    private let fileManagerService: FileManagerService = FileManagerServiceImpl(
        logService: LogServiceImpl(name: "FileManagerService")
    )
    
    let coreDataService: CoreDataService = CoreDataServiceImpl(
        logService: LogServiceImpl(name: "CoreDataService")
    )
    
    private let chatTransportService: ChatTransportService = ChatTransportServiceImpl(
        logService: LogServiceImpl(name: "ChatTransportService")
    )
    
    private let sseTransportService: SSETransportService = SSETransportServiceImpl(
        logService: LogServiceImpl(name: "SSETransportService")
    )
    
    func makeNetworkService(with logService: LogService = LogServiceImpl(name: "NetworkService")) -> NetworkService {
        NetworkServiceImpl(fileManagerService: fileManagerService,
                           logService: logService)
    }
    
    func makeThemesService(with logService: LogService = LogServiceImpl(name: "ThemesService")) -> ThemesService {
        ThemesServiceImpl(logService: logService)
    }
    
    func makeProfileService(with logService: LogService = LogServiceImpl(name: "ProfileService")) -> ProfileService {
        ProfileServiceImpl(coreDataService: coreDataService,
                           fileManagerService: fileManagerService,
                           logService: logService)
    }
    
    func makePhotoLoaderService(with logService: LogService = LogServiceImpl(name: "PhotoLoaderService")) -> PhotoLoaderService {
        PhotoLoaderServiceImpl(networkService: makeNetworkService(),
                               logService: logService)
    }
    
    func makeDataService(with logService: LogService = LogServiceImpl(name: "DataService")) -> DataService {
        DataServiceImpl(coreDataService: coreDataService,
                        chatTransportService: chatTransportService,
                        sseTransportService: sseTransportService,
                        logService: logService)
    }
}
