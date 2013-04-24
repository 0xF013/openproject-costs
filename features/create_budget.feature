Feature: Creating a Budget

  Scenario: Budgets can be created
    Given there is 1 User with:
      | Login | testuser |
    And there is 1 Project with the following:
      | name       | project1 |
      | identifier | project1 |
    And there is a role "manager"
    And the role "manager" may have the following rights:
      | edit_cost_objects |
    And the user "testuser" is a "manager" in the project "project1"
    And I am already logged in as "testuser"

    When I go to the overview page of the project called "project1"
    And I follow "Budgets" within "#main-menu"
    And I follow "New Budget" within "#main-menu"
    And I fill in "cost_object_subject" with "budget1"
    And I press "Create"

    Then I should be on the show page for the budget "budget1"
    And I should see "Successful creation"
    And I should see "budget1" within ".cost_object"
