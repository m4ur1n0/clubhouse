Feature: Manage club memberships from the backend
  Members must be able to join or leave via the controllers while respecting the rules

  Background:
    Given a signed in user "Jordan"
    And an existing club "Writers" owned by "Jordan"

  Scenario: Member joins a club they do not own
    Given another club "Gamers" owned by "Alex"
    When "Jordan" joins the club "Gamers"
    Then "Jordan" is recorded as a member of "Gamers"

  Scenario: Member leaves a club
    Given the user "Jordan" belongs to the club "Writers"
    When "Jordan" leaves the club "Writers"
    Then "Jordan" is no longer a member of "Writers"
