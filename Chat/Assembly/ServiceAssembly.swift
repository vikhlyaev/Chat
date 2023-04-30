import Foundation

final class ServiceAssembly {
    
    private let fileManagerService: FileManagerService = FileManagerServiceImpl(
        logService: LogServiceImpl(name: "FileManagerService")
    )
    
    let coreDataService: CoreDataService = CoreDataServiceImpl(
        logService: LogServiceImpl(name: "CoreDataService")
    )
    
    private let networkService: NetworkService = NetworkServiceImpl(
        logService: LogServiceImpl(name: "NetworkService")
    )
    
    private let chatTransportService: ChatTransportService = ChatTransportServiceImpl(
        logService: LogServiceImpl(name: "ChatTransportService")
    )
    
    func makeThemesService(with logService: LogService = LogServiceImpl(name: "ThemesService")) -> ThemesService {
        ThemesServiceImpl(logService: logService)
    }
    
    func makeProfileService(with logService: LogService = LogServiceImpl(name: "ProfileService")) -> ProfileService {
        ProfileServiceImpl(coreDataService: coreDataService,
                           fileManagerService: fileManagerService,
                           logService: logService)
    }
    
    func makePhotoLoaderService(with logService: LogService = LogServiceImpl(name: "PhotoLoaderService")) -> PhotoLoaderService {
        PhotoLoaderServiceImpl(networkService: networkService,
                               logService: logService)
    }
    
    func makeDataService(with logService: LogService = LogServiceImpl(name: "DataService")) -> DataService {
        DataServiceImpl(coreDataService: coreDataService,
                        chatTransportService: chatTransportService,
                        logService: logService)
    }
}
