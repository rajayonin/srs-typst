#import "/src/lib.typ" as srs


#let reqs = srs.create(
  config: srs.make-config(
    language: "en",
    item-formatter: srs.defaults.table-item-formatter-maker(),
    template-formatter: srs.defaults.table-template-formatter-maker(),
    traceability-formatter: srs.defaults.table-traceability-formatter-maker(
      style: (row-gutter: 0em),
      rotation-angle: 0deg,
      column_size: 7em,
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
  srs.make-item(
    "cool-req-patata",
    srs.make-tag("R", "S", "NF"),
    origins: (
      srs.make-tag("R", "U", "RE", "user-req"),
    ),
    Description: [The software shall veryyy be cool.],
    Necessity: "h",
    Priority: "h",
    Stability: "c",
    Verifiability: "l",
  ),
)



// #reqs.config
#reqs.items

#srs.show-template(reqs, srs.make-tag("R", "U"), "RU-template")
@srs:RU-template

#srs.show-items(reqs, srs.make-tag("R", "U", "RE"))
@srs:R-U-RE-user-req

#srs.show-template(reqs, srs.make-tag("R", "S", "NF"), "RS-template")
@srs:RS-template

#srs.show-items(reqs, srs.make-tag("R", "S", "NF"))
@srs:R-S-NF-cool-req

#srs.show-traceability(reqs, srs.make-tag("R", "S", "NF"))
@srs:R-S-NF-traceability



// si es auto te lo muestra TODO

// hacer un formatter maker, que devuelve una barbaridad de cosas

// hacer un formater que sea un class-tag, origin-class-tag (array)

// hacer validaciones

// que los origenes sean de la clase
// Que se pueda
