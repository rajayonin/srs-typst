//! Functions for creating and managing the configuration of the package


/// Validates the configuration object.
/// Returns `true` if valid, else `false`
///
/// - config (dictionary): Configuration object. Generate it using `make-field`.
/// -> bool
#let validate-config(
  config,
) = {
  // TODO: validate object syntax

  // TODO: validate origins exist

  true
}

/// Creates a configuration object from SRS classes.
///
/// Each class must be generated using `make-class`.
/// -> dictionary
#let make-config(
  ..classes,
) = (
  classes: classes.pos(),
)


/// Encapsulates an enum field.
/// These fields will receive a key as a value, and print its related value.
///
/// *Example:*
/// ```
/// make-enum-type(
///   h: "High",
///   m: "Medium",
///   l: "Low",
/// )
/// ```
/// -> dictionary
#let make-enum-field(
  ..values,
) = { return values.named() }



/// Encapsulates a content field.
/// These fields will receive a `content` object as a value.
/// -> str
#let content-field = "content"


/// An unique identifier of an item and/or class, composed of its class path.
///
/// Each class is specified by the its ID.
///
/// *Example:*
/// ```
/// make-tag("R", "U", "CA")
/// ```
/// -> array
#let make-tag(
  ..path,
) = path.pos()



/// Generates a class.
///
/// - id (str): Class short identifier. Typically the first letter of the name, e.g. `"R"`.
/// - name (str): Class name.
/// - fields (dictionary): Set of fields that apply to the class. Generate them using `make-field`.
/// - classes (dictionary): sub-classes belonging to this class. Fields belonging to this class are inherited by classes. Generate them using `make-class`.
/// - origins (dictionary): List of classes that are the origin to this class. Note that *only* a "terminal class", that is, a *class without classes* can have origins. Generate them using `make-origins`.
/// -> dictionary
#let make-class(
  id,
  name,
  fields: (),
  classes: (),
  origins: (),
) = {
  // TODO: more parameter validation
  assert(
    not (origins.len() > 0 and classes.len() > 0),
    message: "A class with sub-classes cannot have origins.",
  )

  (
    id: id,
    name: name,
    classes: classes,
    fields: fields,
    origins: origins
  )
}


/// Generates a class field.
///
/// - name (str): Field name.
/// - value (dictionary, str): Field values. Can be either an enumeration (`enum-type`) or content (`content-type`).
/// - description (content): Field description.
/// -> dictionary
#let make-field(
  name,
  value,
  description,
) = {
  // TODO: parameter validation

  // TODO: for enumerated value types, re-generate the description to include
  //       the possible values and add a period at the end

  (
    name: name,
    description: description,
    value: value,
  )
}


/// Generates an origins object.
///
/// Each origin is an array of `tag`s. Generate them with `make-tag`.
///
/// - description (content): Description, or justification of the origins.
/// -> dictionary
#let make-origins(
  description,
  ..tags,
) = (
  description: description,
  tags: tags.pos(),
)
