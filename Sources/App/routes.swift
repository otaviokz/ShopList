import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // API
    try router.register(collection: ListItemsAPIController.shared)
    try router.register(collection: ListAPIController.shared)
    
    // Website
    try router.register(collection: IndexWebsiteController.shared)
    try router.register(collection: ListItemWebsiteController.shared)
    try router.register(collection: ListWebsiteController.shared)
}
