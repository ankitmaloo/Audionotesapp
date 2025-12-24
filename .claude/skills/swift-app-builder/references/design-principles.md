# Apple Design Principles & Human Interface Guidelines

## Core Design Principles

### 1. Clarity
- Text is legible at all sizes
- Icons are precise and lucid
- Adornments are subtle and appropriate
- Design is driven by functionality

### 2. Deference
- Fluid motion and crisp interface help people understand and interact with content
- Content never competes with chrome
- Bezels, gradients, and drop shadows are minimized

### 3. Depth
- Visual layers and realistic motion convey hierarchy
- Touch and discoverability heighten delight
- Transitions provide sense of depth as you navigate

## SwiftUI Design Patterns

### Layout Philosophy
- **VStack/HStack/ZStack over frames**: Let SwiftUI handle layout naturally
- **Spacer() for flexibility**: Use spacers instead of fixed padding when possible
- **GeometryReader sparingly**: Only when you truly need parent dimensions
- **.frame() modifiers**: Use minWidth/idealWidth/maxWidth for responsive layouts

### Visual Hierarchy
```swift
// Good: Clear visual hierarchy
VStack(alignment: .leading, spacing: 12) {
    Text("Title")
        .font(.title2.bold())
    Text("Subtitle")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}

// Avoid: Flat hierarchy
VStack {
    Text("Title")
    Text("Subtitle")
}
```

### Color Usage
- **System colors**: Use .primary, .secondary, .tertiary for text
- **Semantic colors**: .red, .blue for meaning, not decoration
- **Adaptive colors**: Always support both light and dark modes
- **Accent colors**: Use sparingly for CTAs and important actions

### Typography
- **System fonts**: Use SF Pro (default) for consistency
- **Dynamic Type**: Always support accessibility text sizes
- **Hierarchy**: Title → Headline → Body → Caption → Footnote

### Spacing & Padding
- 4pt grid system (4, 8, 12, 16, 20, 24, 32...)
- Standard padding: 16pt for primary content
- Compact padding: 8pt for dense UIs
- Generous padding: 24pt+ for focus areas

## Platform-Specific Guidelines

### iOS
- **Navigation**: Use NavigationStack for hierarchical content
- **Lists**: Native list styles (inset, plain, grouped)
- **Sheets & Alerts**: Use .sheet() and .alert() modifiers
- **Tab bars**: Bottom placement, 2-5 tabs
- **Safe areas**: Respect notch, home indicator

### macOS
- **Windows**: Multiple windows, resizable, movable
- **Sidebars**: Primary navigation in sidebar
- **Toolbars**: Top placement for actions
- **Menus**: Full menu bar support
- **Keyboard**: Support keyboard navigation extensively

## Aesthetic Best Practices

### Modern iOS/macOS Look
1. **Materials**: Use .ultraThinMaterial, .regularMaterial for depth
2. **Corner Radius**: 10-12pt for cards, 8pt for buttons
3. **Shadows**: Subtle, use .shadow(radius: 2, y: 1)
4. **Animations**: Spring animations, 0.3-0.5s duration
5. **Iconography**: SF Symbols (native, consistent)

### What to Avoid
- Heavy drop shadows (pre-iOS 7 skeuomorphism)
- Excessive gradients
- Non-standard controls (unless truly necessary)
- Tiny touch targets (<44pt)
- Auto-layout conflicts (SwiftUI handles this)

### Interaction Patterns
- **Pull to refresh**: Standard in lists
- **Swipe actions**: Leading/trailing in lists
- **Context menus**: Long press for options
- **Drag and drop**: Where content can be moved
- **Gestures**: Tap, long press, drag, pinch, rotate

## Accessibility

### Must-Have Features
1. **Dynamic Type**: Scale with user preferences
2. **VoiceOver**: Proper labels and hints
3. **High Contrast**: Test in accessibility mode
4. **Reduce Motion**: Respect animation preferences
5. **Color Blindness**: Don't rely on color alone

### Implementation
```swift
// Dynamic Type support
Text("Hello")
    .font(.body)  // Scales automatically

// VoiceOver
Image(systemName: "heart")
    .accessibilityLabel("Favorite")

// Reduce Motion
@Environment(\.accessibilityReduceMotion) var reduceMotion
```

## Performance Guidelines

### Optimization
- Keep view hierarchies shallow (< 10 levels)
- Use LazyVStack/LazyHStack for long lists
- Avoid .frame() on every view
- Cache expensive computations with @State or computed properties
- Profile with Instruments for complex views

### Memory
- Weak references in closures when capturing self
- Dispose of large resources when views disappear
- Use @StateObject properly (one instance per view lifecycle)

## Resources

**Official Guidelines:**
- Human Interface Guidelines: developer.apple.com/design/human-interface-guidelines
- SF Symbols: developer.apple.com/sf-symbols

**Design Tools:**
- SF Symbols App (macOS)
- Xcode Previews for rapid iteration
- Accessibility Inspector in Simulator
