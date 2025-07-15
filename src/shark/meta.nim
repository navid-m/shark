proc show_usage*() = echo "Usage: shark [-c|-s|-t|-f] fname [fname_2 ...]\n(t = 2 space | f = 4 space)"
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
Shark v1.0.0
Navid M
https://github.com/navid-m"""
    quit(0)
