# nimib compiles each page's browser code with `nim js` from the repo root (a
# js_file_nbCodeToJs_*.nim file there), so the dependency paths are needed here too.
import std/os
let deps = getEnv("PARLOKU_DEPS", thisDir() / "src" / "deps")
for d in ["nimib", "fusion", "markdown", "parsetoml", "jsony", "puzzlepaw"]:
  switch("path", deps / d / "src")
switch("hints", "off")
