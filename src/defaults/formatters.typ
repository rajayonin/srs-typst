#import "../utils.typ": *
#import "locale.typ" as locale
#import "../items.typ": get-all-items, get-class, get-full-class



/// This function creates a dummy item from a FULL class specification, where
/// the values are just the description and, in enumerated-type values, possible values.
///
/// - class (dictionary): The FULL class specification.
/// -> dictionary
#let _class-as-template-item(class) = (
  origins: class.origins.description,
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


/// This function returns a labeled table with the specified `contents`.
///
/// - contents (array): The table's contents.
/// - id (str): Label that will be applied to the figure.
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
    #label(id)
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
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// -> function
#let table-item-formatter-maker(
  language: auto,
  breakable: false,
  justify: (false, true),
  style: (columns: 2),
) = {
  (class, id, item, index, config, items) => {
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

    let cls = get-full-class(config, class)

    // fields
    let contents = ()
    for class-field in cls.fields {
      contents.push([#strong(class-field.name)])

      let value = item.fields.at(class-field.name, default: [])
      if class-field.value == "content" or type(value) == content {
        contents.push(value)
      } else {
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
          .map(
            origin => {
              let origin-tag = origin.slice(0, -1)
              let origin-id = origin.last()
              let origin-class-items = get-all-items(items, origin-tag)

              let origin-item = origin-class-items.at(origin-id)
              let origin-index = origin-class-items
                .keys()
                .position(x => x == id)
              let root-class-name = get-class(config, origin.slice(
                0,
                count: 1,
              )).name

              let origin-class = get-class(config, origin-tag)

              [#link(
                (origin-class.labler)(
                  origin-tag,
                  origin-id,
                  origin-item.fields,
                  origin-index,
                  root-class-name,
                  origin-class.name,
                ),
                (origin-class.namer)(
                  origin-tag,
                  origin-id,
                  origin-item.fields,
                  origin-index,
                  root-class-name,
                  origin-class.name,
                ),
              )]
            },
          )
          .join([, ]),
      )
    }


    table-formatter(
      contents,
      (cls.labler)(
        class,
        id,
        item.fields,
        index,
        cls.root-class-name,
        cls.name,
      ),
      [#cls.root-class-name "#(cls.namer)(
          class,
          id,
          item.fields,
          index,
          cls.root-class-name,
          cls.name,
        )"],
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
      locale.TEMPLATE.at(lang)(class.name, lower(class.root-class-name)),
      lang,
      breakable: breakable,
      justify: justify,
      style: style,
    )
  }
}


/// Basic item formatter, which creates tables.
///
/// Each table has a label and can be referenced with its class path and id, separated by `-`.
///
/// -> function
#let basic-item-formatter = table-item-formatter-maker()

/// Basic item formatter, which creates tables.
///
/// Each table has a label and can be referenced with its class path and id, separated by `-`.
///
/// -> function
#let basic-template-formatter = table-template-formatter-maker()



/* NAMERS */


/// Returns a namer function that names the item by the specified field name.
///
/// - field-name (str): Class field to get the item name from.
/// -> function
#let field-namer-maker(field-name) = {
  (tag, id, fields, index, root-class-name, class-name) => {
    item.fields.at(field-name)
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


#let basic-item-namer = incremental-namer-maker(
  prefix: (tag, root-class-name, class-name, separator) => {
    tag.join(separator)
  },
  separator: "-",
  start: 1,
  width: 2,
)



/* LABLERS */


/// Returns a labler function, which creates tags of form `<prefix><separator><id>`.
///
/// - prefix (function, str, none): Prefix to use. Can be dynamic, if a function `(tag: array, root-class-name: str, class-name: str, separator: str) -> str` is supplied, or static, if string, or `none`, in which case the tag will be just the ID.
/// - separator (str): Separator between the prefix and name. If `prefix` is a function, this will be the argument passed.
/// -> function
#let item-labler-maker(
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


#let basic-item-labler = item-labler-maker(
  prefix: (tag, root-class-name, class-name, separator) => {
    "srs:" + tag.join(separator)
  },
  separator: "-",
)
