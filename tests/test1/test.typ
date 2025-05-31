#import "/src/lib.typ" as srs

#srs.create(
  config: srs.default-config,
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
