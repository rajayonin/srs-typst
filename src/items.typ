//! Functions for creating and managing items

#import "defaults.typ": default-config
#import "config.typ": validate-config


/// Creates an item belonging to the specified class. The specified fields are
/// the ones belonging to the class.
///
/// *Example:*
/// ```
/// make-item(
///   "cool-req",
///   ("R", "S", "NF"),
///   origins: (("R", "U", "RE", "user-req")),
///   Description: [ The software shall be cool. ],
///   Necessity: "h",
///   Priority: "h",
///   Stability: "c",
///   Verifiability: "l"
/// )
/// ```
///
/// - id (str): Item ID. This must be unique inside the class.
/// - class (array): Item class, expressed as the class hierarchy
/// - origins (array): Array of tags of items that give origin to this one.
/// -> dictionary
#let make-item(id, class, origins: (), ..fields) = (
  id: id,
  class: class,
  origins: origins,
  fields: fields.named(),
)



/// Validates an item's fields are valid.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - item_fields (dictionary): Fields to be validated.
/// - class_fields (dictionary): Item class's fields to validate against.
/// -> array
#let _validate-fields(item_fields, class_fields) = {
  // check too much fields
  if item_fields.len() > class_fields.len() {
    return (false, "Too many fields.")
  }

  // check missing fields
  if item_fields.len() < class_fields.len() {
    return (
      false,
      "Missing fields ("
        + class_fields.filter(f => not item_fields.keys().contains(f.name)).map(f => f.name).join(", ")
        + ").",
    )
  }

  // check values
  for (key, value) in item_fields.pairs() {
    let field = class_fields.find(f => f.name == key)
    if field == none {
      return (false, "Invalid field '" + key + "'.")
    }

    if field.value == "content" and type(value) != content {
      return (false, "Field '" + field.name + "' is not of type `content`.")
    } else if type(field.value) == dictionary and not field.value.keys().contains(value) {
      return (
        false,
        "Invalid value for field '" + field.name + "'. Valid values are '" + field.value.keys().join("', '") + "'.",
      )
    }
  }

  return (true, none)
}


/// Validates an item's origins are valid.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - item_origins (array): Origins to be validated.
/// - class_origins (array): Item class's origins to validate against.
/// -> array
#let _validate-origins(item_origins, class_origins, tree) = {
  if item_origins.len() == 0 { return (true, none) }

  if class_origins.len() == 0 {
    return (false, "Item class does not allow origins.")
  }

  for (i, origin_tag) in item_origins.enumerate() {
    // type check
    if type(origin_tag) != array {
      return (
        false,
        "Origin " + str(i) + " is not an tag.",
      )
    }

    // check if it's a valid origin class
    for class_origin_tag in class_origins.tags {
      let item_origin_tag = origin_tag.slice(0, count: origin_tag.len() - 1)

      if not item_origin_tag == class_origin_tag {
        return (
          false,
          "Invalid origin. Class '"
            + origin_tag.slice(0, count: origin_tag.len() - 1).join("-")
            + "' is not a valid origin class (valid classes are '"
            + class_origins.tags.map(t => t.join("-")).join(", '")
            + "')",
        )
      }
    }

    // traverse the tree to see if that origin item exists
    let current = tree
    for class in origin_tag {
      current = current.at(class, default: none)
      if current == none {
        return (
          false,
          "Invalid origin. Item '" + origin_tag.join("-") + "' not found.",
        )
      }
    }
  }

  return (true, none)
}


