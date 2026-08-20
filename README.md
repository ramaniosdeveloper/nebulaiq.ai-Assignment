# GeoTrackAssignment

A SwiftUI-based geo-fencing tracking application built using **MVVM + Clean Architecture + Repository Pattern**.

The application allows users to create tracking groups, associate a geo-fence with a group, monitor the user's location, and generate a notification when the user moves outside the configured geo-fenced region.

---

## Features

- Create a tracking group.
- Associate a geo-fence with the group.
- Use the device's current location as the geo-fence center.
- Configure the geo-fence radius.
- Load groups associated with the current user.
- Join an existing group.
- Select an active tracking group.
- Monitor the active geo-fence using Core Location.
- Detect geo-fence exit events.
- Report the user's latest location.
- Evaluate whether the user is inside or outside the configured region.
- Trigger a local notification when the user moves outside the geo-fence.
- Support in-memory repositories for assignment/demo usage.
- Provide remote repository implementations for REST API integration.
- Keep business logic independent from SwiftUI, Core Location, and networking.

---

## Architecture

The project follows a Clean Architecture structure with MVVM in the Presentation layer.

```text
+--------------------------------------------------+
|                 Presentation                     |
|                                                  |
|  GroupListView                                   |
|  CreateGroupView                                 |
|        |                                         |
|        v                                         |
|  GroupViewModel                                  |
+--------------------------|-----------------------+
                           |
                           v
+--------------------------------------------------+
|                    Domain                        |
|                                                  |
|  Models                                          |
|  Use Cases                                       |
|    - CreateGroupUseCase                          |
|    - JoinGroupUseCase                            |
|    - ReportLocationUseCase                       |
|  Repository Protocols                            |
|  GeoFenceEvaluator                               |
+--------------------------|-----------------------+
                           |
                           v
+--------------------------------------------------+
|                     Data                         |
|                                                  |
|  InMemoryGroupRepository                         |
|  InMemoryLocationRepository                      |
|  GroupRepositoryRemote                           |
|  LocationRepositoryRemote                        |
|  DTOs                                             |
|  HTTPClient                                      |
+--------------------------|-----------------------+
                           |
                           v
+--------------------------------------------------+
|                   Services                       |
|                                                  |
|  LocationService                                 |
|  PushService                                     |
|  NotificationDelegate                            |
|  LocalNotificationRepository                     |
+--------------------------------------------------+
```

### Dependency Direction

The main principle is:

```text
Presentation
     |
     v
Domain
     ^
     |
Data / Services
```

The Domain layer depends on repository **protocols**, not concrete data sources. This allows the application to use an in-memory repository for the assignment and a remote repository for a production backend without changing the business use cases.

---

## Project Layers

### 1. Presentation

The Presentation layer contains SwiftUI views and the ViewModel.

#### `GroupListView`

Responsible for:

- Displaying tracking groups.
- Loading groups when the screen starts.
- Selecting a group.
- Navigating to group creation.
- Showing error/status messages.

The view uses `GroupViewModel` as its observable state holder.

#### `CreateGroupView`

Responsible for:

- Accepting the group name.
- Accepting the geo-fence radius.
- Obtaining the current device location.
- Validating the input.
- Calling the ViewModel to create the group.

The current device location is used as the center of the geo-fence.

#### `GroupViewModel`

The ViewModel coordinates the Presentation layer with the application/domain layer.

Main responsibilities:

- Load groups.
- Create groups.
- Join groups.
- Select the active group.
- Start geo-fence monitoring.
- Report location through the location use case.
- Expose errors/status messages to SwiftUI.

Important published state:

```swift
@Published var groups: [Group]
@Published var selectedGroup: Group?
@Published var statusMessage: String?
```

The ViewModel is isolated to the main actor because it owns UI-observable state.

---

# 2. Domain

The Domain layer contains the application's business concepts and rules.

## Domain Models

### `Group`

Represents a tracking group.

Conceptually:

```text
Group
 ├── id
 ├── name
 ├── members
 └── geoFence
```

### `User`

Represents a user participating in a tracking group.

### `GeoFence`

Represents the geographic boundary:

```text
center latitude
center longitude
radius in meters
```

### `LocationSnapshot`

Represents a location reported by a user:

```text
user ID
timestamp
latitude
longitude
```

