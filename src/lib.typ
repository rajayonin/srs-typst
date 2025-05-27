#let enum-type(..values) = { return values.named() }

#let english-scale-type = enum-type(
  h : "High",
  m : "Medium",
  l : "Low")

#let english-stability-type = enum-type(
  c  : "Constant",
  i  : "Inconstant",
  vu : "Very unstable")

/*
#let english-default-config = make-config(
  make-class("R", "Requirements",
    fields: (
      make-field("Description", content-type,
                 [Detailed description of the requirement])
      make-field("Necessity", english-scale-type,
                 [Priority of the requirement of the user]),
      make-field("Priority", english-scale-type,
                 [Priority of the requirement for the developer]),
      make-field("Stability", english-stability-type,
                 [Indicates the requirement's variability through the
                 development process]),
      make-field("Verifiability", english-scale-type,
                 [Ability to thest the vailidity of the requirement])
    ),
    subclasses: (
      make-class("U", "User",
        subclasses: (
          make-class("CA", "Capability", origins : ()),
          make-class("RE", "Restriction", origins : ()))),
      make-class("S", "Software",
        subclasses: (
          make-class("FN", "Functional",
                     origins : make-origins(
                       [User requirements that derived this requirement.]
                       tag("R", "U", "CA"))),
          make-class("NF", "Non-functional",
                     origins : make-origins(
                       [User requirements that derived this requirement.]
                       tag("R", "U", "RE")))))
    )
  ),
  make-class("U", "Use Cases",
    fields: (
      make-field("Name", content-type,
                 [Brief description of the use case]),
      make-field("Actors", content-type,
                 [External agent that executes the use case]),
      make-field("Objective", content-type,
                 [The use case's purpose]),
      make-field("Pre-condition", content-type,
                 [Conditions that must be fulfilled _before_ executing the use
                  case])
      make-field("Post-condition", content-type,
                 [Conditions that must be fulfilled _after_ executing the use
                  case])
      )
  ),
  make-class("C", "Component"
    fields: (
      make-field("Role", content-type,
                 [Component's function in the system]),
      make-field("Dependencies", content-type,
                 [Components that depe]),
      make-field("Description", content-type,
                 [Explanation of the component's functionality]),
      make-field("Inputs", content-type,
                 [Component's input data]),
      make-field("Outputs", content-type,
                 [Component's output data]),
    )
  ),
  make-class("T", "Test"),
    fields: (
      make-field("Description", content-type,
                 [Test description]),
      make-field("Preconditions", content-type,
                 [Conditions that must be fulfilled in order to perform the
                  test]),
      make-field("Postcondition", content-type,
                 [Conditions that must be fulfilled after performing the test
                  in order to pass]),
      make-field("Evaluation", make-enum("ok": "OK", "err": "Error"))
    ),
    subclasses: (
      make-class("VAT", "Validation Test",
                 origins: make-origins(
                   [Requirement that originated this test.]
                   tag("R", "S", "FN"),
                   tag("R", "S", "NF"))),
      make-class("VET", "Verification Test",
                 origins: make-origins(
                   [Requirement that originated this test.]
                   tag("R", "U", "CA"),
                   tag("R", "U", "RE")))
      )
    )
  )
)

#let _create-tree-from-config(tree, config) = (
  for (name, sub) in config {
    let in-tree = _create-tree-from-config((:), sub)
    tree.insert(name, in-tree)
  },
  return tree
)

#let create(
  config : default-config) = {

  let tree = (:)
  tree = _create-tree-from-config(tree, config)

  return (
    tree : tree,
    config : (),
    requirements : ()
  )
}
*/
