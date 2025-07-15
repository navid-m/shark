import std/parseopt
import shark/[meta, processing, text, indentation]

export to_camel_case
export to_snake_case
export process_file

when is_main_module:
    var
        to_camel = false
        to_snake = false
        to_four = false
        to_two = false
        files: seq[string] = @[]

    for kind, key, val in getopt():
        case kind
        of cmd_argument:
            files.add(key)
        of cmd_long_option, cmd_short_option:
            case key
            of "c": to_camel = true
            of "s": to_snake = true
            of "f": to_four = true
            of "t":
                if to_four == true:
                    echo "You cannot specify both four space and two space indentation."
                    quit(1)
                to_two = true
            of "about": meta.show_about()
        of cmd_end: discard

    if to_four:
        for file in files:
            toggleIndentation(file, file, false)
    elif to_two:
        for file in files:
            toggleIndentation(file, file, true)

    if to_camel and to_snake:
        echo "You cannot specify both -c and -s options."
        quit(1)
    elif not to_camel and not to_snake:
        echo "No other options were specified (-c (camel case) or -s (snake case))."
        quit(0)

    if files.len == 0:
        echo "Specify an input file."
        show_usage()
        quit(1)

    for file in files:
        process_file(file, to_camel)
