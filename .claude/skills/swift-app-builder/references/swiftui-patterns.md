# SwiftUI Common Patterns & Quick Solutions

## Navigation Patterns

### NavigationStack (iOS 16+)
```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}
```

### Programmatic Navigation
```swift
@State private var path = NavigationPath()

NavigationStack(path: $path) {
    // ...
}

// Navigate programmatically
path.append(item)

// Pop to root
path.removeLast(path.count)
```

### Sheet Presentation
```swift
@State private var showingSheet = false

Button("Show") {
    showingSheet = true
}
.sheet(isPresented: $showingSheet) {
    DetailView()
}
```

## List Patterns

### Basic List
```swift
List(items) { item in
    ItemRow(item: item)
}
```

### Swipe Actions
```swift
List(items) { item in
    Text(item.name)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
                delete(item)
            }
        }
        .swipeActions(edge: .leading) {
            Button("Archive") {
                archive(item)
            }
        }
}
```

### Search
```swift
@State private var searchText = ""

List(filteredItems) { item in
    ItemRow(item: item)
}
.searchable(text: $searchText)

var filteredItems: [Item] {
    searchText.isEmpty ? items : items.filter { 
        $0.name.contains(searchText) 
    }
}
```

### Pull to Refresh
```swift
List(items) { item in
    ItemRow(item: item)
}
.refreshable {
    await loadItems()
}
```

## Form Patterns

### Basic Form
```swift
Form {
    Section("Personal") {
        TextField("Name", text: $name)
        DatePicker("Birthday", selection: $birthday)
    }
    
    Section("Preferences") {
        Toggle("Notifications", isOn: $notificationsEnabled)
        Picker("Theme", selection: $theme) {
            Text("Light").tag(Theme.light)
            Text("Dark").tag(Theme.dark)
        }
    }
}
```

### Validation
```swift
var isValid: Bool {
    !name.isEmpty && email.contains("@")
}

Button("Submit") {
    submit()
}
.disabled(!isValid)
```

## Async/Await Patterns

### Loading Data
```swift
@State private var items: [Item] = []
@State private var isLoading = false

var body: some View {
    List(items) { item in
        ItemRow(item: item)
    }
    .task {
        await loadItems()
    }
}

func loadItems() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        items = try await fetchItems()
    } catch {
        // Handle error
    }
}
```

### Concurrent Operations
```swift
await withTaskGroup(of: Data.self) { group in
    for url in urls {
        group.addTask {
            await fetch(url)
        }
    }
    
    for await data in group {
        process(data)
    }
}
```

## State Management Patterns

### Local State
```swift
@State private var count = 0

Button("Increment") {
    count += 1
}
```

### Shared State (Environment)
```swift
@Observable
class AppSettings {
    var isDarkMode = false
}

// In app root
@State private var settings = AppSettings()

WindowGroup {
    ContentView()
        .environment(settings)
}

// In child views
@Environment(AppSettings.self) private var settings
```

### Persisted State
```swift
@AppStorage("username") private var username = ""

// Automatically synced with UserDefaults
TextField("Username", text: $username)
```

## Animation Patterns

### Implicit Animation
```swift
@State private var isExpanded = false

Rectangle()
    .frame(height: isExpanded ? 200 : 100)
    .animation(.spring(response: 0.3), value: isExpanded)
```

### Explicit Animation
```swift
Button("Animate") {
    withAnimation(.spring()) {
        isExpanded.toggle()
    }
}
```

### Transitions
```swift
if showDetails {
    DetailView()
        .transition(.move(edge: .trailing))
}
```

### Hero Animations
```swift
// iOS 18+
Image("photo")
    .matchedTransitionSource(id: "photo", in: namespace)

// In destination
Image("photo")
    .matchedTransitionDestination(id: "photo", in: namespace)
```

## Error Handling Patterns

### Try-Catch with UI Feedback
```swift
@State private var error: Error?
@State private var showError = false

func performAction() async {
    do {
        try await riskyOperation()
    } catch {
        self.error = error
        showError = true
    }
}

.alert("Error", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(error?.localizedDescription ?? "Unknown error")
}
```

### Result Type
```swift
@State private var result: Result<Data, Error>?

switch result {
case .success(let data):
    SuccessView(data: data)
case .failure(let error):
    ErrorView(error: error)
case nil:
    LoadingView()
}
```

## Layout Patterns

### Adaptive Stack
```swift
// Horizontal on wide screens, vertical on narrow
ViewThatFits {
    HStack { content }
    VStack { content }
}
```

### Grid Layout
```swift
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 100))
]) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### Overlay Pattern
```swift
Image("background")
    .overlay {
        VStack {
            Spacer()
            Text("Caption")
                .padding()
                .background(.ultraThinMaterial)
        }
    }
```

## Custom View Modifiers

### Reusable Styling
```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background.secondary)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

## Performance Patterns

### Lazy Views
```swift
// Bad: Creates all views immediately
ScrollView {
    ForEach(1000..<2000) { i in
        HeavyView(id: i)
    }
}

// Good: Creates views as needed
ScrollView {
    LazyVStack {
        ForEach(1000..<2000) { i in
            HeavyView(id: i)
        }
    }
}
```

### Equatable for Performance
```swift
struct ExpensiveView: View, Equatable {
    let data: Data
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data.id == rhs.data.id
    }
    
    var body: some View {
        // Complex rendering
    }
}

// Use with .equatable()
ExpensiveView(data: data)
    .equatable()
```

## Platform-Specific Patterns

### Conditional Compilation
```swift
#if os(iOS)
    .listStyle(.insetGrouped)
#elseif os(macOS)
    .listStyle(.sidebar)
#endif
```

### Device Detection
```swift
@Environment(\.horizontalSizeClass) var sizeClass

if sizeClass == .compact {
    CompactLayout()
} else {
    RegularLayout()
}
```

## Common Quick Fixes

### Keyboard Dismissal
```swift
@FocusState private var isFieldFocused: Bool

TextField("Search", text: $query)
    .focused($isFieldFocused)

Button("Done") {
    isFieldFocused = false
}
```

### Safe Area Management
```swift
// Ignore safe area for background
Color.blue
    .ignoresSafeArea()

// Content respects safe area
VStack {
    // Content
}
```

### Preview Variants
```swift
#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    ContentView()
        .environment(\.dynamicTypeSize, .accessibility3)
}
```
