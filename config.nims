# nimib compiles each page's browser code with `nim js` from the repo root (a
# js_file_nbCodeToJs_*.nim file there), so the dependency paths are needed here too.
import std/os
let deps = getEnv("PARLOKU_DEPS", thisDir() / "src" / "deps")
for d in ["nimib", "fusion", "markdown", "parsetoml", "jsony", "zogyn"]:
  switch("path", deps / d / "src")
switch("path", thisDir() / "src")   # src/solver.nim, for the builder's browser code
switch("hints", "off")
