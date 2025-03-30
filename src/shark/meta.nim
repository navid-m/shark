proc show_usage*() = echo "usage: shark -c|-s fname [fname_2 ...]"
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
