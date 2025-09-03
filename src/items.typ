//! Functions for creating and managing items


#import "config.typ": validate-config


/* QUERY FUNCTIONS */

/// Returns the class matching the tag.
///
/// - config (dictionary): Main config.
/// - tag (array): Tag of the class to find.
/// -> dictionary
#let get-class(config, tag) = {
  let current = config

  for subtag in tag {
    current = current.classes.find(x => x.id == subtag)
    assert(
      current != none,
      message: "Couldn't find tag '" + tag.join("-") + "'.",
    )
  }

  return current
}


/// This function returns an array of all the classes and subclasses of
/// `config` following the path described by `tag`. For instance: if `tag`
/// is `("R", "F")`, then the result will be an array of two elements: the
/// class "R" and its child class "F".
///
/// - config (dictionary): The configuration lol
/// - tag (array): The tag
/// -> array
#let tag-to-class-tree(config, tag) = {
  let iter = config
  let result = ()
  for subtag in tag {
    let found = none
    for class in iter.classes { if class.id == subtag { found = class } }
    assert(found != none, message: "Class tree couldn't be created")
    iter = found
    result.push(found)
  }
  return result
}


/// Obtains the namer and identifier for a class, taking into account autos.
///
/// - config (dictionary): The full config
/// - class (dictionary): The class
/// -> array
#let get-class-namer-identifier(config, tag, class) = {
  if class.namer == auto or class.identifier == auto {
    // inherit from ancestors
    let namer = none
    let identifier = none
    for c in tag-to-class-tree(config, tag).rev() {
      if class.namer == auto and c.namer != auto { namer = c.namer }
      if class.identifier == auto and c.identifier != auto {
        identifier = c.identifier
      }
      if namer != none or identifier != none { break }
    }
    return (namer, identifier)
  } else { return (class.namer, class.identifier) }
}



/// This function merges all the fields of a class and subclasses identified
/// by the `tag` into a big class which contains all the fields. The name of
/// the resulting class is the name of the youngest child. This is a helper
/// function.
///
/// - config (dictionary): Guess what?! The configuration! lmao
/// - tag (array): Tag
/// -> dictionary
#let get-full-class(config, tag) = {
  let classes = tag-to-class-tree(config, tag)
  let cls = classes.last()
  return (
    name: cls.name,
    root-class-name: classes.first().name,
    tag: tag,
    fields: classes.map(class => class.fields).flatten(),
    namer: cls.namer,
    identifier: cls.identifier,
    origins: cls.origins,
    terminal: cls.classes.len() == 0,
  )
}


/// Returns all the items that belong to the given class given by the `tag`.
///
/// - items (dictionary): The item tree.
/// - tag (array): The tag
/// -> array
#let get-all-items(items, tag) = {
  let iter = items
  for subtag in tag { iter = iter.at(subtag) }
  return iter
}

/// Returns all the items that belong to the given class given by the `tag`.
///
/// - items (dictionary): The item tree.
/// - class-tag (array): The item's class.
/// - id (str): The item's ID.
/// -> array
#let get-item(items, class-tag, id) = get-all-items(items, class-tag).at(id)


/// Returns the name and label of the specified item.
///
/// - config (dictionary): Full config.
/// - items (dictionary): Full item tree.
/// - tag (array): Full item tag, including its ID.
/// -> array
#let get-item-name-id(config, items, tag) = {
  let class-tag = tag.slice(0, -1)
  let id = tag.last()
  let class-items = get-all-items(items, class-tag)

  let class = get-class(config, class-tag)

  let data = (
    class-tag, // class-tag
    id, // id
    class-items.at(id).fields, // fields
    class-items.keys().position(x => x == id), // index
    get-class(config, tag.slice(0, count: 1)).name, // root-class-name
    class.name, // class-name
  )

  let (namer, identifier) = get-class-namer-identifier(
    config,
    class-tag,
    class,
  )

  (namer(..data), identifier(..data))
}



/* CREATION */

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
/// - ..fields (arguments): Fields of the item, according to the class, e.g. `Name: "Potato"`.
/// -> dictionary
#let make-item(id, class, origins: (), ..fields) = (
  id: id,
  class: class,
  origins: origins,
  fields: fields.named(),
)



/// Validates an item's fields.
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
        + class_fields
          .filter(f => not f.name in item_fields)
          .map(f => f.name)
          .join(", ")
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
    } else if (type(field.value) == dictionary and not value in field.value) {
      return (
        false,
        "Invalid value for field '"
          + field.name
          + "'. Valid values are '"
          + field.value.keys().join("', '")
          + "'.",
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
    let found = false
    let item_origin_tag = origin_tag.slice(0, count: origin_tag.len() - 1)

    for class_origin_tag in class_origins.tags {
      found = found or item_origin_tag == class_origin_tag
    }

    if not found {
      return (
        false,
        "Invalid origin. Class '"
          + item_origin_tag.join("-")
          + "' is not a valid origin class (valid classes are '"
          + class_origins.tags.map(t => t.join("-")).join(", '")
          + "')",
      )
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
    (type(item) != dictionary)
      or item.keys() != ("id", "class", "origins", "fields")
  ) {
    return (false, "Invalid format. Please make sure to use #make-item.")
  }

  if type(item.class) != array {
    return (false, "Invalid format. `class` is not an array.")
  }

  if type(item.origins) != array {
    return (false, "Invalid format. `origins` is not an array.")
  }

  // validate ID (no spaces)
  if " " in item.id {
    return (false, "Invalid ID. Spaces are not allowed in the ID.")
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
        "Invalid class. '"
          + class_id
          + "' is not a subclass of '"
          + item.class.at(i - 1)
          + "'.",
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
          not item.id in current.at(class_id),
          message: "ID '"
            + item.id
            + "' already exists for class '"
            + item.class.join("-")
            + "'",
        )
      }

      current
        .at(class_id)
        .insert(item.id, (origins: item.origins, fields: item.fields))

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
  config: none,
  ..items,
) = {
  assert(config != none, message: "Missing argument 'config'")

  // validate configuration
  let (ok, err) = validate-config(config)
  assert(ok, message: "Invalid configuration: " + err)

  // TODO: expand autos here instead of in formatters

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

