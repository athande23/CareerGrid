# CareerGrid

CareerGrid is an iOS application designed to help students organise their job search, track applications, prepare for interviews, and manage important recruitment dates in one place.

## Features

- **Home:** Browse job opportunities and add new opportunities with relevant application details.
- **Saved Jobs:** Save opportunities for later and remove jobs from your saved list.
- **Applications:** Track applications and update their recruitment stages as the process progresses.
- **Interview Preparation:** Access interview preparation information and manage interview questions and notes.
- **Calendar:** Organise recruitment-related events and important dates.
- **WidgetKit Extension:** View the next upcoming job application deadline from the Home Screen.
- **Share Extension:** Share job information with CareerGrid to import opportunities into the app.
- **Persistent Storage:** Store job opportunities, applications, interview preparation information, and calendar events using Core Data.

## Technology Stack

- Swift
- SwiftUI
- Core Data
- WidgetKit
- App Extensions
- App Groups
- XCTest / Swift Testing

## Architecture

CareerGrid uses a layered architecture to separate the user interface, application logic, and data persistence.

The main application follows this dependency structure:

1. **Views:** Display the user interface and handle user interactions.
2. **ViewModels:** Manage view state and coordinate user actions.
3. **Use Cases:** Encapsulate individual application operations and business rules.
4. **Repositories:** Define the data-access interface and coordinate persistence operations.
5. **Core Data:** Persist application data across launches.

The WidgetKit and Share Extensions use the configured App Group shared container to exchange the data required between the extensions and the main application.

## Data Persistence

Core Data provides persistent storage for CareerGrid's main application data. Repository implementations abstract the underlying storage operations, while repository protocols allow application logic to be tested using mock repositories.

## Testing

CareerGrid includes unit tests for application use cases and related business logic. Mock repositories allow tests to verify application behaviour without depending on the production Core Data store.

To run the tests:

1. Open `CareerGrid.xcodeproj` in Xcode.
2. Select a compatible iOS Simulator.
3. Select **Product → Test** to run the test suite.

## Setup

1. Clone or download the repository.
2. Open `CareerGrid.xcodeproj` in Xcode.
3. Select an appropriate development team and configure signing for the app and extension targets if required.
4. Ensure the App Group capability and identifier are configured consistently across the relevant targets.
5. Build and run the application on a compatible iOS Simulator or device.

## Project Structure

The project is organised into separate areas for domain models, use cases, repository implementations, view models, views, extensions, and tests. This structure supports separation of responsibilities and makes individual components easier to maintain and test.
