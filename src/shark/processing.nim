import std/os
import text

proc process_file*(filename: string, to_camel: bool) =
    ## Convert some text-based file to camel or snake case.
    if not file_exists(filename):
        echo "File not found: ", filename
        return

    let converted = convert_identifiers(read_file(filename), to_camel)
    write_file(filename, converted)
