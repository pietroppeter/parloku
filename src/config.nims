# Dependencies from deps.sh (PARLOKU_DEPS, default ./deps).
import std/os
let deps = getEnv("PARLOKU_DEPS", thisDir() / "deps")
for d in ["nimib", "fusion", "markdown", "parsetoml", "jsony", "puzzlepaw"]:
  switch("path", deps / d / "src")
switch("hints", "off")
