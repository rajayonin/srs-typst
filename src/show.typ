//! Functions for showing the items

#import "utils.typ": *


/// This function returns an array of all the classes and subclasses of
/// `config` following the path described by `tag`. For instance: if `tag`
/// is `("R", "F")`, then the result will be an array of two elements: the
/// class "R" and its child class "F".
///
/// - config (dictionary): The configuration lol
/// - tag (array): The tag
/// -> array
#let _tag-to-class-tree(config, tag) = {
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

/// This function merges all the fields of a class and subclasses identified
/// by the `tag` into a big class which contains all the fields. The name of
/// the resulting class is the name of the youngest child. This is a helper
/// function.
///
/// - config (dictionary): Guess what?! The configuration! lmao
/// - tag (array): Tag
/// -> dictionary
#let _full-class(config, tag) = {
  let classes = _tag-to-class-tree(config, tag)
  return (
    name: classes.last().name,
    root-class-name: classes.first().name,
    tag: tag,
    fields: classes.map(class => class.fields).flatten(),
    terminal: classes.last().classes.len() == 0,
  )
}

/// Returns all the items that belong to the given class given by the `tag`.
///
/// - reqs (dictionary): The requirements
/// - tag (array): The tag
/// -> array
#let _get-all-items(reqs, tag) = {
  let iter = reqs.items
  for subtag in tag { iter = iter.at(subtag) }
  return iter
}



/// Shows a template for the items of the specified class tag.
///
/// - reqs (dictionary): Requirements object.
/// - tag (array): Item class tag, use `make-tag` to generate it. Must be a terminal class.
/// - formatter (function, auto): Formatter function, of format `(class: dictionary, language: str | none) -> content`. If `auto`, it uses the configuration's default `template-formatter`.
/// -> content
#let show-template(reqs, tag, formatter: auto) = {
  if formatter == auto {
    // use the one defined in config
    formatter = reqs.config.at("template-formatter", default: none)
    assert(
      formatter != none,
      message: "Can't set `formatter` to `auto`. Found no `template-formatter` in the configuration.",
    )
  }

  let class = _full-class(reqs.config, tag)
  let items = _get-all-items(reqs, tag)
  return formatter(class, reqs.config.at("language", default: none))
}

/// Shows the items belonging to the specified class tag.
///
/// - reqs (dictionary): Requirements object.
/// - tag (array): Item class tag, use `make-tag` to generate it. Must be a terminal class.
/// - formatter (function, auto): Formatter function, of format `(class: dictionary, item: dictionary, id: str, index: int, language: str | none) -> content`. If `auto`, it uses the configuration's default `item-formatter`.
/// -> content
#let show-items(reqs, tag, formatter: auto) = {
  if formatter == auto {
    // use the one defined in config
    formatter = reqs.config.at("item-formatter", default: none)
    assert(
      formatter != none,
      message: "Can't set `formatter` to `auto`. Found no `item-formatter` in the configuration",
    )
  }

  let class = _full-class(reqs.config, tag)
  assert(class.terminal, message: "Can't show items for a non-terminal class.")

  let items = _get-all-items(reqs, tag)
  return {
    mapi(
      items.pairs().filter(x => x.last().len() != 0), // filter out empty classes
      (pair, index) => {
        formatter(
          class,
          pair.last(),
          pair.first(),
          index,
          reqs.config.at("language", default: none),
        )
      },
    ).join([])
  }
}

