#import "/src/lib.typ" as srs


#show table: block.with(stroke: (y: 0.7pt))
// #set table(
//   row-gutter: -0.1em, // Row separation
//   stroke: (_, y) => if y == 0 { (bottom: 0.2pt) },
//   align: left,
// )


#let my-table-style = (
  columns: (8em, 1fr),
  row-gutter: -0.1em,
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) },
  align: (left, left),
)

#let reqs = srs.create(
  config: srs.make-config(
    item-formatter: srs.defaults.table-item-formatter-maker(
      namer: srs.defaults.incremental-namer-maker(
        prefix: (class, separator) => { class.tag.slice(1).join(separator) },
      ),
      tagger: srs.defaults.item-tagger-maker(
        prefix: (class, separator) => { class.tag.join(separator) },
      ),
      breakable: false,
      style: my-table-style,
    ),
    template-formatter: srs.defaults.table-template-formatter-maker(
      tagger: srs.defaults.template-tagger-maker(),
      breakable: false,
      style: my-table-style,
    ),
    classes: srs.defaults.base-classes,
  ),
  srs.make-item(
    "user-req",
    srs.make-tag("R", "U", "RE"),
    Description: [Man, I want like... some cool stuff bro...],
    Necessity: "h",
    Priority: "h",
    Stability: "c",
    Verifiability: "l",
  ),
  srs.make-item(
    "cool-req",
    srs.make-tag("R", "S", "NF"),
    origins: (srs.make-tag("R", "U", "RE", "user-req"),),
    Description: [The software shall be cool.],
    Necessity: "h",
    Priority: "h",
    Stability: "c",
    Verifiability: "l",
  ),
)

#srs.show-template(reqs, srs.make-tag("R", "U"))

#srs.show-items(reqs, srs.make-tag("R", "U", "RE"))


