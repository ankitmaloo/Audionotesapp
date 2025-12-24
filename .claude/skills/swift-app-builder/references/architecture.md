# Swift Architecture & Compilation

## Swift Compilation Process

### Source to Binary Pipeline
1. **Parser**: Converts .swift files to Abstract Syntax Tree (AST)
2. **Semantic Analysis**: Type checking, name resolution
3. **SIL Generation**: Swift Intermediate Language (optimizable IR)
4. **SIL Optimization**: High-level optimizations
5. **LLVM IR Generation**: Lower-level intermediate representation
6. **LLVM Optimization**: Low-level optimizations
7. **Code Generation**: Machine code for target architecture

### Build Modes
- **Debug**: Fast compilation, no optimization, full debug info
- **Release**: Full optimization, minimal debug info, dead code elimination
- **Testing**: Special mode for unit/UI tests

### Compilation Commands
```bash
# Type check only (fast validation)
swiftc -typecheck MyFile.swift

# Build executable
swiftc -o MyApp main.swift

# With optimization
swiftc -O -o MyApp main.swift

# SPM project build
swift build                    # Debug
swift build -c release         # Release
swift run                      # Build + run
```

## Swift Language Architecture

### Type System
- **Value Types**: struct, enum (copied on assignment)
- **Reference Types**: class, closure (shared references)
- **Protocol Types**: Interfaces with associated types
- **Generics**: Compile-time polymorphism
- **Opaque Types**: some View (type-erased generics)

### Memory Management
- **ARC (Automatic Reference Counting)**: Reference types only
- **No GC**: Deterministic deallocation
- **Strong/Weak/Unowned**: Reference relationships
- **Value semantics**: Structs are copied (copy-on-write optimized)

### Concurrency Model (Swift 6+)
- **async/await**: Structured concurrency
- **Actors**: Isolated mutable state
- **Tasks**: Units of asynchronous work
- **@MainActor**: Run on main thread
- **Sendable**: Thread-safe types

## SwiftUI Architecture

### Declarative UI Framework
SwiftUI rebuilds views when state changes via:
1. State changes (@State, @Binding, @ObservedObject)
2. SwiftUI creates new view value
3. Diffing algorithm finds changes
4. Only changed parts re-render

### Core Property Wrappers
- **@State**: View-owned mutable state
- **@Binding**: Two-way connection to external state
- **@StateObject**: View-owned ObservableObject instance
- **@ObservedObject**: External ObservableObject reference
- **@EnvironmentObject**: Shared object down view tree
- **@Environment**: System environment values

### Data Flow Patterns

#### Single Source of Truth
```swift
// Parent owns state
struct ParentView: View {
    @State private var text = ""
    
    var body: some View {
        ChildView(text: $text)  // Pass binding
    }
}

// Child modifies via binding
struct ChildView: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Enter", text: $text)
    }
}
```

#### Observable Pattern (iOS 17+)
```swift
@Observable
class AppModel {
    var count = 0
    var items: [Item] = []
}

struct ContentView: View {
    @State private var model = AppModel()
    
    var body: some View {
        Text("\(model.count)")  // Auto-updates
            .onTapGesture {
                model.count += 1
            }
    }
}
```

## App Architecture Patterns

### MVVM (Recommended for SwiftUI)
```
Model ← ViewModel ← View
  ↓         ↓         ↓
Data   Business   UI
       Logic
```

**Benefits:**
- Clear separation of concerns
- Testable business logic
- Natural fit for SwiftUI's reactive pattern

**Structure:**
```swift
// Model (data)
struct User {
    let id: UUID
    let name: String
}

// ViewModel (logic + state)
@Observable
class UserViewModel {
    var users: [User] = []
    
    func loadUsers() async {
        // Business logic
    }
}

// View (UI)
struct UserListView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
    }
}
```

### TCA (The Composable Architecture)
For complex apps needing predictable state management:
- Single source of truth (Store)
- Unidirectional data flow
- Testable reducers
- Effect handling

### Redux-like Patterns
State machine pattern:
```swift
enum AppState {
    case loading
    case loaded(Data)
    case error(Error)
}

enum Action {
    case load
    case didLoad(Data)
    case didFail(Error)
}
```

## Project Structure

### Recommended Organization
```
MyApp/
├── Sources/
│   ├── MyApp/
│   │   ├── App/
│   │   │   └── MyAppApp.swift       # App entry point
│   │   ├── Models/
│   │   │   └── User.swift
│   │   ├── ViewModels/
│   │   │   └── UserViewModel.swift
│   │   ├── Views/
│   │   │   ├── UserListView.swift
│   │   │   └── UserDetailView.swift
│   │   ├── Services/
│   │   │   └── APIService.swift
│   │   └── Utilities/
│   │       └── Extensions.swift
├── Tests/
│   └── MyAppTests/
├── Package.swift
└── README.md
```

### Module Boundaries
- **App**: Entry point, composition root
- **Models**: Pure data structures
- **ViewModels**: Business logic, state management
- **Views**: UI components
- **Services**: Network, persistence, external APIs
- **Utilities**: Helpers, extensions

## Dependency Management

### Swift Package Manager (SPM)
Built-in, recommended for pure Swift packages:
```swift
dependencies: [
    .package(url: "https://github.com/user/repo.git", from: "1.0.0")
]
```

### CocoaPods
For legacy or Objective-C dependencies.

### Best Practices
- Minimize dependencies
- Pin versions in production
- Review dependency licenses
- Consider package size impact

## Testing Architecture

### Unit Tests
```swift
import Testing  // Swift Testing framework

@Test func viewModelLoadsUsers() async throws {
    let viewModel = UserViewModel()
    await viewModel.loadUsers()
    #expect(viewModel.users.isEmpty == false)
}
```

### UI Tests
```swift
import XCTest

final class UITests: XCTestCase {
    func testUserFlow() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Add User"].tap()
        // ...
    }
}
```

### Preview Tests
SwiftUI Previews are living documentation and light tests:
```swift
#Preview {
    UserListView()
}

#Preview("Empty State") {
    UserListView(users: [])
}

#Preview("Error State") {
    UserListView(state: .error)
}
```

## Performance Architecture

### Lazy Loading
```swift
LazyVStack {  // Only renders visible items
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### Task Management
```swift
.task {
    await loadData()  // Cancelled when view disappears
}
```

### Caching Strategies
- @State for ephemeral UI state
- UserDefaults for small persistent data
- SwiftData/CoreData for structured data
- File system for large data/images

## Build System

### Xcode Projects vs SPM
- **SPM**: Simple, modern, command-line friendly
- **Xcode Projects**: Full IDE integration, complex configurations

### Build Configuration
```swift
// Package.swift
let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [...],
    dependencies: [...],
    targets: [...]
)
```

### Compilation Optimization
- Use `final` on classes (enables devirtualization)
- Whole-module optimization in Release
- Incremental builds in Debug
- Build time tracking with `-Xfrontend -debug-time-compilation`
