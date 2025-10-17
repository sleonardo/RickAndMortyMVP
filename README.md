# 🚀 RickAndMorty MVP iOS App

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-green.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)

**A modern iOS application built with SwiftUI showcasing Clean Architecture + MVVM**

</div>

## ✨ Features

- 🎯 **Clean Architecture + MVVM** - Scalable and testable architecture
- 🔍 **Advanced Search** - Real-time search with debouncing
- 🎚️ **Smart Filtering** - Combine status and gender filters
- 💾 **Intelligent Caching** - Multi-layer cache strategy
- 📱 **Modern UI** - Built with SwiftUI and custom components
- ♿ **Full Accessibility** - VoiceOver and Dynamic Type support
- 🧪 **Comprehensive Testing** - Unit tests for all layers
- 🌙 **Dark Mode** - Full dark mode support
- 🔄 **Pagination** - Infinite scrolling for optimal performance

## 🏗️ Architecture Overview

<div align="center">

Presentation Layer (MVVM) → Domain Layer → Data Layer

↓ ↓ ↓

Views + ViewModels UseCases Repository + Data Sources
(SwiftUI + State) (Business Rules) (API + Cache)

</div>

## 🚀 Quick Start

### Prerequisites

- **Xcode 13.0+**
- **iOS 15.0+**
- **Swift 5.5+**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/RickAndMortyMVP.git
   cd RickAndMortyMVP
   
2. **Open the project**
    ```bash
    open RickAndMortyMVP.xcodeproj

3. **Build and run**

    - Select your target device or simulator

    - Press Cmd + R to build and run

# Running Tests
```bash
    # Run all unit tests
    xcodebuild test -scheme "RickAndMortyMVP" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

    # Or run directly from Xcode
    # Product → Test or Cmd + U
```

# 🔄 Data Flow
```swift
// 1. View triggers action
CharactersListView → ViewModel.loadCharacters()

// 2. ViewModel orchestrates
ViewModel → UseCase.getCharacters()

// 3. UseCase contains business logic
UseCase → Repository.getCharacters()

// 4. Repository decides data source
Repository → Cache → API (if needed)

// 5. Data flows back
API/Cache → Repository → UseCase → ViewModel → View
```

# 🎨 UI Components

### Custom Components
- SearchBar - Debounced search with clear functionality

- FiltersView - Modal filter selection

- ErrorBannerView - User-friendly error display

- EmptyStateView - Beautiful empty states

- FilterChip - Interactive filter tags

### Accessibility Features
- VoiceOver Support - Complete screen reader compatibility

- Dynamic Type - Adapts to user's text size preferences

- Accessibility Labels - Descriptive labels for all interactive elements

- Contrast Ratios - WCAG compliant color contrast

# 📈 Performance Optimizations
- Lazy Loading - Images and paginated content

- Debounced Search - 300ms delay to reduce API calls

- Memory Management - Automatic cache cleanup

- Background Processing - Async image loading

- Efficient Rendering - SwiftUI performance best practices

