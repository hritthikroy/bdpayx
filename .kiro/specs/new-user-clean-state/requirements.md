# Requirements Document

## Introduction

This feature addresses the issue where new users see demo/fake balance and transaction data instead of starting with a clean slate. The goal is to make the currency exchange app professional by ensuring new users see their actual (zero) balances and empty transaction history, while providing a welcoming onboarding experience.

## Glossary

- **User**: A person who has registered or logged into the BDPayX currency exchange application
- **Balance**: The amount of currency (BDT or INR) available in a user's account
- **Transaction**: A record of a financial operation (deposit, withdrawal, exchange) performed by a user
- **Demo Data**: Hardcoded fake balances and transactions currently shown to all users
- **Clean State**: The initial state for new users with zero balances and no transaction history
- **Empty State UI**: A user-friendly interface shown when there is no data to display

## Requirements

### Requirement 1

**User Story:** As a new user, I want to see my actual zero balance when I first log in, so that I understand my real financial position in the app.

#### Acceptance Criteria

1. WHEN a new user logs in for the first time THEN the System SHALL display zero (0.00) for both BDT and INR balances
2. WHEN the System displays user balances THEN the System SHALL fetch balance data from the backend API or user profile
3. WHEN the backend is unavailable THEN the System SHALL display the last cached balance or zero if no cache exists
4. IF the user has not completed any transactions THEN the System SHALL NOT display any demo or fake balance amounts

### Requirement 2

**User Story:** As a new user, I want to see an empty transaction history with a helpful message, so that I know I haven't made any transactions yet.

#### Acceptance Criteria

1. WHEN a user has no transaction history THEN the System SHALL display an empty state UI with a friendly message
2. WHEN displaying the empty state THEN the System SHALL show a call-to-action button to make the first transaction
3. WHEN the System loads transactions THEN the System SHALL only display real transactions from the backend API
4. IF the transaction list is empty THEN the System SHALL NOT display any demo or sample transactions

### Requirement 3

**User Story:** As a user, I want the wallet screen to show my real balances, so that I can trust the information displayed.

#### Acceptance Criteria

1. WHEN the wallet screen loads THEN the System SHALL display the user's actual BDT balance from the backend
2. WHEN the wallet screen loads THEN the System SHALL display the user's actual INR balance from the backend
3. WHEN the user is not authenticated THEN the System SHALL prompt for login before showing balance information
4. IF the balance fetch fails THEN the System SHALL display an error state with retry option

### Requirement 4

**User Story:** As a user, I want the home screen balance cards to reflect my real account status, so that I have accurate information at a glance.

#### Acceptance Criteria

1. WHEN the home screen loads THEN the System SHALL display the authenticated user's actual BDT balance
2. WHEN the home screen loads THEN the System SHALL calculate and display the INR equivalent using the live exchange rate
3. WHEN the user is not logged in THEN the System SHALL display a login prompt instead of fake balances
4. IF balance data is loading THEN the System SHALL display a loading indicator instead of placeholder values

### Requirement 5

**User Story:** As a developer, I want all demo/hardcoded data removed from the codebase, so that the app only shows real user data.

#### Acceptance Criteria

1. WHEN reviewing the codebase THEN the System SHALL NOT contain hardcoded demo balance values
2. WHEN reviewing the codebase THEN the System SHALL NOT contain hardcoded sample transaction data
3. WHEN the app initializes THEN the System SHALL fetch all user data from the backend or local storage
4. IF demo data exists for development purposes THEN the System SHALL only enable it via a debug flag that is disabled in production

### Requirement 6

**User Story:** As a user, I want to see a professional empty state when I have no pending requests, so that the app feels polished and trustworthy.

#### Acceptance Criteria

1. WHEN there are no pending withdrawal requests THEN the System SHALL display an empty state with appropriate messaging
2. WHEN there are no pending deposit requests THEN the System SHALL display an empty state with appropriate messaging
3. WHEN there are no pending exchange requests THEN the System SHALL display an empty state with appropriate messaging
4. WHEN displaying empty states THEN the System SHALL use consistent styling across all screens
