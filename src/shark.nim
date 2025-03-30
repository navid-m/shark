import std/[os, strutils, parseopt]

proc toCamelCase*(s: string): string =
    let allCaps = s.len > 0 and s.toUpperAscii() == s and s.contains('_')
    if allCaps or (s.len > 0 and s[0] in {'A'..'Z'}): return s

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
    if allCaps: return s

    result = ""
    for i, c in s:
        if i > 0 and c in {'A'..'Z'}:
            result.add('_')
            result.add(toLowerAscii(c))
        else:
            result.add(toLowerAscii(c))

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
            if toCamel:
                if word[0] in {'A'..'Z'} and word.contains({'a'..'z'}):
                    result.add(word)
                else:
                    result.add(toCamelCase(word))
            else:
                if word[0] in {'A'..'Z'} and word.contains({'a'..'z'}):
                    result.add(word)
                else:
                    result.add(toSnakeCase(word))

    return result

proc convertIdentifiers*(content: string, toCamel: bool): string =
    var i = 0
    var insideSingleQuote = false
    var insideDoubleQuote = false
    var insideTripleSingleQuote = false
    var insideTripleDoubleQuote = false
    result = ""

    while i < content.len:
        if i <= content.len - 3 and content[i..i+2] == "'''" and
                not insideDoubleQuote:
            insideTripleSingleQuote = not insideTripleSingleQuote
            result.add("'''")
            i += 3
        elif i <= content.len - 3 and content[i..i+2] == "\"\"\"" and
                not insideSingleQuote:
            insideTripleDoubleQuote = not insideTripleDoubleQuote
            result.add("\"\"\"")
            i += 3
        elif content[i] == '\'' and not insideDoubleQuote and
                not insideTripleSingleQuote:
            insideSingleQuote = not insideSingleQuote
            result.add(content[i])
            i += 1
        elif content[i] == '\"' and not insideSingleQuote and
                not insideTripleDoubleQuote:
            insideDoubleQuote = not insideDoubleQuote
            result.add(content[i])
            i += 1
        elif insideSingleQuote or insideDoubleQuote or
                insideTripleSingleQuote or insideTripleDoubleQuote:
            result.add(content[i])
            i += 1
        else:
            var start = i
            while i < content.len and content[i] notin {'\'', '\"', '\0'}:
                i += 1
            result.add(processTextSegment(content[start..<i], toCamel))

    return result

proc processFile*(filename: string, toCamel: bool) =
    if not fileExists(filename):
        echo "Error: File not found: ", filename
        return

    let content = readFile(filename)
    let converted = convertIdentifiers(content, toCamel)
    writeFile(filename, converted)

when isMainModule:
    var toCamel = false
    var toSnake = false
    var files: seq[string] = @[]

    for kind, key, val in getopt():
        case kind
        of cmdArgument: files.add(key)
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
        quit(1)

    if files.len == 0:
        echo "No input files specified"
        quit(1)

    for file in files:
        processFile(file, toCamel)
