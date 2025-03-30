import std/parseopt
import shark/[meta, processing, text]

export to_camel_case
export to_snake_case

when is_main_module:
    var
        to_camel = false
        to_snake = false
        files: seq[string] = @[]

    for kind, key, val in getopt():
        case kind
        of cmd_argument:
            files.add(key)
        of cmd_long_option, cmd_short_option:
            case key
            of "c": to_camel = true
            of "s": to_snake = true
        of cmd_end: discard

    if to_camel and to_snake:
        echo "Cannot specify both -c and -s options"
        quit(1)
    elif not to_camel and not to_snake:
        echo "Must specify either -c (to camelCase) or -s (to snake_case)"
        show_usage()
        quit(1)

    if files.len == 0:
        echo "No input files specified"
        show_usage()
        quit(1)

    for file in files:
        process_file(file, to_camel)
