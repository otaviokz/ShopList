import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // API
    try router.register(collection: ItemsAPIController.shared)
    try router.register(collection: ListsAPIController.shared)
    try router.register(collection: MandarinAPIController.shared)
    
    // Website
    try router.register(collection: IndexWebsiteController.shared)
    try router.register(collection: ItemsWebsiteController.shared)
    try router.register(collection: ListsWebsiteController.shared)
    try router.register(collection: MandarinWebsiteController.shared)
}
