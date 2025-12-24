# Decision Prompts for Consequential Choices

When building Swift apps, certain architectural and design decisions have significant long-term impact. This guide outlines when to pause and ask the user for input on critical choices.

## When to Ask Questions

### 1. Architecture Pattern Selection

**When**: Setting up a new project or major feature
**Why**: Affects testability, maintainability, and team workflow

**Prompt Template**:
```
I'm setting up the app architecture. What pattern would you prefer?

1. **MVVM** (recommended for most SwiftUI apps)
   - Clear separation of concerns
   - Easy to test
   - Natural fit with SwiftUI
   
2. **TCA (The Composable Architecture)**
   - Predictable state management
   - Best for complex state machines
   - More boilerplate but very testable
   
3. **Simple/Minimal** (good for small apps)
   - State directly in views
   - Fastest to build
   - Harder to test/scale

Which approach fits your needs best?
```

### 2. Data Persistence Strategy

**When**: App needs to save data beyond app lifecycle
**Why**: Migration between persistence systems is costly

**Prompt Template**:
```
How should the app persist data?

1. **SwiftData** (modern, recommended for iOS 17+)
   - Declarative models with @Model
   - iCloud sync available
   - Type-safe queries
   
2. **Core Data** (mature, complex)
   - Battle-tested for large datasets
   - More control over performance
   - Steeper learning curve
   
3. **UserDefaults/Files** (simple)
   - Good for small amounts of data
   - No migration support
   - Manual serialization

What volume and complexity of data are you working with?
```

### 3. Network Layer Design

**When**: App communicates with backend APIs
**Why**: Affects error handling, testing, and API evolution

**Prompt Template**:
```
How should we structure the network layer?

1. **URLSession with async/await** (modern, lightweight)
   - Native Swift concurrency
   - No dependencies
   - Manual request building
   
2. **Service Protocol Pattern** (testable)
   - Easy to mock for testing
   - Clear API contract
   - More upfront work
   
3. **Third-party library** (e.g., Alamofire)
   - Feature-rich
   - Adds dependency
   - Well-documented patterns

What's your priority: simplicity, testability, or features?
```

### 4. Authentication Approach

**When**: App requires user login
**Why**: Security implications and user experience impact

**Prompt Template**:
```
What authentication method should we implement?

1. **Apple Sign In** (recommended for consumer apps)
   - Privacy-focused
   - One-tap sign in
   - Required if offering other social logins
   
2. **Email/Password** (traditional)
   - Full control
   - Need to handle password reset, security
   - More implementation work
   
3. **OAuth/Social** (Google, GitHub, etc.)
   - Easy for users
   - Depends on third-party availability
   - Privacy considerations

What type of app is this, and who are the users?
```

### 5. Platform Target Selection

**When**: Starting new project
**Why**: Affects UI patterns and available APIs

**Prompt Template**:
```
Which platforms should this app target?

1. **iOS only**
   - Use iOS-specific patterns (tab bars, etc.)
   - Full access to iOS APIs
   
2. **macOS only**
   - Desktop patterns (menu bars, toolbars)
   - Window management considerations
   
3. **Multiplatform (iOS + macOS)**
   - Shared business logic
   - Platform-specific UI adaptations
   - More testing surface

This affects navigation patterns and UI choices significantly.
```

### 6. Dependency Management

**When**: Need to add external libraries
**Why**: Affects build system and team workflow

**Prompt Template**:
```
How should we manage dependencies?

1. **Swift Package Manager** (recommended)
   - Built into Xcode
   - Modern, well-supported
   - Command-line friendly
   
2. **CocoaPods** (legacy but extensive)
   - Largest package ecosystem
   - Some packages not yet on SPM
   - Additional tooling required

Do you need any specific packages that might only be available via CocoaPods?
```

### 7. Localization Strategy

**When**: App may need multiple languages
**Why**: Difficult to retrofit; affects string handling throughout

**Prompt Template**:
```
Will this app need to support multiple languages?

1. **Yes, plan for it now**
   - Use String catalogs (.xcstrings)
   - NSLocalizedString throughout
   - More upfront structure
   
2. **No, English only**
   - Simpler string handling
   - Can add later (but harder)
   
3. **Maybe later**
   - Use string constants now
   - Makes retrofit easier

Even if not immediate, planning helps avoid technical debt.
```

### 8. Testing Strategy

**When**: Setting up project structure
**Why**: Hard to add comprehensive tests retroactively

**Prompt Template**:
```
What level of testing do you want?

1. **Comprehensive** (TDD approach)
   - Unit tests for ViewModels/logic
   - UI tests for critical flows
   - Snapshot tests for UI
   
2. **Moderate** (pragmatic)
   - Unit tests for business logic
   - UI tests for happy path
   
3. **Minimal** (move fast)
   - Test only critical paths
   - Rely on manual testing

This affects how we structure ViewModels and services.
```

### 9. Design System Approach

**When**: Multi-screen app with brand identity
**Why**: Consistency and maintenance efficiency

**Prompt Template**:
```
How should we handle UI consistency?

1. **Custom Design System**
   - Shared Colors, Fonts, Components
   - Brand-specific styling
   - Upfront investment
   
2. **Native Components** (standard iOS/macOS)
   - System colors and fonts
   - Automatic dark mode
   - Fastest to build
   
3. **Hybrid** (custom where needed)
   - Native base + custom accents
   - Balanced approach

Do you have existing brand guidelines or design assets?
```

### 10. State Management Complexity

**When**: App has complex interdependent state
**Why**: Simple solutions don't scale; complex ones add overhead

**Prompt Template**:
```
How complex is your app's state management?

1. **Simple** (few interconnected states)
   - @State and @Observable sufficient
   - Minimal indirection
   
2. **Moderate** (shared state, some async)
   - @Observable classes
   - Environment for sharing
   
3. **Complex** (many dependencies, real-time updates)
   - Consider TCA or Redux pattern
   - More structure, more testable

Examples of your app's key states would help me recommend.
```

## How to Use These Prompts

### Timing
- Ask **before** writing significant code
- Present options when architectural fork is reached
- Don't ask for decisions on trivial matters (use good defaults)

### Presentation
1. Provide 2-4 clear options
2. Note recommended default
3. Explain trade-offs briefly
4. Ask clarifying question to understand context

### After Answer
- Acknowledge the choice
- Proceed with implementation
- Document the decision in code comments if significant

## Example Decision Flow

```
[AI detects need for data persistence]

AI: "I notice you want to save user preferences and a reading list. 
     How should we persist this data?
     
     1. SwiftData (recommended) - Good for structured data like lists
     2. UserDefaults - Fine for simple preferences only
     3. Both - UserDefaults for preferences, SwiftData for reading list
     
     What's your preference?"

User: "Let's use SwiftData for everything"

AI: "Great! I'll set up SwiftData models for both preferences and the 
     reading list. This gives us type-safe queries and automatic iCloud 
     sync if you enable it later."

[AI proceeds with SwiftData implementation]
```

## Red Flags: When NOT to Ask

- User has already specified approach
- Decision is easily reversible
- One option is clearly superior for stated requirements
- Would interrupt flow for minor choice
- User explicitly asked for specific technology

In these cases: use best practices and proceed.
