import std/[strutils, sequtils, re]

proc to_camel_case*(s: string): string =
    ## Converts some input string, this can be source code, to camel case.
    let
        all_caps = s.len > 0 and s.to_upper_ascii() == s and s.contains('_')
        is_pascal_case = s.len > 0 and s[0] in {'A'..'Z'}

    if is_pascal_case or all_caps:
        return s

    var capitalize_next = false
    if s.len > 0 and s[0] == '_':
        capitalize_next = true

    for c in s:
        if c == '_':
            capitalize_next = true
        elif capitalize_next:
            result.add(to_upper_ascii(c))
            capitalize_next = false
        else:
            result.add(c)

proc to_snake_case*(s: string): string =
    ## Converts some input string, that may be source code, to snake case.
    if s.len > 0 and s.to_upper_ascii() == s:
        return s
    let is_pascal_case = s.len > 0 and s[0] in {'A'..'Z'}
    for i, c in s:
        if i > 0 and c in {'A'..'Z'}:
            result.add('_')
            result.add(to_lower_ascii(c))
        else:
            if i == 0 and is_pascal_case:
                result.add(to_lower_ascii(c))
            else:
                result.add(c)

proc process_text_segment(text: string, to_camel: bool): string =
    ## Internal logic for processing text sections.
    var i = 0

    while i < text.len:
        var ws_start = i
        while i < text.len and text[i] in Whitespace:
            i.inc

        if i > ws_start:
            result.add(text[ws_start..<i])

        var word_start = i
        while i < text.len and text[i] notin Whitespace:
            i.inc

        if i > word_start:
            let word = text[word_start..<i]
            if word.len > 0:
                if to_camel:
                    if word.len > 0 and word[0] in {'A'..'Z'} and word.contains({'a'..'z'}):
                        result.add(word)
                    else:
                        result.add(to_camel_case(word))
                else:
                    if word.len > 0 and word[0] in {'A'..'Z'} and word.contains(
                            {'a'..'z'}) and
                       not word[0..^1].all_it(it in {'A'..'Z'}):
                        result.add(word)
                    else:
                        result.add(to_snake_case(word))
    return result

proc convert_identifiers*(content: string, to_camel: bool): string =
    ## Convert the identifiers in the content.
    ##
    ## Either to camel or snake case.
    let string_pattern = re"'[^']*'"
    var
        last_pos = 0
        current_pos = 0

    result = ""
    while current_pos < content.len:
        let bounds = find_bounds(
            content,
            string_pattern,
            current_pos
        )
        if bounds.first >= 0:
            let text_before = content[last_pos ..< bounds.first]
            result.add(process_text_segment(text_before, to_camel))
            result.add(content[bounds.first .. bounds.last])
            last_pos = bounds.last + 1
            current_pos = bounds.last + 1
        else:
            break

    if last_pos < content.len:
        let remaining_text = content[last_pos .. ^1]
        result.add(process_text_segment(remaining_text, to_camel))

    return result
