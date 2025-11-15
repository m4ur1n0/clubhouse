Feature: Manage club chat messages in the backend
  Chat endpoints should only allow members to post and edits should be marked accordingly

  Background:
    Given a signed in user "Elena"
    And an existing club "Book Club" owned by "Elena"
    And the user "Elena" belongs to the club "Book Club"

  Scenario: Posting a chat message
    When they post a chat message "Welcome to book club" in "Book Club"
    Then a chat message exists in "Book Club" with content "Welcome to book club"

  Scenario: Editing a chat message stamps the edit time
    Given an existing chat message "Original note" in "Book Club"
    When they update the chat message to "Updated note"
    Then the message content is "Updated note"
    And the message was flagged as edited
