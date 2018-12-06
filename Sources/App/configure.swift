import FluentPostgreSQL
import Leaf
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Sessions middleware
    services.register(middlewares)

    // Configure a PostgreSQL database
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName: String
    let databasePort: Int
    
    if (env == .testing) {
        databaseName = "vapor_shoplist_test"
        databasePort = 5433
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor_shoplist"
        databasePort = 5432
    }
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                                  port: databasePort,
                                                  username: username,
                                                  database: databaseName,
                                                  password: password)
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    /// Register the configured PostgreSQL database to the database config.
    var databasesConfig = DatabasesConfig()
    databasesConfig.add(database: database, as: .psql)
    services.register(databasesConfig)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: List.self, database: .psql)
    migrations.add(model: Item.self, database: .psql)
    migrations.add(model: MandarinWord.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)

    services.register(migrations)
    
    // Adding Fluent commands to wipe out database
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
