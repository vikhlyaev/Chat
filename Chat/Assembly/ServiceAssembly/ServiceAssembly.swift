import Foundation

protocol ServiceAssembly {
    func makeFileManagerService() -> FileManagerService
    func makeCoreDataService() -> CoreDataService
    func makeNetworkService() -> NetworkService
    func makeChatTransportService() -> ChatTransportService
    func makeSSETransportService() -> SSETransportService
    func makeThemesService() -> ThemesService
    func makeProfileService() -> ProfileService
    func makePhotoLoaderService() -> PhotoLoaderService
    func makeDataService() -> DataService
    func makePhotoAddingService() -> PhotoAddingService
    func makeAlertCreaterService() -> AlertCreatorService
}
