# Worked Example: Companion App for therobotknows.com

End-to-end walkthrough of building a companion Android app for an existing web project.

## Scenario

**therobotknows.com** is a web application with a REST API backend. The team wants a companion Android app that provides:
- Browse content (articles, guides) from the existing API
- Push notifications for new content
- Offline reading (download articles for later)
- User authentication (shared accounts with web)

## Phase 1: Requirements & Architecture

### Discovery

| Dimension | Decision |
|-----------|----------|
| Package name | `com.therobotknows.app` |
| Min API | 26 (Android 8.0, covers 95%+ of active devices) |
| Compile API | 35 (latest stable) |
| Auth | JWT tokens from existing API, stored in DataStore |
| Offline | Room with WorkManager sync |
| Push | Firebase Cloud Messaging |
| Monetization | Free with optional premium subscription |

### Architecture Decision

Standard layered architecture with MVVM. No need for MVI — screen state is straightforward (loading, content, error).

```
UI (Compose) → ViewModels → Use Cases → Repositories → Room + Retrofit
```

### Module Structure (Monolith Start)

Single `app` module. Will modularize when build times exceed 2 minutes.

```
com.therobotknows.app/
├── di/
│   ├── NetworkModule.kt
│   ├── DatabaseModule.kt
│   └── RepositoryModule.kt
├── data/
│   ├── local/
│   │   ├── AppDatabase.kt
│   │   ├── ArticleEntity.kt
│   │   └── ArticleDao.kt
│   ├── remote/
│   │   ├── ApiService.kt
│   │   ├── ArticleDto.kt
│   │   └── AuthInterceptor.kt
│   └── repository/
│       ├── ArticleRepositoryImpl.kt
│       └── AuthRepositoryImpl.kt
├── domain/
│   ├── model/
│   │   ├── Article.kt
│   │   └── User.kt
│   ├── repository/
│   │   ├── ArticleRepository.kt
│   │   └── AuthRepository.kt
│   └── usecase/
│       ├── GetArticlesUseCase.kt
│       ├── GetArticleDetailUseCase.kt
│       └── SyncArticlesUseCase.kt
├── ui/
│   ├── theme/
│   │   ├── Color.kt
│   │   ├── Type.kt
│   │   └── Theme.kt
│   ├── components/
│   │   ├── ArticleCard.kt
│   │   ├── LoadingState.kt
│   │   └── ErrorState.kt
│   ├── navigation/
│   │   ├── AppNavHost.kt
│   │   └── Routes.kt
│   └── screens/
│       ├── home/
│       │   ├── HomeScreen.kt
│       │   └── HomeViewModel.kt
│       ├── article/
│       │   ├── ArticleScreen.kt
│       │   └── ArticleViewModel.kt
│       ├── auth/
│       │   ├── LoginScreen.kt
│       │   └── AuthViewModel.kt
│       └── settings/
│           ├── SettingsScreen.kt
│           └── SettingsViewModel.kt
├── worker/
│   └── SyncWorker.kt
└── TheRobotKnowsApp.kt
```

## Phase 2: Project Setup

### Version Catalog

```toml
[versions]
kotlin = "2.1.0"
compose-bom = "2025.01.01"
hilt = "2.53"
room = "2.7.0"
retrofit = "2.11.0"
datastore = "1.1.1"

[libraries]
# Compose
compose-bom = { module = "androidx.compose:compose-bom", version.ref = "compose-bom" }
compose-material3 = { module = "androidx.compose.material3:material3" }
compose-navigation = { module = "androidx.navigation:navigation-compose", version = "2.8.5" }

# DI
hilt-android = { module = "com.google.dagger:hilt-android", version.ref = "hilt" }
hilt-compiler = { module = "com.google.dagger:hilt-android-compiler", version.ref = "hilt" }
hilt-navigation = { module = "androidx.hilt:hilt-navigation-compose", version = "1.2.0" }

# Data
room-runtime = { module = "androidx.room:room-runtime", version.ref = "room" }
room-compiler = { module = "androidx.room:room-compiler", version.ref = "room" }
room-ktx = { module = "androidx.room:room-ktx", version.ref = "room" }
retrofit-core = { module = "com.squareup.retrofit2:retrofit", version.ref = "retrofit" }
datastore-prefs = { module = "androidx.datastore:datastore-preferences", version.ref = "datastore" }
kotlinx-serialization = { module = "org.jetbrains.kotlinx:kotlinx-serialization-json", version = "1.7.3" }

# Firebase
firebase-bom = { module = "com.google.firebase:firebase-bom", version = "33.7.0" }
firebase-messaging = { module = "com.google.firebase:firebase-messaging-ktx" }
firebase-crashlytics = { module = "com.google.firebase:firebase-crashlytics-ktx" }

# Testing
junit5 = { module = "org.junit.jupiter:junit-jupiter", version = "5.11.4" }
turbine = { module = "app.cash.turbine:turbine", version = "1.2.0" }
mockk = { module = "io.mockk:mockk", version = "1.13.13" }
truth = { module = "com.google.truth:truth", version = "1.4.4" }
```

### Theme (Derived from Web Brand)

Map the website's color palette to MD3 color roles:

```kotlin
// Color.kt — generated from Material Theme Builder with brand seed color
val md_theme_light_primary = Color(0xFF1A73E8)        // Brand blue
val md_theme_light_onPrimary = Color(0xFFFFFFFF)
val md_theme_light_primaryContainer = Color(0xFFD3E3FD)
// ... (full palette from Theme Builder)

val md_theme_dark_primary = Color(0xFFA8C7FA)
val md_theme_dark_onPrimary = Color(0xFF062E6F)
val md_theme_dark_primaryContainer = Color(0xFF0842A0)
// ... (full dark palette)
```

