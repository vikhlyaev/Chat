import Foundation

final class ServiceAssembly {
    
    func makeFileManagerService() -> FileManagerService {
        FileManagerServiceImpl()
    }
    
    func makeCoreDataService() -> CoreDataService {
        CoreDataServiceImpl()
    }
    
    func makeChatTransportService() -> ChatTransportService {
        ChatTransportServiceImpl()
    }
    
    func makeSSETransportService() -> SSETransportService {
        SSETransportServiceImpl()
    }
    
    func makeNetworkService() -> NetworkService {
        NetworkServiceImpl(fileManagerService: makeFileManagerService())
    }
    
    func makeThemesService() -> ThemesService {
        ThemesServiceImpl()
    }
    
    func makeProfileService() -> ProfileService {
        ProfileServiceImpl(coreDataService: makeCoreDataService(),
                           fileManagerService: makeFileManagerService())
    }
    
    func makePhotoLoaderService() -> PhotoLoaderService {
        PhotoLoaderServiceImpl(networkService: makeNetworkService())
    }
    
    func makeDataService() -> DataService {
        DataServiceImpl(coreDataService: makeCoreDataService(),
                        chatTransportService: makeChatTransportService(),
                        sseTransportService: makeSSETransportService())
    }
    
    func makePhotoAddingService() -> PhotoAddingService {
        PhotoAddingServiceImpl()
    }
    
    func makeAlertCreaterService() -> AlertCreatorService {
        AlertCreatorServiceImpl()
    }
}