### `GroupID` and `UserID`

Strongly typed identifiers are used instead of passing raw strings everywhere. This improves type safety and makes the domain APIs clearer.

---

## Use Cases

### `CreateGroupUseCase`

Responsible for the business workflow of creating a tracking group.

Flow:

```text
GroupViewModel
      |
      v
CreateGroupUseCase
      |
      +--> AuthRepository
      |       |
      |       v
      |   Current User
      |
      +--> GroupRepository
              |
              v
          Create Group
```

The authenticated user becomes the owner of the newly created group.

---

### `JoinGroupUseCase`

Responsible for adding the current user to an existing tracking group.

Flow:

```text
GroupViewModel
      |
      v
JoinGroupUseCase
      |
      +--> AuthRepository
      |
      +--> GroupRepository.addMember()
      |
      v
Updated Group
```

---

### `ReportLocationUseCase`

This is the main business workflow for geo-fence tracking.

Responsibilities:

1. Get the current user.
2. Create a `LocationSnapshot`.
3. Store/report the location.
4. Retrieve the group.
5. Evaluate the location against the group's geo-fence.
6. If the user is outside the geo-fence, notify the other group members.

Flow:

```text
LocationService
      |
      v
ReportLocationUseCase
      |
      +--> AuthRepository
      |
      +--> LocationRepository
      |
      +--> GroupRepository
      |
      +--> GeoFenceEvaluator
      |
      +--> NotificationRepository
```

The use case contains the business orchestration instead of putting business rules inside the Core Location service or SwiftUI ViewModel.

---

## `GeoFenceEvaluator`

Responsible for determining whether a coordinate is inside the configured geo-fence.

The evaluator calculates the geographic distance between:

```text
GeoFence Center
       |
       v
Current Location
```

and compares the calculated distance with the configured radius.

Example:

```text
Radius = 100 meters

Distance = 50 meters
50 <= 100
      |
      v
   INSIDE
```

If:

```text
Distance = 150 meters
150 > 100
       |
       v
    OUTSIDE
```

The distance calculation uses the Haversine formula.

Keeping this logic in the Domain layer makes the business rule independent of Core Location and easy to unit test.

---

# 3. Repository Layer

Repositories define how the application accesses data.

The Domain layer uses repository protocols such as:

```text
GroupRepository
LocationRepository
NotificationRepository
AuthRepository
```

Concrete implementations can be changed without modifying the use cases.

---

## `GroupRepository`

Defines operations such as:

```text
createGroup
addMember
getGroup
updateGeoFence
listGroups
```

---

## `LocationRepository`

Defines location reporting:

```text
postLocation
```

---

## `NotificationRepository`

Defines notification behavior:

```text
notifyMembers
```

The Domain layer does not need to know whether notification delivery is local, APNs-based, or backend-driven.

---

# 4. Data Layer

## `InMemoryGroupRepository`

An in-memory implementation of `GroupRepository`.

It stores groups in memory and is useful for:

- Assignment/demo execution.
- SwiftUI previews.
- Testing without a backend.

Data is not persistent and is lost when the application process ends.

---

## `InMemoryLocationRepository`

Stores location snapshots in memory, grouped by `GroupID`.

Conceptually:

```text
Group A
 ├── LocationSnapshot 1
 ├── LocationSnapshot 2
 └── LocationSnapshot 3
```

---

## `GroupRepositoryRemote`

Remote implementation of `GroupRepository`.

It uses `HTTPClient` to communicate with REST endpoints.

Supported operations include:

```text
POST /groups
POST /groups/{groupId}/members
GET  /groups/{groupId}
PUT  /groups/{groupId}/geofence
GET  /users/{userId}/groups
```

API DTOs are converted into Domain models before being returned to the application.

---

## `LocationRepositoryRemote`

Remote implementation for reporting locations.

It sends location information to the backend through `HTTPClient`.

Conceptually:

```text
LocationSnapshot
      |
      v
LocationRepositoryRemote
      |
      v
HTTPClient
      |
      v
REST API
```

---

## DTOs

API-specific objects such as:

```text
GroupDTO
GeoDTO
```

represent the backend response/request format.

DTOs are converted to Domain objects using mapping such as:

```text
GroupDTO
   |
   v
toDomain()
   |
   v
Group
```

