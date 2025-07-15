import std/[os, strutils]

proc get_indent_level(line: string): int =
    ## Get the indentation level of a line (counting leading spaces)
    result = 0
    for c in line:
        if c == ' ':
            inc result
        else:
            break

proc convert_indentation(content: string, reverse: bool): string =
    ## Convert indentation between 2-space and 4-space
    let lines = content.split_lines()
    var result_lines: seq[string] = @[]

    for line in lines:
        if line.strip().len == 0:
            result_lines.add("")
            continue

        let indent_level = get_indent_level(line)
        let content_part = line[indent_level..^1]

        let new_indent_level =
            if reverse:
                if indent_level mod 4 == 0:
                    (indent_level div 4) * 2
                else:
                    stderr.write_line("Warning: Mixed indentation detected at line: " & line)
                    indent_level
            else:
                if indent_level mod 2 == 0:
                    (indent_level div 2) * 4
                else:
                    stderr.write_line("Warning: Odd indentation detected at line: " & line)
                    indent_level

        result_lines.add(repeat(' ', new_indent_level) & content_part)

    return result_lines.join("\n")

proc toggle_indentation*(input_file: string, reverse: bool) =
    let inplace = true

    if input_file == "":
        echo "Error: Input file required"
        quit(1)

    if not file_exists(input_file):
        echo "Error: Input file '" & input_file & "' does not exist"
        quit(1)

    try:
        let content = read_file(input_file)
        let converted_content = convert_indentation(content, reverse)

        if inplace:
            write_file(input_file, converted_content)
            echo "File '" & input_file & "' updated in place"

        else:
            echo converted_content

    except IOError as e:
        echo "Error: " & e.msg
        quit(1)

