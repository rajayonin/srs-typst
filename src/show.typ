#import "utils.typ": *

// This function returns an array of all the classes and subclasses of
// `config' following the path described by `tag'. For instance: if `tag'
// is `("R", "F")', then the result will be an array of two elements: the
// class "R" and its child class "F".
//
// - config (dict): The configuration lol
// - tag (array): The tag
// -> array
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

// This function merges all the fields of a class and subclasses identified
// by the `tag' into a big class which contains all the fields. The name of
// the resulting class is the name of the youngest child. This is a helper
// function.
//
// - config (dict): Guess what?! The configuration! lmao
// - tag (array): Tag
// -> dict
#let _full-class(config, tag) = {
  let classes = _tag-to-class-tree(config, tag)
  return (
    root: classes.first().name,
    leaf: classes.last().name,
    tag: tag,
    fields: classes.map((class) => class.fields).flatten()
  )
}

// Returns all the items that belong to the given class given by the `tag'.
//
// - reqs (dict): The requirements
// - tag (array): The tag
// -> array
#let _get-all-items(reqs, tag) = {
  let iter = reqs.items
  for subtag in tag { iter = iter.at(subtag) }
  return iter
}

// This function creates a dummy item from a FULL class specification, where
// the values are just the default values.
//
// - class (dict): The class
// -> dict
#let _class-as-template-item(class) = {
  return (fields:
    class.fields.map((field) => { (field.name, field.description) }).to-dict())
}

#let show-class(reqs, tag, class-formatter: none, item-formatter: none) = {

  let class = _full-class(reqs.config, tag)
  let items = _get-all-items(reqs, tag)
  return [
    #class-formatter(class)
    #mapi(items.pairs(),
          (pair, index) =>
            item-formatter(class, pair.last(), pair.first(), index)).join([])
  ]
}


/* *** DEFAULTS *** ======================================================== */

// This function returns a labeled table for the given `item' associated to
// the given `class'.
//
// class (dict): The FULL class
// item (dict): The item
// id (str): The label
// caption (content, string): The table's caption
// breakable (boolean): Whether the table can span multiple pages.
#let _class-formatter-helper(class, item,
    id:        none,
    caption:   none,
    breakable: true) = {

  show figure: set block(breakable: breakable)
  show table.cell.where(x: 0): set par(justify: false)

  let contents = ()
  for field in class.fields {
    contents.push([*#field.name*])
    let value = item.fields.at(field.name, default: [])
    if field.value == "content" or type(value) == content {
      contents.push(value)
    } else {
      contents.push([#field.value.at(value)])
    }
  }

  [
    #figure(
      caption: caption,
      table(
        columns: (8.0em, 100% - 8.0em),
        align: (left, left),
        table.header([*Campo*], [*Comentario*]),
        ..contents))
    #if id != none { label(id) }
  ]
}

#let default-item-formatter-maker(
    name:      none,
    breakable: true) = (class, item, id, index) => {
  return _class-formatter-helper(class, item, id: id,
    caption: [#class.root «#name(class, item, id, index)»],
    breakable: breakable)
}

#let default-class-formatter-maker(
    breakable: true) = (class) => {
  return _class-formatter-helper(
    class, _class-as-template-item(class),
    caption: [Plantilla de «#class.leaf»],
    breakable: breakable)
}

#let name-by-field-maker(field-name) = {
  (class, item, id, index) => { item.fields.at(field-name) }
}

#let incremental-name-maker(prefix, first: 1, width: 2) = {
  (class, item, id, index) => { prefix + left-pad(str(index + first), 2, "0") }
}
