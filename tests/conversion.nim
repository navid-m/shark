import std/[unittest, os, tempfiles]
import shark

suite "Case Converter Tests":
    test "toCamelCase basic conversion":
        check toCamelCase("snake_case_variable") == "snakeCaseVariable"
        check toCamelCase("another_example") == "anotherExample"
        check toCamelCase("single") == "single"

    test "toCamelCase edge cases":
        check toCamelCase("") == ""
        check toCamelCase("_leading_underscore") ==
                "LeadingUnderscore" #Check failed: toSnakeCase("LeadingCapital") == "leading_capital" toSnakeCase("LeadingCapital") was Leading_capital
        check toCamelCase("trailing_underscore_") == "trailingUnderscore"
        check toCamelCase("multiple___underscores") == "multipleUnderscores"

    test "toSnakeCase basic conversion":
        check toSnakeCase("camelCaseVariable") == "camel_case_variable"
        check toSnakeCase("anotherExample") == "another_example"
        check toSnakeCase("single") == "single"

    test "toSnakeCase edge cases":
        check toSnakeCase("") == ""
        check toSnakeCase("LeadingCapital") == "leading_capital"
        check toSnakeCase("ALLCAPS") == "ALLCAPS" #All capitals should be unchanged, currently toSnakeCase("ALLCAPS") is A_l_l_c_a_p_s

    test "convertIdentifiers ignores string literals for camelCase":
        let input = "some_var = 'string_with_underscores'"
        let expected = "someVar = 'string_with_underscores'"
        check convertIdentifiers(input, true) == expected

    test "convertIdentifiers ignores string literals for snakeCase":
        let input = "someVar = 'stringWithCamelCase'"
        let expected = "some_var = 'stringWithCamelCase'"
        check convertIdentifiers(input, false) == expected

    test "convertIdentifiers with multiple strings":
        let input = "snake_case = 'literal1' + camelCase + 'literal2'"
        let expected_to_camel = "snakeCase = 'literal1' + camelCase + 'literal2'"
        let expected_to_snake = "snake_case = 'literal1' + camel_case + 'literal2'"
        check convertIdentifiers(input, true) == expected_to_camel
        check convertIdentifiers(input, false) == expected_to_snake

    test "convertIdentifiers with empty strings":
        let input = "empty_string = ''"
        let expected_to_camel = "emptyString = ''"
        check convertIdentifiers(input, true) == expected_to_camel

    test "processFile integration test":
        let tempDir = createTempDir("cconv", "test")
        let testFilePath = tempDir / "test_file.txt"
        writeFile(testFilePath, "testFunction(someVar, anotherVar) // 'ignoreThisString'")
        processFile(testFilePath, false)
        check readFile(testFilePath) == "test_function(some_var, another_var) // 'ignoreThisString'"
        writeFile(testFilePath, "test_function(some_var, another_var) // 'ignore_this_string'")
        processFile(testFilePath, true)
        check readFile(testFilePath) == "testFunction(someVar, anotherVar) // 'ignore_this_string'"
        removeDir(tempDir)

    test "mixed case conversions":
        let mixed = "snake_case mixedWith camelCase and PascalCase"
        let to_camel = "snakeCase mixedWith camelCase and PascalCase"
        let to_snake = "snake_case mixed_with camel_case and PascalCase"
        check convertIdentifiers(mixed, true) == to_camel
        check convertIdentifiers(mixed, false) == to_snake

    test "adjacent string literals":
        let input = "var1 = 'string1''string2' + snake_case"
        let expected = "var1 = 'string1''string2' + snakeCase"
        check convertIdentifiers(input, true) == expected
