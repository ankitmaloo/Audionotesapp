---
name: swift-app-builder
description: Build production-quality Swift applications for iOS and macOS using SwiftUI, following Apple's design principles and modern architecture patterns. Use this skill when creating new Swift/SwiftUI apps, implementing features, debugging Swift code, or when users ask for help with Swift development, iOS/macOS app design, SwiftUI views, app architecture, or performance optimization. Includes rapid validation tools, design guidelines, and architectural decision support.
---

# Swift App Builder

Build exceptional Swift applications with modern SwiftUI, following Apple's design language and best practices.

## Quick Start Workflow

1. **Understand requirements** → Ask clarifying questions about platform, features, and complexity
2. **Make architectural decisions** → Consult decision-prompts.md for consequential choices
3. **Scaffold project** (if new) → Use scaffold_project.py
4. **Implement features** → Follow SwiftUI patterns and design principles
5. **Validate quickly** → Use swift_validate.py for rapid feedback
6. **Iterate and refine** → Test with Xcode Previews and build

## Core Principles

### Apple-First Design
- Follow Human Interface Guidelines (see design-principles.md)
- Use native components and system colors
- Support Dynamic Type and accessibility
- Design for both light and dark modes
- Respect platform conventions (iOS vs macOS)

### Modern Swift Idioms
- Value types (struct) over reference types (class) by default
- Protocol-oriented programming where appropriate
- async/await for concurrency, avoid completion handlers
- @Observable for state management (iOS 17+)
- Leverage SwiftUI's declarative syntax

### Quick Validation Philosophy
Validate early and often without full builds:
- Type-check syntax with `swiftc -typecheck` (instant)
- Test logic in Xcode Previews (live updates)
- Run scripts/swift_validate.py for quick snippets
- Build minimally viable views first, iterate on details

## Scripts

### swift_validate.py
Rapidly validate Swift code without full project builds.

**Type checking:**
```bash
python scripts/swift_validate.py MyView.swift
```

**Run code snippet:**
```bash
python scripts/swift_validate.py --run test.swift
```

**Validate SwiftUI View:**
```bash
python scripts/swift_validate.py --view ContentView.swift
```

**Use this for**: Quick syntax checks, testing small functions, validating view code before integrating.

### scaffold_project.py
Create new Swift projects with proper structure.

**Create iOS app:**
```bash
python scripts/scaffold_project.py MyApp --platform ios
```

**Create macOS app:**
```bash
python scripts/scaffold_project.py MyApp --platform macos
```

**Create multiplatform app:**
```bash
python scripts/scaffold_project.py MyApp --platform multiplatform
```

Generates: Package.swift, app structure, .gitignore, and main SwiftUI view.

## Building Features: Step-by-Step Process

### 1. Clarify Requirements
Before writing code:
- What platform(s)? iOS, macOS, or both?
- What's the core user flow?
- Any specific design requirements or brand guidelines?
- Performance requirements or data complexity?

### 2. Identify Consequential Decisions
Check references/decision-prompts.md before proceeding if:
- New project (architecture, persistence, platform)
- Authentication needed (security implications)
- Complex state (state management pattern)
- External data (network layer design)
- Multiple languages (localization strategy)

**Present options to user when decisions have long-term impact.**

### 3. Plan the Architecture

**For simple apps (<5 screens):**
- @State in views for local UI state
- @Observable classes for shared state
- Direct network calls with async/await

**For moderate apps (5-15 screens):**
- MVVM: Views + ViewModels + Models
- @Observable ViewModels
- Service layer for network/persistence
- See architecture.md for details

**For complex apps (15+ screens, complex state):**
- Consider TCA or Redux-like patterns
- Proper dependency injection
- Comprehensive testing strategy

### 4. Implement Following Patterns

Reference files for implementation:
- **swiftui-patterns.md**: Navigation, lists, forms, async patterns
- **design-principles.md**: Layout, colors, typography, accessibility
- **architecture.md**: MVVM structure, data flow, compilation

### 5. Rapid Validation Loop

**Ideal workflow:**
1. Write view/logic in Xcode or editor
2. Add `#Preview` for instant visual feedback
3. For isolated logic: validate with swift_validate.py
4. For full feature: `swift build` and test
5. Iterate based on feedback

**Preview-Driven Development:**
```swift
struct UserProfileView: View {
    let user: User
    
    var body: some View {
        // Implementation
    }
}

#Preview("Standard User") {
    UserProfileView(user: .example)
}

#Preview("Premium User") {
    UserProfileView(user: .premiumExample)
}

#Preview("Empty State") {
    UserProfileView(user: .empty)
}
```

Previews are living documentation and light tests.

## Code Quality Guidelines

### SwiftUI View Structure
```swift
struct MyView: View {
    // 1. Property wrappers (@State, @Binding, etc.)
    @State private var isExpanded = false
    
    // 2. Regular properties
    let title: String
    
    // 3. Computed body
    var body: some View {
        // Keep simple, extract subviews
        VStack {
            headerView
            contentView
        }
    }
    
    // 4. Extracted subviews (for clarity)
    private var headerView: some View {
        Text(title)
            .font(.headline)
    }
    
    private var contentView: some View {
        if isExpanded {
            DetailContent()
        }
    }
}
```

