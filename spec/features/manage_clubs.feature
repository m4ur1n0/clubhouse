Feature: Manage clubs through backend endpoints
  In order to ensure our core club flows stay stable
  Backend requests should keep honoring the ownership and membership rules

  Background:
    Given a signed in user "Alice"

  Scenario: Creating a club enrolls the owner as a member
    When they submit a POST to create a club named "Robotics" with description "Building bots"
    Then the club "Robotics" exists for "Alice"
    And "Alice" is recorded as a member of "Robotics"

  Scenario: Owners can update their club description
    Given an existing club "Outdoors" owned by "Alice"
    When they submit a PATCH to update club "Outdoors" with description "Weekend hikes"
    Then the club "Outdoors" has description "Weekend hikes"
