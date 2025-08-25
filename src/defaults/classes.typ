#import "../config.typ": *


#let _scale-type = make-enum-field(
  h: "High",
  m: "Medium",
  l: "Low",
)


#let _stability-type = make-enum-field(
  c: "Constant",
  i: "Inconstant",
  vu: "Very unstable",
)


// TODO: locale


/// Base class set.
///
/// Includes:
/// - Requirement (R)
///   - User Requirement (U)
///     - Capabilities (CA)
///     - Restrictions (RE)
///   - Software Requirement (S)
///     - Functional (FN)
///     - Non-Functional (NF)
/// - Use Case (U)
/// - Component (C)
/// - Test (T)
///   - Verification (VET)
///   - Validation (VAT)
///
/// -> array
#let base-classes = (
  make-class(
    "R",
    "Requirement",
    fields: (
      make-field(
        "Description",
        content-field,
        [Detailed description of the requirement],
      ),
      make-field(
        "Necessity",
        _scale-type,
        [Priority of the requirement of the user],
      ),
      make-field(
        "Priority",
        _scale-type,
        [Priority of the requirement for the developer],
      ),
      make-field(
        "Stability",
        _stability-type,
        [Indicates the requirement's variability through the development
          process],
      ),
      make-field(
        "Verifiability",
        _scale-type,
        [Ability to test the vailidity of the requirement],
      ),
    ),
    classes: (
      make-class(
        "U",
        "User",
        classes: (
          make-class("CA", "Capability"),
          make-class("RE", "Restriction"),
        ),
      ),
      make-class(
        "S",
        "Software",
        classes: (
          make-class(
            "FN",
            "Functional",
            origins: make-origins(
              [User requirements that derived this requirement.],
              make-tag("R", "U", "CA"),
            ),
          ),
          make-class(
            "NF",
            "Non-functional",
            origins: make-origins(
              [User requirements that derived this requirement.],
              make-tag("R", "U", "RE"),
            ),
          ),
        ),
      ),
    ),
  ),
  make-class(
    "U",
    "Use Case",
    fields: (
      make-field(
        "Name",
        content-field,
        [Brief description of the use case],
      ),
      make-field(
        "Actors",
        content-field,
        [External agent that executes the use case],
      ),
      make-field(
        "Objective",
        content-field,
        [The use case's purpose],
      ),
      make-field(
        "Pre-condition",
        content-field,
        [Conditions that must be fulfilled _before_ executing the use case],
      ),
      make-field(
        "Post-condition",
        content-field,
        [Conditions that must be fulfilled _after_ executing the use case],
      ),
    ),
  ),
  make-class(
    "C",
    "Component",
    fields: (
      make-field(
        "Role",
        content-field,
        [Component's function in the system],
      ),
      make-field(
        "Dependencies",
        content-field,
        [Components that depe],
      ),
      make-field(
        "Description",
        content-field,
        [Explanation of the component's functionality],
      ),
      make-field(
        "Inputs",
        content-field,
        [Component's input data],
      ),
      make-field(
        "Outputs",
        content-field,
        [Component's output data],
      ),
    ),
  ),
  make-class(
    "T",
    "Test",
    fields: (
      make-field(
        "Description",
        content-field,
        [Test description],
      ),
      make-field(
        "Preconditions",
        content-field,
        [Conditions that must be fulfilled in order to perform the test],
      ),
      make-field(
        "Postcondition",
        content-field,
        [Conditions that must be fulfilled after performing the test in order to
          pass],
      ),
      make-field(
        "Evaluation",
        make-enum-field(ok: "OK", err: "Error"),
        [Result of the test],
      ),
    ),
    classes: (
      make-class(
        "VAT",
        "Validation Test",
        origins: make-origins(
          [Requirement that originated this test.],
          make-tag("R", "S", "FN"),
          make-tag("R", "S", "NF"),
        ),
      ),
    ),
  ),
  make-class(
    "VET",
    "Verification Test",
    origins: make-origins(
      [Requirement that originated this test.],
      make-tag("R", "U", "CA"),
      make-tag("R", "U", "RE"),
    ),
  ),
)


/// Simple classes set.
///
/// Includes:
/// - Requirement (R)
///   - User Requirement (U)
///   - Software Requirement (S)
///     - Functional (FN)
///     - Non-Functional (NF)
///
/// -> array
#let simple-classes = (
  make-class(
    "R",
    "Requirements",
    fields: (
      make-field(
        "Description",
        content-field,
        [Detailed description of the requirement],
      ),
    ),
    classes: (
      make-class(
        "U",
        "User",
      ),
      make-class(
        "S",
        "Software",
        classes: (
          make-class(
            "FN",
            "Functional",
            origins: make-origins(
              [User requirements that derived this requirement.],
              make-tag("R", "U"),
            ),
          ),
          make-class(
            "NF",
            "Non-functional",
            origins: make-origins(
              [User requirements that derived this requirement.],
              make-tag("R", "U"),
            ),
          ),
        ),
      ),
    ),
  ),
)
