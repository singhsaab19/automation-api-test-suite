@inventory
Feature: Inventory Management API Tests

  Background:
    * url baseUrl
    # Bonus: Generating a dynamic UUID ensures tests can run multiple times without data collisions or manual cleanup.
    * def uniqueId = java.util.UUID.randomUUID().toString()
    * def newItemPayload = { id: '#(uniqueId)', name: 'Hawaiian', image: 'hawaiian.png', price: '$14' }

  @smoke @get-all
  Scenario: Get all menu items and validate schema
    Given path 'inventory'
    When method GET
    Then status 200
    * karate.log('Full inventory response:', response)
    # Validate response contains at least 9 items
    And assert response.data.length >= 9
    # Validate schema using Karate fuzzy matchers (checks presence and type)
    And match each response.data contains { id: '#notnull', name: '#string', price: '#string', image: '#string' }

  @smoke @filter
  Scenario: Filter inventory by exact ID
    Given path 'inventory/filter'
    And param id = 3
    When method GET
    Then status 200
    # verify the response contains exactly one item with the expected fields and values
    And match response contains { id: "3", name: 'Baked Rolls x 8', price: '#notnull', image: '#notnull' }

  @e2e @item-lifecycle
  Scenario: Item lifecycle - Add, duplicate check, and retrieval
    # Step 1: Add item for non-existent id
    Given path 'inventory/add'
    And request newItemPayload
    When method POST
    Then status 200

    # Step 2: Add item for existent id (using the exact same payload)
    Given path 'inventory/add'
    And request newItemPayload
    When method POST
    Then status 400

    # Step 3: Validate recently added item is present in the inventory
    Given path 'inventory'
    When method GET
    Then status 200
    # Use JSONPath to find the specific item we injected to verify it exists
    * def addedItem = karate.jsonPath(response, "$.data[?(@.id == '" + uniqueId + "')]")
    And match addedItem[0] contains newItemPayload

  @negative @validation
  Scenario: Try to add item with missing information
    Given path 'inventory/add'
    # Sending payload without an 'id'
    And request { name: 'Hawaiian', image: 'hawaiian.png', price: '$14' }
    When method POST
    Then status 400
    # Match string anywhere in the response if the exact JSON error structure is unknown
    And match response contains 'Not all requirements are met'