This prevents API-specific models from leaking into the Domain layer.

---

# 5. Networking

## `HTTPClient`

Provides common HTTP functionality for remote repositories.

Responsibilities include:

- Build URLs.
- Execute HTTP requests.
- Support GET/POST/PUT operations.
- Encode JSON request bodies.
- Decode JSON responses.
- Validate HTTP responses.
- Use Swift concurrency with `async/await`.

Architecture:

```text
Remote Repository
       |
       v
   HTTPClient
       |
       v
    URLSession
       |
       v
   Backend API
```

Repositories therefore focus on repository operations and DTO mapping rather than repeating low-level networking code.

---

# 6. Services

## `LocationService`

Responsible for Core Location functionality.

Responsibilities:

- Request location permissions.
- Request current location.
- Start geo-fence monitoring.
- Handle Core Location delegate callbacks.
- Publish the current location.
- React to geo-fence exit events.
- Forward updated locations to the location reporting workflow.

It uses:

```text
CLLocationManager
CLCircularRegion
```

### Current Location Flow

```text
Group/Create Screen
       |
       v
LocationService
       |
       v
CLLocationManager
       |
       v
Current CLLocation
```

The service also bridges the delegate-based Core Location API to Swift Concurrency using a checked continuation for `async/await` callers.

---

## Geo-fence Monitoring

When a group becomes active:

```text
GroupViewModel
      |
      v
LocationService.startMonitoring()
      |
      v
CLCircularRegion
      |
      v
CLLocationManager
```

The application configures the region to respond to exit events.

```text
notifyOnEntry = false
notifyOnExit  = true
```

---

## Geo-fence Exit Flow

When the user leaves the monitored region:

```text
Core Location
      |
      v
didExitRegion()
      |
      v
Request latest location
      |
      v
didUpdateLocations()
      |
      v
ReportLocationUseCase
```

The latest location is then evaluated against the group's geo-fence.

---

# 7. Notifications

## `LocalNotificationRepository`

Uses Apple's `UNUserNotificationCenter` to create local notifications.

It checks notification authorization and creates an immediate notification request.

Example:

```text
Title:
Member left geofence

Body:
<user> moved out of the region.
```

For this assignment, the notification is generated locally on the current device.

In a production implementation, this repository can be replaced by a backend/APNs-based implementation for notifying other group members.

---

## `NotificationDelegate`

Implements:

```swift
UNUserNotificationCenterDelegate
```

Responsibilities:

- Handle notifications received while the application is in the foreground.
- Configure foreground presentation.
- Handle notification taps.
- Clear the application badge after a notification is opened.

Foreground notifications are configured to display:

```text
Banner
Sound
Badge
```

---

## `PushService`

Responsible for:

- Requesting notification authorization.
- Registering the application for remote notifications/APNs.

Difference between notification classes:

| Component | Responsibility |
|---|---|
| `PushService` | Permission and APNs registration |
| `LocalNotificationRepository` | Create local notifications |
| `NotificationDelegate` | Handle notification presentation and user interaction |

---

# 8. Dependency Injection

## `Dependencies`

Acts as the composition point for the application's concrete implementations.

Conceptually:

```text
Dependencies
 ├── GroupRepository
 ├── LocationRepository
 ├── NotificationRepository
 ├── AuthRepository
 ├── CreateGroupUseCase
 ├── JoinGroupUseCase
 ├── ReportLocationUseCase
 └── LocationService
```

This allows the application to inject dependencies into `GroupViewModel`.

For example, the assignment can use:

```text
InMemoryGroupRepository
InMemoryLocationRepository
LocalNotificationRepository
```

while production can use:

```text
GroupRepositoryRemote
LocationRepositoryRemote
Backend/APNs NotificationRepository
```

without changing the core business logic.

---

# 9. Application Startup

`GeoTrackAssignmentApp` is the SwiftUI application entry point.

Startup flow:

```text
GeoTrackAssignmentApp
        |
        +--> Configure NotificationDelegate
        |
        +--> Request Notification Permission
        |
        +--> Request Location Permission
        |
        +--> Build Dependencies
        |
        +--> Create GroupViewModel
        |
        +--> Show GroupListView
```

---

# 10. End-to-End Demo Flow

