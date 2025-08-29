#import "/src/lib.typ" as srs


#let reqs = srs.create(
  config: srs.make-config(
    language: "en",
    item-formatter: srs.defaults.basic-item-formatter,
    template-formatter: srs.defaults.basic-template-formatter,
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


// #reqs.config
// #reqs.items

#srs.show-template(reqs, srs.make-tag("R", "U"), "srs:RU-template")
@srs:RU-template

#srs.show-items(reqs, srs.make-tag("R", "U", "RE"))
@srs:R-U-RE-user-req

#srs.show-template(reqs, srs.make-tag("R", "S"), "srs:RS-template")
@srs:RU-template

#srs.show-items(reqs, srs.make-tag("R", "S", "NF"))
@srs:R-S-NF-cool-req

