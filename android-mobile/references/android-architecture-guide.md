# Android Architecture Guide

Comprehensive guide to modern Android app architecture using Kotlin, Jetpack, and Compose.

## Layered Architecture

### UI Layer

The UI layer displays data and handles user interaction. In Compose, this means:

**Screen composables** — Top-level composables that represent a full screen. They receive a ViewModel via `hiltViewModel()` and collect state via `collectAsStateWithLifecycle()`.

```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onNavigateToDetail: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HomeContent(
        uiState = uiState,
        onItemClick = onNavigateToDetail,
        onRefresh = viewModel::refresh
    )
}

@Composable
private fun HomeContent(
    uiState: HomeUiState,
    onItemClick: (String) -> Unit,
    onRefresh: () -> Unit
) {
    // Stateless composable — easy to preview and test
}
```

**State holders (ViewModels)** — Survive configuration changes, scope coroutines, expose state as `StateFlow`.

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getItemsUseCase: GetItemsUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init { refresh() }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            getItemsUseCase()
                .onSuccess { _uiState.value = HomeUiState.Success(it) }
                .onFailure { _uiState.value = HomeUiState.Error(it.message) }
        }
    }
}
```

### Domain Layer

Pure Kotlin classes with no Android dependencies. Contains:

- **Models** — Domain objects (not Room entities, not API DTOs)
- **Repository interfaces** — Contracts the data layer implements
- **Use cases** — Single-responsibility business logic classes

```kotlin
class GetItemsUseCase @Inject constructor(
    private val repository: ItemRepository
) {
    suspend operator fun invoke(): Result<List<Item>> {
        return repository.getItems()
    }
}
```

Use cases are optional for simple CRUD — a ViewModel can call the repository directly. Add use cases when:
- Business logic spans multiple repositories
- The same logic is used by multiple ViewModels
- Complex data transformations are needed

### Data Layer

Implements repository interfaces from the domain layer. Contains:

- **Repository implementations** — Coordinate between local and remote data sources
- **Room entities and DAOs** — Local database access
- **API services and DTOs** — Remote data access
- **Mappers** — Convert between DTOs, entities, and domain models

```kotlin
class ItemRepositoryImpl @Inject constructor(
    private val localDataSource: ItemLocalDataSource,
    private val remoteDataSource: ItemRemoteDataSource
) : ItemRepository {

    override fun getItems(): Flow<List<Item>> {
        return localDataSource.getAllItems().map { entities ->
            entities.map { it.toDomain() }
        }
    }

    override suspend fun refreshItems(): Result<Unit> {
        return try {
            val dtos = remoteDataSource.fetchItems()
            localDataSource.insertAll(dtos.map { it.toEntity() })
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

## Offline-First Pattern

### Single Source of Truth

Room is the single source of truth. The network is a refresh mechanism, not a data source.

```
User action → ViewModel → Repository → Room (read) → UI
                                      → API (refresh) → Room (write) → UI updates via Flow
```

### Sync Strategy

| Strategy | When | Implementation |
|----------|------|----------------|
| **Pull on demand** | User triggers refresh | SwipeRefresh → Repository.refresh() |
| **Pull on launch** | Data should be fresh on app open | Repository checks staleness, refreshes if needed |
| **Periodic sync** | Background freshness matters | WorkManager with PeriodicWorkRequest |
| **Push sync** | Real-time updates needed | FCM triggers WorkManager one-time sync |

### Conflict Resolution

For apps where users create or modify data offline:

1. **Last-write-wins** — Simplest. Server timestamp determines winner.
2. **Client-priority** — Local changes always win. Good for user-generated content.
3. **Merge** — Field-level merge for complex documents. Requires careful schema design.

Default to last-write-wins unless the domain specifically requires merge semantics.

## Dependency Injection with Hilt

### Module Organization

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient { ... }

    @Provides
    @Singleton
    fun provideRetrofit(client: OkHttpClient): Retrofit { ... }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService { ... }
}

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase { ... }

    @Provides
    fun provideItemDao(db: AppDatabase): ItemDao = db.itemDao()
}

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {
    @Binds
    abstract fun bindItemRepository(impl: ItemRepositoryImpl): ItemRepository
}
```

### Scope Guide

| Scope | Hilt Component | Lifetime | Use For |
|-------|---------------|----------|---------|
| `@Singleton` | SingletonComponent | App lifetime | Database, Retrofit, OkHttp |
| `@ViewModelScoped` | ViewModelComponent | ViewModel lifetime | Use cases (if stateful) |
| `@ActivityScoped` | ActivityComponent | Activity lifetime | Rarely needed |
| None (unscoped) | Created each time | Per injection | Use cases (stateless), mappers |

## Navigation with Compose

### Type-Safe Routes (Kotlin Serialization)

```kotlin
@Serializable
data object Home

@Serializable
data class Detail(val itemId: String)

@Serializable
data object Settings

@Composable
fun AppNavHost(navController: NavHostController) {
    NavHost(navController = navController, startDestination = Home) {
        composable<Home> {
            HomeScreen(onNavigateToDetail = { id ->
                navController.navigate(Detail(itemId = id))
            })
        }
        composable<Detail> { backStackEntry ->
            val detail: Detail = backStackEntry.toRoute()
            DetailScreen(itemId = detail.itemId)
        }
        composable<Settings> {
            SettingsScreen()
        }
    }
}
```

### Navigation Patterns

- **Bottom Navigation** — 3-5 top-level destinations, each with its own back stack
- **Nested Graphs** — Group related screens (auth flow, onboarding flow)
- **Deep Links** — Register in AndroidManifest, handle in navigation graph
- **Arguments** — Use type-safe routes with data classes (Kotlin Serialization)

## Performance Optimization

### Startup

1. **Baseline Profiles** — Pre-compile critical paths for 30-50% faster cold start
2. **Lazy initialization** — Don't initialize everything in `Application.onCreate()`
3. **Remove splash screen work** — SplashScreen API handles display, don't do I/O during splash

### Compose Performance

1. **Stability** — Mark data classes as `@Stable` or `@Immutable` when appropriate
2. **Keys in LazyColumn** — Always provide unique `key` parameter to avoid unnecessary recompositions
3. **derivedStateOf** — Derive state to reduce recompositions
4. **remember** — Cache expensive computations
5. **Compose Compiler Metrics** — Enable `-P plugin:...=metricsDestination` to audit skippability

### APK Size

1. **R8 full mode** — `android.enableR8.fullMode=true` in `gradle.properties`
2. **Resource shrinking** — `shrinkResources true` in build config
3. **WebP images** — Convert PNGs to WebP (Android Studio built-in converter)
4. **Per-ABI splits** — Split native libraries by architecture if using NDK
5. **Remove unused dependencies** — Audit with `./gradlew dependencies`

## Version Catalog Setup

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.1.0"
agp = "8.7.0"
compose-bom = "2025.01.01"
hilt = "2.53"
room = "2.7.0"
retrofit = "2.11.0"
coroutines = "1.9.0"

[libraries]
compose-bom = { module = "androidx.compose:compose-bom", version.ref = "compose-bom" }
compose-ui = { module = "androidx.compose.ui:ui" }
compose-material3 = { module = "androidx.compose.material3:material3" }
compose-tooling = { module = "androidx.compose.ui:ui-tooling" }
compose-tooling-preview = { module = "androidx.compose.ui:ui-tooling-preview" }
hilt-android = { module = "com.google.dagger:hilt-android", version.ref = "hilt" }
hilt-compiler = { module = "com.google.dagger:hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { module = "androidx.hilt:hilt-navigation-compose", version = "1.2.0" }
room-runtime = { module = "androidx.room:room-runtime", version.ref = "room" }
room-compiler = { module = "androidx.room:room-compiler", version.ref = "room" }
room-ktx = { module = "androidx.room:room-ktx", version.ref = "room" }
retrofit-core = { module = "com.squareup.retrofit2:retrofit", version.ref = "retrofit" }
kotlinx-serialization = { module = "org.jetbrains.kotlinx:kotlinx-serialization-json", version = "1.7.3" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
ksp = { id = "com.google.devtools.ksp", version = "2.1.0-1.0.29" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
```
