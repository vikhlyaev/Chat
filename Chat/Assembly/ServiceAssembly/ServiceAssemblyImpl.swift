import Foundation

final class ServiceAssemblyImpl: ServiceAssembly {
    
    func makeFileManagerService() -> FileManagerService {
        FileManagerServiceImpl()
    }
    
    func makeCoreDataService() -> CoreDataService {
        CoreDataServiceImpl()
    }
    
    func makeNetworkService() -> NetworkService {
        NetworkServiceImpl()
    }
    
    func makeChatTransportService() -> ChatTransportService {
        ChatTransportServiceImpl()
    }
    
    func makeSSETransportService() -> SSETransportService {
        SSETransportServiceImpl()
    }
    
    func makeThemesService() -> ThemesService {
        ThemesServiceImpl()
    }
    
    func makeProfileService() -> ProfileService {
        ProfileServiceImpl(
            coreDataService: makeCoreDataService(),
            fileManagerService: makeFileManagerService()
        )
    }
    
    func makePhotoLoaderService() -> PhotoLoaderService {
        PhotoLoaderServiceImpl(
            networkService: makeNetworkService(),
            fileManagerService: makeFileManagerService()
        )
    }
    
    func makeDataService() -> DataService {
        DataServiceImpl(
            coreDataService: makeCoreDataService(),
            chatTransportService: makeChatTransportService(),
            sseTransportService: makeSSETransportService()
        )
    }
    
    func makePhotoAddingService() -> PhotoAddingService {
        PhotoAddingServiceImpl()
    }
    
    func makeAlertCreaterService() -> AlertCreatorService {
        AlertCreatorServiceImpl()
    }
    
}
