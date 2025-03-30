import std/[os, strutils, parseopt, re, sequtils]

proc toCamelCase*(s: string): string =
    let
        allCaps = s.len > 0 and s.toUpperAscii() == s and s.contains('_')
        isPascalCase = s.len > 0 and s[0] in {'A'..'Z'}

    if isPascalCase or allCaps:
        return s

    var capitalizeNext = false
    result = ""
    if s.len > 0 and s[0] == '_':
        capitalizeNext = true

    for c in s:
        if c == '_':
            capitalizeNext = true
        elif capitalizeNext:
            result.add(toUpperAscii(c))
            capitalizeNext = false
        else:
            result.add(c)

proc toSnakeCase*(s: string): string =
    let allCaps = s.len > 0 and s.toUpperAscii() == s
    if allCaps:
        return s
    let isPascalCase = s.len > 0 and s[0] in {'A'..'Z'}

    result = ""
    for i, c in s:
        if i > 0 and c in {'A'..'Z'}:
            result.add('_')
            result.add(toLowerAscii(c))
        else:
            if i == 0 and isPascalCase:
                result.add(toLowerAscii(c))
            else:
                result.add(c)

proc processTextSegment(text: string, toCamel: bool): string =
    var i = 0

    while i < text.len:
        var wsStart = i
        while i < text.len and text[i] in Whitespace:
            i.inc

        if i > wsStart:
            result.add(text[wsStart..<i])

        var wordStart = i
        while i < text.len and text[i] notin Whitespace:
            i.inc

        if i > wordStart:
            let word = text[wordStart..<i]
            if word.len > 0:
                if toCamel:
                    if word.len > 0 and word[0] in {'A'..'Z'} and word.contains({'a'..'z'}):
                        result.add(word)
                    else:
                        result.add(toCamelCase(word))
                else:
                    if word.len > 0 and word[0] in {'A'..'Z'} and word.contains(
                            {'a'..'z'}) and
                       not word[0..^1].allIt(it in {'A'..'Z'}):
                        result.add(word)
                    else:
                        result.add(toSnakeCase(word))

    return result

proc convertIdentifiers*(content: string, toCamel: bool): string =
    let stringPattern = re"'[^']*'"
    var
        lastPos = 0
        currentPos = 0

    result = ""
    while currentPos < content.len:
        let bounds = findBounds(content, stringPattern, currentPos)
        if bounds.first >= 0:
            let textBefore = content[lastPos ..< bounds.first]
            result.add(processTextSegment(textBefore, toCamel))
            result.add(content[bounds.first .. bounds.last])
            lastPos = bounds.last + 1
            currentPos = bounds.last + 1
        else:
            break

    if lastPos < content.len:
        let remainingText = content[lastPos .. ^1]
        result.add(processTextSegment(remainingText, toCamel))

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
