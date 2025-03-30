# Package

version       = "1.0.0"
author        = "Navid M"
description   = "Convert nim source files from snake to camel case and vice versa"
license       = "GPL-3.0-only"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["shark"]


# Dependencies

requires "nim >= 2.2.2"