The easiest way to demonstrate the application is:

### Step 1 — Launch the application

The app configures notifications and location services.

### Step 2 — Load groups

```text
GroupListView
     ↓
GroupViewModel.loadGroups()
     ↓
AuthRepository
     ↓
GroupRepository
```

### Step 3 — Create a group

Enter:

```text
Group Name: Family
Radius: 100 meters
```

The device's current location becomes the geo-fence center.

### Step 4 — Create

```text
CreateGroupView
     ↓
GroupViewModel.create()
     ↓
CreateGroupUseCase
     ↓
GroupRepository
```

### Step 5 — Start monitoring

```text
GroupViewModel
     ↓
LocationService
     ↓
CLCircularRegion
     ↓
CLLocationManager
```

### Step 6 — Leave the region

Core Location calls:

```text
didExitRegion()
```

### Step 7 — Report location

```text
LocationService
     ↓
ReportLocationUseCase
```

### Step 8 — Evaluate geo-fence

```text
Current Location
      +
Group GeoFence
      |
      v
GeoFenceEvaluator
      |
      +---- Inside  → No notification
      |
      +---- Outside → Notify
```

### Step 9 — Notification

```text
ReportLocationUseCase
      ↓
NotificationRepository
      ↓
LocalNotificationRepository
      ↓
UNUserNotificationCenter
      ↓
User Notification
```

---

# 11. Why Clean Architecture?

The main advantages in this project are:

### Separation of concerns

Each component has one primary responsibility.

```text
View              → UI
ViewModel         → UI state/orchestration
Use Case          → Business workflow
Repository        → Data access
LocationService   → Core Location
HTTPClient        → Networking
Notification      → Notification delivery
```

### Testability

The business logic can be tested using repository protocols and fake/in-memory implementations without requiring:

- Real GPS
- Backend server
- APNs
- SwiftUI

### Replaceable data sources

The application can switch:

```text
InMemory Repository
        ↓
Remote Repository
```

without changing the use cases.

### Platform independence of business rules

`GeoFenceEvaluator` and the use cases do not depend directly on Core Location or SwiftUI.

---

# 12. Testing Strategy

The architecture supports testing at multiple levels.

### Domain tests

Test:

- Geo-fence inside/outside calculation.
- Group creation rules.
- Join group behavior.
- Location reporting workflow.

### Repository tests

Test:

- Group creation.
- Group lookup.
- Member addition.
- Location storage.

### ViewModel tests

Test:

- Loading groups.
- Creating groups.
- Joining groups.
- Selecting groups.
- Error/status handling.

### UI tests

Test:

- Group list.
- Create group screen.
- Form validation.
- Navigation.

---

# 13. Production Improvements

The assignment uses in-memory repositories and local notifications for a backend-independent demonstration.

For a production implementation, the following can be added:

- Backend authentication.
- Persistent database/cache.
- Real remote group/location repositories.
- APNs/backend notification delivery.
- Secure device/user authentication.
- Background location strategy based on product requirements.
- Retry and offline handling.
- More detailed error mapping.
- Unit and UI test coverage.
- Dependency injection through a more formal container if the application grows.
- Observability/logging.

---

# 14. Key Design Principles

The project demonstrates:

- **MVVM**
- **Clean Architecture**
- **Repository Pattern**
- **Use Case Pattern**
- **Dependency Injection**
- **Dependency Inversion**
- **Protocol-oriented design**
- **Single Responsibility Principle**
- **Swift Concurrency**
- **Core Location**
- **Local Notifications**
- **DTO → Domain mapping**

---

## Summary

The core business flow is:

```text
User
 |
 v
SwiftUI View
 |
 v
GroupViewModel
 |
 v
Use Case
 |
 +--------------------+
 |                    |
 v                    v
Repository       LocationService
 |                    |
 v                    v
Data              Core Location
                      |
                      v
                Location Update
                      |
                      v
              ReportLocationUseCase
                      |
                      v
              GeoFenceEvaluator
                 /          \
                /            \
            INSIDE          OUTSIDE
              |                |
              v                v
           Nothing       Notification
```

The main architectural goal is to keep **business rules independent from UI, networking, Core Location, and notification implementation details**. This makes the application easier to test, maintain, and evolve from the current assignment/demo implementation toward a production backend.
