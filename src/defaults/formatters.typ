//! Default formatters and auxiliar functions


#import "../utils.typ": *
#import "locale.typ" as locale
#import "../items.typ": (
  get-all-items, get-class, get-class-namer-identifier, get-full-class,
  get-item-name-id, tag-to-class-tree,
)



/// This function returns a labeled table with the specified `contents`.
///
/// The label will be `srs:<id>`.
///
/// - contents (array): The table's contents.
/// - id (str): Unique item ID, used in the label.
/// - caption (content, str): The table's caption
/// - language (str): Language to use.
/// - breakable (bool): Whether the table can span multiple pages.
/// - justify (array): Justification of the two columns, e.g. (true, false)
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// -> content
#let table-formatter(
  contents,
  id,
  caption,
  language,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  show figure: set block(breakable: breakable)
  show table.cell.where(x: 0): set par(justify: justify.at(0))
  show table.cell.where(x: 1): set par(justify: justify.at(1))

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
    #label("srs:" + id)
  ]
}


/* FORMATTERS */


/// Returns an item formatter that formats the item as a table.
///
/// The table's label will have the form `srs:<tag>`, where `<tag>` is the result of calling `tagger`.
///
/// - language (str, auto): Language of the captions. If `auto`, it will use the one in `config.language`
/// - breakable (bool): If the table can be broken in several pages.
/// - justify (array): Justification of the two columns, e.g. (true, false)
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), align: left, gutter: 1em)`
/// -> function
#let table-item-formatter-maker(
  language: auto,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  (class-tag, id, item, index, config, items) => {
    // handle automatic language
    let lang = language
    if language == auto {
      let conf-language = config.at("language", default: none)
      assert(
        conf-language != none,
        message: "Can't set `language` to `auto`. Found no `language` in the configuration",
      )
      lang = conf-language
    }

    let cls = get-full-class(config, class-tag)

    // fields
    let contents = ()
    for class-field in cls.fields {
      contents.push([#strong(class-field.name)])

      let value = item.fields.at(class-field.name, default: [])
      if class-field.value == "content" {
        contents.push(value)
      } else if type(class-field.value) == dictionary {
        // enum
        contents.push([#class-field.value.at(value)])
      }
    }

    // origins
    if cls.origins.len() != 0 {
      contents.push([#strong(locale.ORIGINS.at(lang))])

      contents.push(
        item
          .origins
          .map(origin-tag => {
            let (origin-name, origin-id) = get-item-name-id(
              config,
              items,
              origin-tag,
            )
            [#link(label("srs:" + origin-id), origin-name)]
          })
          .join([, ]),
      )
    }

    // namer/identifier
    let (namer, identifier) = get-class-namer-identifier(config, class-tag, cls)
    let data = (
      class-tag,
      id,
      item.fields,
      index,
      cls.root-class-name,
      cls.name,
    )


    table-formatter(
      contents,
      identifier(..data),
      [#cls.root-class-name "#namer(..data)"], // TODO: extract this as arg
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
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), align: left, gutter: 1em)`
/// -> function
#let table-template-formatter-maker(
  language: auto,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  (config, tag, id) => {
    // handle automatic language
    let lang = language
    if language == auto {
      let conf-language = config.at("language", default: none)
      assert(
        conf-language != none,
        message: "Can't set `language` to `auto`. Found no `language` in the configuration",
      )
      lang = conf-language
    }

    let class = get-full-class(config, tag)

    // fields
    let contents = class
      .fields
      .map(field => (
        // field name
        [#strong(field.name)],
        // field description
        if type(field.value) == dictionary [
          // for enumerated value types, include their default values
          #field.description (#for (i, v) in (
            field.value.values().enumerate()
          ) [#emph(v)#if i != field.value.len() - 1 { ", " }])
        ] else {
          [#field.description]
        },
      ))
      .flatten()

    // origins
    // TODO: non-terminal classes...
    if class.origins.len() != 0 {
      contents += (
        [#strong(locale.ORIGINS.at(lang))],
        [#class.origins.description],
      )
    }

    table-formatter(
      contents,
      id,
      locale.TEMPLATE.at(lang)(class.name, lower(class.root-class-name)), // TODO: extract this as arg
      lang,
      breakable: breakable,
      justify: justify,
      style: style,
    )
  }
}




/* NAMERS */


/// Returns a namer function that names the item by the specified field name.
///
/// - field-name (str): Class field to get the item name from.
/// -> function
#let field-namer-maker(field-name) = {
  (tag, id, fields, index, root-class-name, class-name) => {
    fields.at(field-name)
  }
}



/// Returns a namer function that names the item with an incremental name, e.g. `<prefix><separator>0X`.
///
/// - prefix (function, str, none): Prefix to use. Can be dynamic, if a function `(tag: array, root-class-name: str, class-name: str, separator: str) -> str` is supplied, or static, if string, or `none`, in which case the tag will be just the ID.
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
    return (tag, id, fields, index, root-class-name, class-name) => {
      (
        prefix(tag, root-class-name, class-name, separator)
          + separator
          + left-pad(str(index + start), 2, "0")
      )
    }
  }
  (tag, id, fields, index, root-class-name, class-name) => {
    let id = left-pad(str(index + start), 2, "0")
    if prefix == none { id } else { prefix + separator + id }
  }
}




/* LABLERS */


/// Returns a identifier function, which creates tags of form `<prefix><separator><id>`.
///
/// - prefix (function, str, none): Prefix to use. Can be dynamic, if a function `(tag: array, root-class-name: str, class-name: str, separator: str) -> str` is supplied, or static, if string, or `none`, in which case the tag will be just the ID.
/// - separator (str): Separator between the prefix and name. If `prefix` is a function, this will be the argument passed.
/// -> function
#let identifier-maker(
  prefix: none,
  separator: "-",
) = {
  if type(prefix) == function {
    return (tag, id, fields, index, root-class-name, class-name) => {
      (
        prefix(tag, root-class-name, class-name, separator) + separator + id
      )
    }
  }

  (tag, id, fields, index, root-class-name, class-name) => {
    if prefix == none { id } else { prefix + separator + id }
  }
}

