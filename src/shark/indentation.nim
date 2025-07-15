import std/[os, strutils]

proc showIndentHelp() =
    echo "Options:"
    echo "  -r, --reverse  Convert 4-space indentation to 2-space (default: 2-space to 4-space)"

proc getIndentLevel(line: string): int =
    ## Get the indentation level of a line (counting leading spaces)
    result = 0
    for c in line:
        if c == ' ':
            inc result
        else:
            break

proc convertIndentation(content: string, reverse: bool): string =
    ## Convert indentation between 2-space and 4-space
    let lines = content.splitLines()
    var resultLines: seq[string] = @[]

    for line in lines:
        if line.strip().len == 0:
            resultLines.add("")
            continue

        let indentLevel = getIndentLevel(line)
        let contentPart = line[indentLevel..^1]

        let newIndentLevel =
            if reverse:
                if indentLevel mod 4 == 0:
                    (indentLevel div 4) * 2
                else:
                    stderr.writeLine("Warning: Mixed indentation detected at line: " & line)
                    indentLevel
            else:
                if indentLevel mod 2 == 0:
                    (indentLevel div 2) * 4
                else:
                    stderr.writeLine("Warning: Odd indentation detected at line: " & line)
                    indentLevel

        resultLines.add(repeat(' ', newIndentLevel) & contentPart)

    return resultLines.join("\n")

proc toggleIndentation*(inputFile: string, outputFile: string, reverse: bool) =
    let inplace = true

    if inputFile == "":
        echo "Error: Input file required"
        showIndentHelp()
        quit(1)

    if not fileExists(inputFile):
        echo "Error: Input file '" & inputFile & "' does not exist"
        quit(1)

    if inplace and outputFile != "":
        echo "Error: Cannot specify both --inplace and output file"
        quit(1)

    try:
        let content = readFile(inputFile)
        let convertedContent = convertIndentation(content, reverse)

        if inplace:
            writeFile(inputFile, convertedContent)
            echo "File '" & inputFile & "' updated in place"
        elif outputFile != "":
            writeFile(outputFile, convertedContent)
            echo "Converted file written to '" & outputFile & "'"
        else:
            echo convertedContent

    except IOError as e:
        echo "Error: " & e.msg
        quit(1)

