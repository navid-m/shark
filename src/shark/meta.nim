proc show_usage*() = echo "usage: shark -c|-s filename [filename2 ...]"
proc show_about*() =
    echo """
                ,
            .';
        .-'` .'
    ,`.-'-.`\
    ; /     '-'
    | \       ,-,
    \  '-.__   )_`'._
    '.     ```      ``'--._
    .-' ,                   `'-.
    '-'`-._           ((   o   )
            `'--....(`- ,__..--'
                    '-'`
shark v1.0.0
navid m
https://github.com/navid-m"""
    quit(0)
