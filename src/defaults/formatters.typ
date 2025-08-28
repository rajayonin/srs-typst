#import "../utils.typ": *
#import "locale.typ" as locale



/// This function creates a dummy item from a FULL class specification, where
/// the values are just the default values.
///
/// - class (dictionary): The class.
/// -> dictionary
#let _class-as-template-item(class) = {
  return (
    fields: class
      .fields
      .map(field => {
        (
          field.name,
          if type(field.value) == dictionary [
            // for enumerated value types, include their default values
            #field.description (#for (i, v) in (
              field.value.values().enumerate()
            ) [#emph(v)#if i != field.value.len() - 1 { ", " }])
          ] else {
            field.description
          },
        )
      })
      .to-dict(),
  )
}

/// This function returns a labeled table for the given `item` associated to
/// the given `class`.
///
/// The table's label will take the form `srs:<tag>`.
///
/// - class (dictionary): The FULL class
/// - item (dictionary): The item
/// - tag (str): Item tag, used to identify it.
/// - caption (content, str): The table's caption
/// - language (str): Language to use.
/// - breakable (bool): Whether the table can span multiple pages.
/// - justify (array): Justification of the two columns, e.g. (true, false)
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// -> content
#let table-formatter(
  class,
  item,
  tag,
  caption,
  language,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  show figure: set block(breakable: breakable)
  show table.cell.where(x: 0): set par(justify: justify.at(0))
  show table.cell.where(x: 1): set par(justify: justify.at(1))

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
        ..style,
        table.header(
          [*#locale.FIELD.at(language)*],
          [*#locale.DESCRIPTION.at(language)*],
        ),
        ..contents,
      ),
    )
    #label("srs:" + tag)
  ]
}

/// Returns an item formatter that formats the item as a table.
///
/// The table's label will have the form `srs:<tag>`, where `<tag>` is the result of calling `tagger`.
///
/// - namer (function): Function to format the item's name, of form `(class, item, id, index) -> str`.
/// - tagger (function): Function to format the item's tag, of form `(class, item, id, index) -> str`.
/// - language (str, auto): Language of the captions. If `auto`, it will use the one in `config.language`
/// - breakable (bool): If the table can be broken in several pages.
/// - justify (array): Justification of the two columns, e.g. (true, false)
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// -> function
#let table-item-formatter-maker(
  namer: none,
  tagger: none,
  language: auto,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  assert(namer != none, message: "Missing argument 'namer'")
  assert(tagger != none, message: "Missing argument 'tagger'")
  (class, item, id, index, conf-language) => {
    // handle automatic language
    let lang = language
    if language == auto {
      assert(
        conf-language != none,
        message: "Can't set `language` to `auto`. Found no `language` in the configuration",
      )
      lang = conf-language
    }

    table-formatter(
      class,
      item,
      tagger(class, item, id, index),
      [#class.root-class-name "#namer(class, item, id, index)"],
      lang,
      breakable: breakable,
      justify: justify,
      style: style,
    )
  }
}


/// Returns a template formatter that formats the template as a table.
///
/// The table's label will have the form `srs:<tag>`, where `<tag>` is the result of calling `tagger`.
///
/// - tagger (function): Function to format the item's tag, of form `(class, item, id, index) -> str`.
/// - language (str, auto): Language of the captions. If `auto`, it will use the one in `config.language`
/// - breakable (bool): If the table can be broken in several pages.
/// - justify (array): Justification of the two columns, e.g. (true, false)
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// -> function
#let table-template-formatter-maker(
  tagger: none,
  language: auto,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  assert(tagger != none, message: "Missing argument 'tagger'")
  (class, conf-language) => {
    // handle automatic language
    let lang = language
    if language == auto {
      assert(
        conf-language != none,
        message: "Can't set `language` to `auto`. Found no `language` in the configuration",
      )
      lang = conf-language
    }

    table-formatter(
      class,
      _class-as-template-item(class),
      tagger(class),
      locale.TEMPLATE.at(lang)(class.name, lower(class.root-class-name)),
      lang,
      breakable: breakable,
      justify: justify,
      style: style,
    )
  }
}


/// Returns a namer function that names the item by the specified field name.
///
/// - field-name (str): Class field to get the item name from.
/// -> function
#let field-namer-maker(field-name) = {
  (class, item, id, index) => { item.fields.at(field-name) }
}



/// Returns a namer function that names the item with an incremental name, e.g. `<prefix><separator>0X`.
///
/// - prefix (function, str, none): Prefix to use. Can be dynamic, if a function `(class: dictionary, separator: str) -> str` is supplied, or static, if string, or `none`, in which case the tag will be just the ID.
/// - separator (str): Separator between the prefix and name. If `prefix` is a function, this will be the argument passed.
/// - start (int): Starting index.
/// - width (int): Width of the index, which will be padded with zeroes.
/// -> function
#let incremental-namer-maker(
  prefix: none,
  separator: "-",
  start: 1,
  width: 2,
) = {
  if type(prefix) == function {
    return (class, item, id, index) => {
      (
        prefix(class, separator)
          + separator
          + left-pad(str(index + start), 2, "0")
      )
    }
  }
  (class, item, id, index) => {
    let id = left-pad(str(index + start), 2, "0")
    if prefix == none { id } else { prefix + separator + id }
  }
}



/// Returns a tagger function, which creates tags of form `<prefix><separator><id>`.
///
/// - prefix (function, str, none): Prefix to use. Can be dynamic, if a function `(class: dictionary, separator: str) -> str` is supplied, or static, if string, or `none`, in which case the tag will be just the ID.
/// - separator (str): Separator between the prefix and name. If `prefix` is a function, this will be the argument passed.
/// -> function
#let item-tagger-maker(
  prefix: none,
  separator: "-",
) = {
  if type(prefix) == function {
    return (class, item, id, index) => {
      (prefix(class, separator) + separator + id)
    }
  }

  (class, item, id, index) => {
    if prefix == none { id } else { prefix + separator + id }
  }
}

/// Returns a tagger function, which creates tags of form `<class-name><separator>template`.
///
/// - separator (str):
/// -> function
#let template-tagger-maker(separator: "-") = {
  class => {
    lower(class.name.replace(" ", separator)) + separator + "template"
  }
}


/// Basic item formatter, which creates tables.
///
/// Each table has a label and can be referenced with its class path and id, separated by `-`.
///
/// -> function
#let basic-item-formatter = table-item-formatter-maker(
  namer: incremental-namer-maker(
    prefix: (class, separator) => { class.tag.slice(1).join(separator) },
  ),
  tagger: item-tagger-maker(
    prefix: (class, separator) => { class.tag.join(separator) },
  ),
  breakable: false,
)


/// Basic template formatter, which creates tables.
/// Each table has a label and can be referenced as `<class-name>-template`. Note that the class name will be in lowercase.
/// -> function
#let basic-template-formatter = table-template-formatter-maker(
  tagger: template-tagger-maker(),
)