/// Validates an item is well constructed.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - item (dictionary): Item to be validated.
/// - config (dictionary): Configuration object.
/// - tree (dictionary): Current item tree.
/// -> array
#let _validate-item(item, config, tree) = {
  // check format (duck typing)
  if (
    (type(item) != dictionary) or item.keys() != ("id", "class", "origins", "fields")
  ) {
    return (false, "Invalid format. Please make sure to use #make-item.")
  }

  if type(item.class) != array {
    return (false, "Invalid format. `class` is not an array.")
  }

  if type(item.origins) != array {
    return (false, "Invalid format. `origins` is not an array.")
  }

  // traverse config collecting the fields
  // we also validate the class is correct
  let class_fields = ()
  let current = config
  for (i, class_id) in item.class.enumerate() {
    current = current.classes.find(class => class.id == class_id)
    if current == none {
      return (
        false,
        "Invalid class. '" + class_id + "' is not a subclass of '" + item.class.at(i - 1) + "'.",
      )
    }
    class_fields += current.fields
  }

  // `current` is now the item's class

  // check it's terminal class
  if current.classes.len() != 0 {
    return (false, "'" + item.class.join("-") + "' is not a terminal class.")
  }

  // validate fields
  let (ok, err) = _validate-fields(item.fields, class_fields)
  if not ok {
    return (false, err)
  }

  // validate origins
  let (ok, err) = _validate-origins(item.origins, current.origins, tree)
  if not ok {
    return (false, err)
  }

  return (true, none)
}


/// Adds an item to the tree.
///
/// Returns the new tree.
///
/// - item (dictionary): Item to be added. Must be a valid item.
/// - tree (dictionary): Tree to insert the item in.
/// - overwrite (bool): If `true`, will overwrite an existing item with the same tag. If `false`, trying to insert a tag that exists will result in an error.
/// -> dictionary
#let _add-item(item, tree, overwrite: false) = {
  // traverse tree

  // We cannot traverse the tree with the "traditional" method, that is:
  // ```typst
  // let current = tree
  // for (i, class_id) in item.class.enumerate() {
  //     if i == item.class.len() - 1 {
  //       current.at(class_id).insert(...)
  //       break
  //     }
  //     current = current.at(class_id)
  // }
  // return tree
  // ```
  //
  // This is because when we assign a dict to a new variable, we are making a
  // (deep) copy, not a reference, so when we modify `current`, we're not
  // modifying `tree`.
  //
  // But Typst has a wacko rule: if we do `my_dict.at(key) = something`,
  // we're updating the value of the dictionary.
  //
  // So we can do one thing, traverse the tree, collecting the nodes we go
  // through in a stack (because remember, these will be copies!), and after
  // inserting, we rebuild the tree from the new inserted node up (following the
  // stack), by reasigning the nodes.
  // You can see it as:
  // ```typst
  // tree.at(k0).at(k1).at(...).at(kn-1) = current
  // tree.at(k0).at(k1).at(...).at(kn-2) = tree.at(k0).at(...).at(kn-1)
  // ...
  // tree.at(k0) = tree.at(k1)
  //
  // return tree
  // ```

  let current = tree
  let stack = ()

  for (i, class_id) in item.class.enumerate() {
    if i == item.class.len() - 1 {
      // we've reached the end, insert

      if not overwrite {
        assert(
          not current.at(class_id).keys().contains(item.id),
          message: "ID '" + item.id + "' already exists for class '" + item.class.join("-") + "'",
        )
      }

      current.at(class_id).insert(item.id, (origins: item.origins, fields: item.fields))

      // re-build the tree
      for (j, node) in stack.enumerate().rev() {
        node.at(item.class.at(j)) = current
        current = node
      }

      return current
    }

    // go to the next one
    stack.push(current)
    current = current.at(class_id)
  }

  return tree
}


/// Generates the skeleton of the item tree from the configuration.
///
/// - config (dictionary): Configuration object.
/// -> dictionary
#let _create-tree-from-config(config, _tree: (:)) = {
  for subclass in config.classes {
    let in-tree = _create-tree-from-config(subclass)
    _tree.insert(subclass.id, in-tree)
  }

  return _tree
}



#let create(
  config: default-config,
  ..items,
) = {
  // validate configuration
  let (ok, err) = validate-config(config)
  assert(ok, message: "Invalid configuration: " + err)

  let tree = _create-tree-from-config(config)

  // add items
  for (i, item) in items.pos().enumerate() {
    // validate item
    let (ok, err) = _validate-item(item, config, tree)
    assert(
      ok,
      message: "Invalid item '" + item.at("id", default: i) + "': " + err,
    )

    tree = _add-item(item, tree)
  }

  return (
    items: tree,
    config: config,
  )
}
