import std/[os, strutils, parseopt, re]

proc toCamelCase*(s: string): string =
    var capitalizeNext = false
    result = ""
    for c in s:
        if c == '_':
            capitalizeNext = true
        elif capitalizeNext:
            result.add(toUpperAscii(c))
            capitalizeNext = false
        else:
            result.add(c)

proc toSnakeCase*(s: string): string =
    result = ""
    for i, c in s:
        if i > 0 and c in {'A'..'Z'}:
            result.add('_')
            result.add(toLowerAscii(c))
        else:
            result.add(c)

proc convertIdentifiers*(content: string, toCamel: bool): string =
    let stringPattern = re"'[^']*'"
    var
        lastPos = 0
        currentPos = 0
    while currentPos < content.len:
        let bounds = findBounds(content, stringPattern, currentPos)

        if bounds.first >= 0:
            let textBefore = content[lastPos ..< bounds.first]
            if toCamel:
                result.add(toCamelCase(textBefore))
            else:
                result.add(toSnakeCase(textBefore))

            result.add(content[bounds.first .. bounds.last])
            lastPos = bounds.last + 1
            currentPos = bounds.last + 1
        else:
            break

    if lastPos < content.len:
        let remainingText = content[lastPos .. ^1]
        if toCamel:
            result.add(toCamelCase(remainingText))
        else:
            result.add(toSnakeCase(remainingText))

    return result

proc showUsage() = echo "usage: shark -c|-s filename [filename2 ...]"

proc processFile*(filename: string, toCamel: bool) =
    if not fileExists(filename):
        echo "Error: File not found: ", filename
        return
    let
        content = readFile(filename)
        converted = convertIdentifiers(content, toCamel)
    writeFile(filename, converted)
    echo "Processed file: ", filename


when isMainModule:
    var
        toCamel = false
        toSnake = false
        files: seq[string] = @[]

    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            files.add(key)
        of cmdLongOption, cmdShortOption:
            case key
            of "c": toCamel = true
            of "s": toSnake = true
        of cmdEnd: discard

    if toCamel and toSnake:
        echo "Cannot specify both -c and -s options"
        quit(1)
    elif not toCamel and not toSnake:
        echo "Must specify either -c (to camelCase) or -s (to snake_case)"
        showUsage()
        quit(1)
    if files.len == 0:
        echo "No input files specified"
        showUsage()
        quit(1)
    for file in files:
        processFile(file, toCamel)
