# Trading App

A Flutter application that displays real-time trading instrument data from Finnhub API, built using Test-Driven Development (TDD) and the BLoC pattern.

## Overview

This application provides a real-time view of trading instruments (forex pairs) with price updates via WebSocket connections.
The app demonstrates best practices in Flutter development, including:

- Clean architecture with separation of concerns
- BLoC pattern for state management
- Real-time data handling with WebSockets
- Error handling and graceful degradation
- Comprehensive test coverage using a TDD approach

## Features

- Display a list of trading instruments with real-time price updates
- Visual indicators for price movements (up/down/stable)
- Search functionality to filter instruments
- Connection status indicator
- Error handling with retry options

## Architecture

The application follows a layered architecture based on the BLoC pattern:

### Models
- `TradingInstrument`: Represents a single trading instrument with price data

### Repository
- `TradingInstrumentsRepository`: Abstracts data access from the business logic

### BLoC (Business Logic Component)
- `TradingInstrumentsBloc`: Handles state transitions and business logic
- `TradingInstrumentsEvent`: Input events that trigger state changes
- `TradingInstrumentsState`: Immutable states representing the UI state

### Services
- `FinnhubService`: Handles API communication with Finnhub, including REST and WebSocket

### UI
- Screens, widgets, and components organized by functionality
- Clear separation between data, business logic, and presentation

## Test-Driven Development

This project follows a strict TDD approach:

1. Tests are written first to define expected behavior
2. Implementation code is written to make tests pass
3. Code is refactored without changing behavior

The application includes:

- BLoC tests to verify state transitions
- Repository tests to verify data handling
- Unit tests for models and services
- Widget tests for UI components
- Mocking of external dependencies

## State Management with BLoC

The app uses the BLoC pattern for state management:

- Events are dispatched from the UI to the BLoC
- The BLoC processes events and emits new states
- The UI rebuilds based on the new state
- Data flows in one direction (UI → Event → BLoC → State → UI)

## Setup and Running

1. Replace the API key in `FinnhubService` with your own API key from Finnhub
   ```dart
   static const String _apiKey = 'YOUR_API_KEY';
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run tests
   ```
   flutter test
   ```

4. Run the application
   ```
   flutter run
   ```

## Dependencies

- bloc, flutter_bloc: State management with BLoC pattern
- equatable: Value equality comparisons for BLoC states and events
- rxdart: Advanced stream operations
- http: REST API calls
- web_socket_channel: WebSocket connection
- intl: Formatting numbers and dates
- flutter_test, bloc_test: Testing frameworks
- mockito, mocktail: Mocking for tests

