Feature: Manage events through backend endpoints
  Club organizers rely on the API to create and validate events, including recurring ones

  Background:
    Given a signed in user "Maya"
    And an existing club "Chess Club" owned by "Maya"
    And the user "Maya" belongs to the club "Chess Club"

  Scenario: Creating an event records the creator as attending
    When they create an event named "Weekly Practice" scheduled for "2025-02-10 18:00" at "Library"
    Then the event "Weekly Practice" exists for "Chess Club"
    And the event "Weekly Practice" lists "Maya" as attending

  Scenario: Recurring events create a weekly series
    When they create a recurring event named "Friday Meetup" scheduled for "2025-03-07 17:00" ending on "2025-03-21"
    Then 3 events exist for "Friday Meetup"
    And each "Friday Meetup" event is owned by "Maya"

  Scenario: Invalid recurring range is rejected
    When they attempt to create a recurring event named "Bad Range" scheduled for "2025-04-01 12:00" ending on "2025-03-01"
    Then the request is rejected