### Naming Conventions
- **Views**: `UserProfileView`, `SettingsScreen`
- **ViewModels**: `UserProfileViewModel`, `SettingsViewModel`
- **Models**: `User`, `Article`, `Settings` (no suffix)
- **Services**: `APIService`, `AuthenticationService`
- **State**: `isLoading`, `showError`, `selectedItem`

### Performance Best Practices
1. **Lazy loading**: Use LazyVStack/LazyHStack for long lists
2. **Shallow hierarchies**: Keep view nesting < 10 levels
3. **Computed properties**: Cache expensive calculations
4. **Task cancellation**: Use `.task {}` for automatic cleanup
5. **@Observable**: Prefer over ObservableObject (less overhead)

### Accessibility Must-Haves
- Dynamic Type support (use system fonts)
- VoiceOver labels on images and icons
- Sufficient color contrast (test in accessibility inspector)
- Respect "Reduce Motion" preference
- Keyboard navigation support (macOS)

## Platform-Specific Considerations

### iOS Apps
- **Navigation**: NavigationStack for hierarchical content
- **Tabs**: 2-5 items in bottom tab bar
- **Lists**: Pull to refresh, swipe actions
- **Modality**: Sheets for auxiliary tasks, full-screen for immersive
- **Gestures**: Support standard iOS gestures

### macOS Apps
- **Windows**: Support multiple windows, resizable
- **Menus**: Full menu bar with keyboard shortcuts
- **Toolbars**: Top toolbar for primary actions
- **Sidebars**: Use for main navigation
- **Keyboard**: Extensive keyboard navigation

### Multiplatform Apps
- **Conditional UI**:
```swift
#if os(iOS)
    .navigationBarTitleDisplayMode(.large)
#elseif os(macOS)
    .frame(minWidth: 800, minHeight: 600)
#endif
```

- **Shared logic**: ViewModels, Models, Services work everywhere
- **Platform UI**: Separate views for platform-specific UIs
- **Size classes**: Use for responsive layouts

## Testing Strategy

### Xcode Previews (Fastest)
```swift
#Preview {
    ContentView()
}
```
Use for immediate visual feedback during development.

### Unit Tests (ViewModels & Logic)
```swift
import Testing

@Test func viewModelLoadsData() async throws {
    let viewModel = DataViewModel()
    await viewModel.load()
    #expect(viewModel.items.isEmpty == false)
}
```

### UI Tests (Critical Flows)
```swift
import XCTest

final class AppUITests: XCTestCase {
    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()
        // Test critical user journeys
    }
}
```

## Common Patterns & Solutions

See **swiftui-patterns.md** for:
- Navigation and routing
- Lists with search and swipe actions
- Forms with validation
- Async/await data loading
- State management patterns
- Animation and transitions
- Error handling
- Custom view modifiers

## Design Reference

See **design-principles.md** for:
- Apple's core design principles (Clarity, Deference, Depth)
- Color, typography, spacing guidelines
- SwiftUI layout patterns
- Platform-specific HIG
- Accessibility requirements
- Modern aesthetic (materials, corners, shadows)

## Architecture Reference

See **architecture.md** for:
- Swift compilation process and build modes
- Type system and memory management
- SwiftUI data flow and property wrappers
- MVVM and other architecture patterns
- Project structure organization
- Testing architecture
- Performance optimization techniques

## Decision Support

See **decision-prompts.md** for:
- When to ask user for input on choices
- Architecture pattern selection prompts
- Data persistence strategy questions
- Network layer design options
- Authentication approach decisions
- Platform targeting considerations
- Testing strategy levels

## Workflow Examples

### Building a New Feature
```
User: "Add a user profile screen with avatar, name, and edit button"

1. Check: Is architecture decided? (if new project, consult decision-prompts.md)
2. Create model: struct User { ... }
3. Create view: UserProfileView.swift
4. Add Preview with sample data
5. Validate: scripts/swift_validate.py --view UserProfileView.swift
6. Implement edit action (sheet or navigation)
7. Wire up in app navigation
8. Test in Xcode or build
```

### Debugging an Issue
```
User: "View isn't updating when data changes"

1. Check state management: Is @State/@Observable used correctly?
2. Verify property wrapper: @State for view-owned, @Binding for passed
3. Check for struct vs class: Views are structs, should be immutable
4. Test in Preview: Isolate the issue
5. Add print statements or breakpoints
6. Consult swiftui-patterns.md for correct pattern
```

### Optimizing Performance
```
User: "List scrolling is laggy with 1000 items"

1. Change VStack → LazyVStack
2. Check view complexity: Use Instruments to profile
3. Add .equatable() to expensive subviews
4. Cache computed properties
5. Ensure images are properly sized
6. Consider pagination if loading from network
```

## Key Reminders

- **Validate early**: Use swift_validate.py before full builds
- **Preview everything**: Add #Preview to all views
- **Ask before committing**: Present options for consequential decisions
- **Follow HIG**: Apple's guidelines are non-negotiable for quality apps
- **Keep views simple**: Extract subviews, keep body readable
- **Support accessibility**: It's a feature, not optional
- **Use native patterns**: Don't fight the platform

## Output Quality Standards

When generating Swift code:
1. **Compilable**: Must pass `swiftc -typecheck`
2. **Styled**: Follow Swift conventions and naming
3. **Accessible**: Include basic accessibility support
4. **Previewed**: Include relevant #Preview blocks
5. **Commented**: Brief comments for complex logic only
6. **Structured**: Proper view/model separation

Aim for code that could ship to the App Store with minimal changes.
