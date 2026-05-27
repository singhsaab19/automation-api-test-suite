@inventory
Feature: Inventory Management API Tests

  Background:
    * url baseUrl
    * def DataGenerator = Java.type('utils.DataGenerator')

  @smoke @get-all
  Scenario: Get all menu items
    Given path 'inventory'
    When method GET
    Then status 200
    And assert response.data.length >= 9
    # Read schema from the centralized resources directory
    * def itemSchema = read('classpath:testData/inventory/inventory-schema.json')
    And match each response.data == itemSchema

  @smoke @filter
  Scenario Outline: Filter by id
    Given path 'inventory/filter'
    And param id = <id>
    When method GET
    Then status <expected_status_code>
    # Read expected data from resources
    * def expectedItem = read('classpath:testData/inventory/'+filename)
    And match response == expectedItem
    Examples:
    | expected_status_code | id |filename             |
    | 200                  | 3  |expected-item-3.json |

  @negative @filter-not-found
  Scenario Outline: Filter by id - Not Found
    Given path 'inventory/filter'
    And param id = <id>
    When method GET
    Then status 404
    # Assert against the expected error message directly from the table
    And match response == <expected_error>

    Examples:
          |id  | expected_error     |
          |0   | 'Not Found'        |
          |999 | 'Not Found'        |
          |'abc'| 'Not Found'        |


@smoke @add-item
  Scenario: Add item for non-existent id
    # Read payload from resources and inject dynamic ID
    * def newItemPayload = read('classpath:testData/inventory/new-item-payload.json')
    * set newItemPayload.id = DataGenerator.getRandomFourDigitId()

    Given path 'inventory/add'
    And request newItemPayload
    When method POST
    Then status 200

  @negative @add-duplicate
  Scenario: Add item for existent id
    # Reuse the existing item JSON for duplicate check
    * def duplicatePayload = read('classpath:testData/inventory/expected-item-3.json')

    Given path 'inventory/add'
    And request duplicatePayload
    When method POST
    Then status 400

  @negative @missing-info
  Scenario Outline: Try to add item with missing information - <missingField>
    # Load the valid, complete payload from resources
    * def payload = read('classpath:testData/inventory/new-item-payload.json')

    # Dynamically delete the field specified in the Examples table
    * karate.remove('payload', '$.' + missingField)
    * print 'Testing with payload missing field:', missingField, 'Payload:', payload
    Given path 'inventory/add'
    And request payload
    When method POST
    Then status 400
    And match response == 'Not all requirements are met'
    # The test will run 4 times, looping through this table and dropping one field per run
    Examples:
      | missingField |
      | id           |
      | name         |
      | price        |
      | image        |


  @e2e @verify-retrieval
  Scenario: Validate recent added item is present in the inventory
    * def uniqueId = DataGenerator.getRandomFourDigitId()
    * def newItemPayload = read('classpath:testData/inventory/new-item-payload.json')
    * set newItemPayload.id = uniqueId

    # Precondition: Add the item
    Given path 'inventory/add'
    And request newItemPayload
    When method POST
    Then status 200

    # Test: Fetch via filter and EXACT MATCH against our injected payload
    Given path 'inventory/filter'
    And param id = uniqueId
    When method GET
    Then status 200
    And match response == newItemPayload