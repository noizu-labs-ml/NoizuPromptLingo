# Android Testing Strategy

Practical testing guide organized by the testing pyramid, with tooling recommendations and coverage priorities.

## Testing Pyramid

```
         /  E2E  \          ← Maestro: 3-5 critical user journeys
        /  UI Tests \       ← Compose Test: screen-level interactions
       / Screenshot  \      ← Roborazzi: visual regression detection
      / Integration    \    ← Hilt Test + Room: data layer end-to-end
     /   Unit Tests      \  ← JUnit 5 + Turbine + MockK: fast, isolated
```

## Unit Tests

### ViewModels

Test state transitions and event handling:

```kotlin
@ExtendWith(MainDispatcherExtension::class)
class HomeViewModelTest {

    private val repository = mockk<ItemRepository>()
    private lateinit var viewModel: HomeViewModel

    @BeforeEach
    fun setup() {
        coEvery { repository.getItems() } returns flowOf(testItems)
        viewModel = HomeViewModel(GetItemsUseCase(repository))
    }

    @Test
    fun `initial state is loading then success`() = runTest {
        viewModel.uiState.test {
            assertThat(awaitItem()).isEqualTo(HomeUiState.Loading)
            assertThat(awaitItem()).isEqualTo(HomeUiState.Success(testItems))
        }
    }

    @Test
    fun `refresh on error shows error state`() = runTest {
        coEvery { repository.getItems() } throws IOException("No network")

        viewModel.refresh()

        viewModel.uiState.test {
            val state = awaitItem()
            assertThat(state).isInstanceOf(HomeUiState.Error::class.java)
        }
    }
}
```

### Use Cases

Test business logic in isolation:

```kotlin
class GetFilteredItemsUseCaseTest {

    @Test
    fun `filters inactive items`() = runTest {
        val repository = FakeItemRepository(
            items = listOf(activeItem, inactiveItem)
        )
        val useCase = GetFilteredItemsUseCase(repository)

        val result = useCase(filter = ItemFilter.ACTIVE_ONLY)

        assertThat(result).containsExactly(activeItem)
    }
}
```

### Repositories

Test data mapping and coordination:

```kotlin
class ItemRepositoryImplTest {

    private val localDataSource = FakeLocalDataSource()
    private val remoteDataSource = mockk<RemoteDataSource>()
    private val repository = ItemRepositoryImpl(localDataSource, remoteDataSource)

    @Test
    fun `refresh stores remote data locally`() = runTest {
        coEvery { remoteDataSource.fetchItems() } returns listOf(testDto)

        repository.refresh()

        assertThat(localDataSource.getAll()).hasSize(1)
        assertThat(localDataSource.getAll().first().name).isEqualTo(testDto.name)
    }
}
```

## Compose UI Tests

### Screen-Level Tests

```kotlin
class HomeScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun `shows items when loaded`() {
        composeTestRule.setContent {
            AppTheme {
                HomeContent(
                    uiState = HomeUiState.Success(testItems),
                    onItemClick = {},
                    onRefresh = {}
                )
            }
        }

        composeTestRule.onNodeWithText("Test Item").assertIsDisplayed()
    }

    @Test
    fun `shows error message with retry`() {
        var retryCalled = false

        composeTestRule.setContent {
            AppTheme {
                HomeContent(
                    uiState = HomeUiState.Error("Something went wrong"),
                    onItemClick = {},
                    onRefresh = { retryCalled = true }
                )
            }
        }

        composeTestRule.onNodeWithText("Something went wrong").assertIsDisplayed()
        composeTestRule.onNodeWithText("Retry").performClick()
        assertThat(retryCalled).isTrue()
    }
}
```

### Component Tests

Test reusable composables in isolation:

```kotlin
class ItemCardTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun `displays title and description`() {
        composeTestRule.setContent {
            ItemCard(
                title = "Test Title",
                description = "Test Description",
                onClick = {}
            )
        }

        composeTestRule.onNodeWithText("Test Title").assertIsDisplayed()
        composeTestRule.onNodeWithText("Test Description").assertIsDisplayed()
    }

    @Test
    fun `click invokes callback`() {
        var clicked = false

        composeTestRule.setContent {
            ItemCard(title = "Test", description = "", onClick = { clicked = true })
        }

        composeTestRule.onNodeWithText("Test").performClick()
        assertThat(clicked).isTrue()
    }
}
```

## Screenshot Tests

### Roborazzi Setup

```kotlin
@RunWith(ParameterizedRobolectricTestRunner::class)
class HomeScreenScreenshotTest(
    private val darkTheme: Boolean
) {

    @get:Rule
    val composeTestRule = createComposeRule()

    companion object {
        @JvmStatic
        @ParameterizedRobolectricTestRunner.Parameters(name = "darkTheme={0}")
        fun params() = listOf(false, true)
    }

    @Test
    fun homeScreen_loaded() {
        composeTestRule.setContent {
            AppTheme(darkTheme = darkTheme) {
                HomeContent(
                    uiState = HomeUiState.Success(testItems),
                    onItemClick = {},
                    onRefresh = {}
                )
            }
        }

        composeTestRule.onRoot()
            .captureRoboImage("HomeScreen_loaded_dark=$darkTheme.png")
    }
}
```

### When to Use Screenshot Tests

- After changing theme colors or typography
- When modifying shared components used across multiple screens
- For complex layouts that are hard to verify with assertion-based tests
- As a regression safety net before releases

## Integration Tests

### Room Database Tests

```kotlin
@RunWith(AndroidJUnit4::class)
class ItemDaoTest {

    private lateinit var database: AppDatabase
    private lateinit var dao: ItemDao

    @Before
    fun setup() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AppDatabase::class.java
        ).build()
        dao = database.itemDao()
    }

    @After
    fun teardown() { database.close() }

    @Test
    fun insertAndRetrieve() = runTest {
        dao.insert(testEntity)

        val items = dao.getAll().first()

        assertThat(items).containsExactly(testEntity)
    }
}
```

## E2E Tests with Maestro

### Flow File Example

```yaml
# .maestro/flows/login-and-browse.yaml
appId: com.example.app
---
- launchApp
- tapOn: "Email"
- inputText: "test@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"
- assertVisible: "Home"
- tapOn: "First Item"
- assertVisible: "Item Details"
- back
- assertVisible: "Home"
```

### When to Use E2E Tests

- Critical user journeys (sign up, purchase, core feature loop)
- Smoke tests before release
- Flows involving multiple screens and system interactions
- Keep to 3-5 flows maximum — they're slow and brittle

## Testing Tools Summary

| Tool | Purpose | Speed | Reliability |
|------|---------|-------|-------------|
| JUnit 5 | Unit test runner | Fast | High |
| Turbine | Flow testing (awaitItem, turbineScope) | Fast | High |
| MockK | Kotlin-first mocking | Fast | High |
| Truth | Assertion library (readable failures) | Fast | High |
| Compose Test | UI component testing | Medium | High |
| Roborazzi | Screenshot testing on JVM (no emulator) | Medium | High |
| Robolectric | Android framework on JVM | Medium | Medium |
| Maestro | E2E flow testing | Slow | Medium |

## CI Test Configuration

```yaml
# Run in parallel for speed
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - run: ./gradlew testDebugUnitTest

  ui-tests:
    runs-on: ubuntu-latest
    steps:
      - run: ./gradlew verifyRoborazziDebug

  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          script: ./gradlew connectedDebugAndroidTest
```
