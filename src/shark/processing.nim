import std/os
import text

proc process_file*(filename: string, to_camel: bool) =
    if not file_exists(filename):
        echo "File not found: ", filename
        return

    let
        content = read_file(filename)
        converted = convert_identifiers(content, to_camel)

    write_file(filename, converted)
