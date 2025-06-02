#import "@preview/tidy:0.4.3"



#for module in ("config", "defaults", "items") {
  tidy.show-module(
    tidy.parse-module(
      read("/src/" + module + ".typ"),
      name: module,
      // we use the old (0.3) syntax bc Tynimist does not support the new one
      // when it's supported, we'll have to migrate, as the new parser supports
      // argument sinks (variadic functions) documentation
      old-syntax: true,
    ),
    omit-private-definitions: true,
  )
}
