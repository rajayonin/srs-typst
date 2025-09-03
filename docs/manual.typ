#import "@preview/tidy:0.4.3"

= The SRS package: Reference documentation


#tidy.show-module(
  tidy.parse-module(
    (
      ..for file in ("config", "items", "show", "utils") {
        (read("/src/" + file + ".typ"),)
      },
    ).join("\n"),
    name: "srs",
    // we use the old (0.3) syntax bc Tynimist does not support the new one
    // when it's supported, we'll have to migrate, as the new parser supports
    // argument sinks (variadic functions) documentation
    old-syntax: true,
  ),
  omit-private-definitions: true,
)

// defaults
#tidy.show-module(
  tidy.parse-module(
    (
      ..for file in ("classes", "formatters") {
        (read("/src/defaults/" + file + ".typ"),)
      },
    ).join("\n"),
    name: "srs.defaults",
    old-syntax: true,
  ),
)
