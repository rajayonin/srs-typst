//! Functions for showing the items

#import "utils.typ": *
#import "items.typ": get-all-items, get-class, get-full-class, tag-to-class-tree




/// Shows a template for the items of the specified class tag.
///
/// - reqs (dictionary): Requirements object.
/// - tag (array): Item class tag, use `make-tag` to generate it.
/// - id (str): ID to give to the template, typically used in the label of a figure.
/// - formatter (function, auto): Formatter function, of format `(config: dict, tag: array, id: str) -> content`. If `auto`, it uses the configuration's default `template-formatter`.
/// -> content
#let show-template(reqs, tag, id, formatter: auto) = {
  if formatter == auto {
    // use the one defined in config
    formatter = reqs.config.at("template-formatter", default: none)
    assert(
      formatter != none,
      message: "Can't set `formatter` to `auto`. Found no `template-formatter` in the configuration.",
    )
  }

  formatter(reqs.config, tag, id)
}

/// Shows the items belonging to the specified class tag.
///
/// - reqs (dictionary): Requirements object.
/// - tag (array): Item class tag, use `make-tag` to generate it. Must be a terminal class.
/// - formatter (function, auto): Formatter function, of format `(class-tag: array, id: str, item: dictionary, index: int, config: dict, items: dictionary) -> content`. If `auto`, it uses the configuration's default `item-formatter`.
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

  // TODO: for non-terminal classes, show items of subclasses

  // return {
  mapi(
    get-all-items(reqs.items, tag)
      .pairs()
      // filter out empty classes
      .filter(x => x.last().len() != 0),
    ((id, item), index) => {
      formatter(
        tag,
        id,
        item,
        index,
        reqs.config,
        reqs.items,
      )
    },
  ).join([])
  // }
}

#let show-traceability(reqs, tag, comparing-tag: auto, formatter: auto) = {
  // choose formatter
  if formatter == auto {
    formatter = reqs.config.at("traceability-formatter", default: none)

    assert(
      formatter != auto,
      message: "Can't set `formatter` to `auto`. Found no `traceability-formatter` in the configuration.",
    )
  }

  // infer comparing-tag if needed
  if comparing-tag == auto {
    let cls = get-full-class(reqs.config, tag)
    assert(
      cls.origins.tags.len() != 0,
      message: "Can't infer `comparing-tag` automatically: class has no `origins.tags`.",
    )
    comparing-tag = cls.origins.tags.at(0)
  }


  // delegate to formatter
  formatter(reqs, tag, comparing-tag)
}
