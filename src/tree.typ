#import "defaults.typ": default-config
#import "config.typ": validate-config



#let _create-tree-from-config(config, tree: (:)) = {
  for subclass in config.classes {
    let in-tree = _create-tree-from-config(subclass)
    tree.insert(subclass.id, in-tree)
  }

  return tree
}


#let create(
  config: default-config,
  ..requirements
) = {
  assert(validate-config(config), message: "Invalid configuration")

  let tree = _create-tree-from-config(config)

  // TODO: add requirements

  // TODO: origins

  return (
    tree: tree,
    config: config,
  )
}