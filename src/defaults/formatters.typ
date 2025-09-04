//! Default formatters and auxiliar functions


#import "../utils.typ": *
#import "locale.typ" as locale
#import "../items.typ": (
  get-all-items, get-class, get-class-namer-identifier, get-full-class,
  get-item, get-item-name-id, tag-to-class-tree,
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


/// This function returns a labeled table with the specified `contents` for an n*m sized matrix.
///
/// The label will be `srs:<id>`.
///
/// - contents (array): The table's contents.
/// - id (str): Unique item ID, used in the label.
/// - caption (content, str): The table's caption
/// - language (str): Language to use.
/// - breakable (bool): Whether the table can span multiple pages.
/// - rotation-angle (angle): Rotation angle for the table headers.
/// - displacement (length): Displacement for the table headers (used normally in conjunction with rotate).
/// - style (dictionary): Parameters to pass to the table, e.g. `(columns: (1fr, 1fr), gutter: 1em)`
/// - column-size (length): Size of the columns in the table.
/// -> content
#let traceability-table-formatter(
  contents,
  id,
  caption,
  language,
  breakable: false,
  rotation-angle: 0deg,
  displacement: -0em,
  style: none,
  column-size: auto,
) = {
  if rotation-angle == 0deg {
    displacement = 0em
  }
  // Wrap traceability matrix in a figure with label
  show figure: set block(breakable: breakable)
  // Center all cells for matrix layout
  show table.cell: set align(center)
  // Determine number of columns from header row
  let ncols = contents.at(0).len()
  // Build an array of 1fr repeated for each column
  let columns = ()
  for _ in range(ncols) {
    columns.push(column-size) // 1fr or 8em, for a good fit
  }
  let header-row = contents.at(0)
  let processed-headers = header-row
    .enumerate()
    .map(pair => {
      let (i, header) = pair
      if i > 0 {
        table.cell(
          align: center,
          inset: auto,
        )[#move(
          dy: displacement,
        )[#rotate(rotation-angle)[#header]]]
      } else if i == 0 {
        // First cell gets no top/left borders
        table.cell(stroke: (
          top: none,
          left: none,
        ))[#header]
      } else {
        header
      }
    })
  [
    #figure(
      caption: caption,
      table(
        stroke: (x, y) => {
          let default_stroke = 1pt + black
          if x == 0 and y == 0 {
            // Top-left cell: no top or left borders
            (
              top: none,
              left: none,
              right: default_stroke,
              bottom: default_stroke,
            )
          } else if x == 0 and y > 0 {
            // First column (row headers): no left border
            (
              top: default_stroke,
              left: none,
              right: default_stroke,
              bottom: default_stroke,
            )
          } else if y == 0 and x > 0 {
            // First row (column headers): no top border
            (
              top: none,
              left: default_stroke,
              right: default_stroke,
              bottom: default_stroke,
            )
          } else {
            default_stroke
          }
        },
        ..style,
        columns: columns,
        // First row of contents is header
        table.header(
          ..processed-headers,
        ),
        // Remaining rows are data rows - flatten them
        ..contents.slice(1).flatten(),
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


/// Returns a traceability matrix formatter that formats the relationship between two classes as a table.
///
/// This formatter will create a table that shows the relationships between the fields of the two classes,
/// indicating which fields in the first class are related to which fields in the second class.
/// - language (str, auto): Language of the captions. If `auto`, it will use the one in `config.language`
/// - breakable (bool): If the table can be broken in several pages.
/// - marker (symbol): Symbol to use for marking related fields.
/// - rotation-angle (angle): Rotation angle for the table headers.
/// - style (dictionary): Parameters to pass to the table, e.g. `(align: center, gutter: 0em)`
/// - column-size (length): Size of the columns in the table.
/// -> function
#let table-traceability-formatter-maker(
  language: auto,
  breakable: false,
  marker: sym.checkmark,
  rotation-angle: 0deg,
  style: none,
  column-size: auto,
) = {
  (reqs, tag, comparing-tag) => {
    // Handle automatic language - early return pattern
    let lang = if language == auto {
      let conf-language = reqs.config.at("language", default: none)
      assert(
        conf-language != none,
        message: "Can't set `language` to `auto`. Found no `language` in the configuration",
      )
      conf-language
    } else {
      language
    }

    // Get classes and items once
    let class = get-full-class(reqs.config, tag)
    let comparing-class = get-full-class(reqs.config, comparing-tag)
    let class-items = get-all-items(reqs.items, tag)
    let comparing-items = get-all-items(reqs.items, comparing-tag)

    // Pre-compute all column data
    let column-data = comparing-items
      .keys()
      .map(col-id => {
        let col-tag = (..comparing-tag, col-id)
        let (name, id) = get-item-name-id(reqs.config, reqs.items, col-tag)
        (tag: col-tag, name: name, id: id)
      })

    // Pre-compute all row data
    let row-data = class-items
      .keys()
      .map(row-id => {
        let row-tag = (..tag, row-id)
        let (name, id) = get-item-name-id(reqs.config, reqs.items, row-tag)
        let item = class-items.at(row-id)
        let origins = if "origins" in item and item.origins != none {
          item.origins
        } else { () }
        (tag: row-tag, name: name, id: id, item: item, origins: origins)
      })

    // Building the header row with links
    let header-row = (
      ([],) + column-data.map(col => link(label("srs:" + col.id), col.name))
    )

    // Build data rows
    let data-rows = row-data.map(row => {
      let row-cells = (link((label("srs:" + row.id)), row.name),)

      // Check relationships for all columns at once
      for col in column-data {
        let has-relationship = row.origins.contains(col.tag)
        row-cells.push(if has-relationship [#marker] else [])
      }

      row-cells
    })

    // Generate matrix ID and caption
    let matrix-id = (
      tag.join("-") + "-traceability"
    )
    let caption = [#locale.TRACEABILITY_MATRIX.at(lang), #class.name vs
      #comparing-class.name]

    // Return formatted table
    traceability-table-formatter(
      (header-row,) + data-rows,
      matrix-id,
      caption,
      lang,
      breakable: breakable,
      rotation-angle: rotation-angle,
      style: style,
      column-size: column-size,
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
  fillchar: "0",
) = {
  if type(prefix) == function {
    return (tag, id, fields, index, root-class-name, class-name) => {
      (
        prefix(tag, root-class-name, class-name, separator)
          + separator
          + left-pad(str(index + start), width, fillchar)
      )
    }
  }
  (tag, id, fields, index, root-class-name, class-name) => {
    let id = left-pad(str(index + start), width, fillchar)
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