## Phase 3: Core Implementation

### Data Layer — API Service

```kotlin
interface ApiService {
    @GET("api/v1/articles")
    suspend fun getArticles(
        @Query("page") page: Int = 1,
        @Query("per_page") perPage: Int = 20
    ): List<ArticleDto>

    @GET("api/v1/articles/{id}")
    suspend fun getArticle(@Path("id") id: String): ArticleDto

    @POST("api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse
}
```

### Data Layer — Room Entity

```kotlin
@Entity(tableName = "articles")
data class ArticleEntity(
    @PrimaryKey val id: String,
    val title: String,
    val summary: String,
    val content: String,
    val imageUrl: String?,
    val publishedAt: Instant,
    val isBookmarked: Boolean = false,
    val lastSyncedAt: Instant = Instant.now()
)

@Dao
interface ArticleDao {
    @Query("SELECT * FROM articles ORDER BY publishedAt DESC")
    fun getAllArticles(): Flow<List<ArticleEntity>>

    @Query("SELECT * FROM articles WHERE id = :id")
    fun getArticle(id: String): Flow<ArticleEntity?>

    @Upsert
    suspend fun upsertAll(articles: List<ArticleEntity>)
}
```

### Repository — Offline-First

```kotlin
class ArticleRepositoryImpl @Inject constructor(
    private val dao: ArticleDao,
    private val api: ApiService
) : ArticleRepository {

    override fun getArticles(): Flow<List<Article>> {
        return dao.getAllArticles().map { entities ->
            entities.map { it.toDomain() }
        }
    }

    override suspend fun refresh(): Result<Unit> {
        return try {
            val dtos = api.getArticles()
            dao.upsertAll(dtos.map { it.toEntity() })
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

### ViewModel

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val getArticlesUseCase: GetArticlesUseCase,
    private val syncArticlesUseCase: SyncArticlesUseCase
) : ViewModel() {

    val articles = getArticlesUseCase()
        .map<List<Article>, HomeUiState> { HomeUiState.Success(it) }
        .catch { emit(HomeUiState.Error(it.message ?: "Unknown error")) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), HomeUiState.Loading)

    fun refresh() {
        viewModelScope.launch {
            syncArticlesUseCase()
        }
    }
}
```

### UI — Home Screen

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel(),
    onArticleClick: (String) -> Unit
) {
    val uiState by viewModel.articles.collectAsStateWithLifecycle()
    val pullRefreshState = rememberPullToRefreshState()

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("The Robot Knows") })
        }
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState is HomeUiState.Loading,
            onRefresh = viewModel::refresh,
            state = pullRefreshState,
            modifier = Modifier.padding(padding)
        ) {
            when (val state = uiState) {
                is HomeUiState.Loading -> LoadingState()
                is HomeUiState.Error -> ErrorState(
                    message = state.message,
                    onRetry = viewModel::refresh
                )
                is HomeUiState.Success -> ArticleList(
                    articles = state.articles,
                    onArticleClick = onArticleClick
                )
            }
        }
    }
}
```

## Phase 4: Testing

### ViewModel Test

```kotlin
class HomeViewModelTest {

    @Test
    fun `articles flow emits loading then success`() = runTest {
        val fakeRepo = FakeArticleRepository(testArticles)
        val viewModel = HomeViewModel(
            GetArticlesUseCase(fakeRepo),
            SyncArticlesUseCase(fakeRepo)
        )

        viewModel.articles.test {
            assertThat(awaitItem()).isEqualTo(HomeUiState.Loading)
            assertThat(awaitItem()).isEqualTo(HomeUiState.Success(testArticles))
        }
    }
}
```

### UI Test

```kotlin
class HomeScreenTest {
    @get:Rule val composeTestRule = createComposeRule()

    @Test
    fun `shows articles when loaded`() {
        composeTestRule.setContent {
            AppTheme {
                ArticleList(articles = testArticles, onArticleClick = {})
            }
        }

        composeTestRule.onNodeWithText("Test Article Title").assertIsDisplayed()
    }
}
```

## Phase 5: Release

### Pre-Launch

1. Internal testing track set up — team tested core flows
2. Crashlytics integrated — no critical crashes in 48 hours
3. Screenshots captured: 6 phone screenshots showing browse, read, offline, dark mode
4. Store listing written with ASO keywords: "tech articles", "offline reading", "AI insights"
5. Privacy policy hosted at `therobotknows.com/privacy`
6. Data safety form completed (collects email for auth, crash logs via Crashlytics)

### Release Timeline

| Day | Action |
|-----|--------|
| Day 1 | Internal testing track → team verification |
| Day 3 | Closed testing → invite 20 beta users |
| Day 10 | Fix any reported issues, update listing |
| Day 14 | Production release → 5% staged rollout |
| Day 15 | Monitor crash rate, expand to 20% |
| Day 17 | Expand to 50% |
| Day 19 | Full 100% rollout |

## Lessons Learned

1. **Start with the API contract** — align DTOs with existing API before writing Room entities
2. **Offline-first from day one** — retrofitting offline support is painful; Room-first is easy
3. **Screenshot tests caught 3 regressions** — worth the setup cost
4. **Internal testing track is invaluable** — deploy to real devices early and often
5. **ASO matters** — the first version with generic description got 2x fewer installs than the keyword-optimized version
