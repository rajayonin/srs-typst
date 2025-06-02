//! Functions for creating and managing the configuration of the package



/// Validates a class object.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - class (dictionary): Class to validate.
/// - config (dictionary): Configuration object tree.
/// -> array
#let _validate-class(class, config) = {
  // check object format (duck typing)

  if (
    (type(class) != dictionary)
      or class.keys()
        != (
          "id",
          "name",
          "classes",
          "fields",
          "origins",
        )
  ) {
    return (
      false,
      "Invalid class: Invalid format. Please make sure to use #make-class.",
    )
  }

  if type(class.id) != str {
    return (
      false,
      "Invalid class: Invalid format. `id` is not a string.",
    )
  }

  if type(class.name) != str {
    return (
      false,
      "Invalid class '" + class.id + "': Invalid format. `name` is not a string.",
    )
  }

  if type(class.classes) != array {
    return (
      false,
      "Invalid class '" + class.id + "': Invalid format. `classes` is not an array.",
    )
  }

  if type(class.fields) != array {
    return (
      false,
      "Invalid class '" + class.id + "': Invalid format. `fields` is not an array.",
    )
  }

  if type(class.origins) != dictionary {
    return (false, "Invalid class '" + class.id + "': Invalid format. `origins` is not a dictionary.")
  }


  // TODO: check duplicates

  // check origins
  if class.origins.len() > 0 {
    // we won't check if it's a non-terminal class w/ origins bc we already do
    // that in `make-class`

    // check origin classes exist
    for origin in class.origins.tags {
      // traverse the tree looking for it
      let current = config
      for (i, class_id) in origin.enumerate() {
        current = current.classes.find(class => class.id == class_id)
        if current == none {
          return (
            false,
            "Invalid class '" + class.id + "'. Origin class '" + origin.join("-") + "' not found.",
          )
        }
      }
    }
  }


  // check subclasses
  for c in class.classes {
    let (ok, err) = _validate-class(c, config)
    if not ok { return (false, err) }
  }

  return (true, none)
}


/// Validates the configuration object.
///
/// It returns a result. That is, a pair `(ok, err)` where `ok` is the result of
/// the operation and `err` is the error message in case of error.
///
/// - config (dictionary): Configuration object. Generate it using `make-field`.
/// -> array
#let validate-config(
  config,
) = {
  // validate classes
  for class in config.classes {
    let (ok, err) = _validate-class(class, config)
    if not ok { return (false, err) }
  }

  return (true, none)
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
/// make-enum-field(
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
) = {
  assert(
    path.pos().all(t => type(t) == str),
    message: "Invalid format. Identifiers are not strings.",
  )

  return path.pos()
}



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
  origins: (:),
) = {
  // parameter validation
  assert(type(id) == str, message: "Invalid format. `id` is not a string.")
  assert(type(name) == str, message: "Invalid format. `name` is not a string.")
  assert(type(fields) == array, message: "Invalid format. `fields` is not an array.")
  assert(type(classes) == array, message: "Invalid format. `classes` is not an array.")

  // check origins
  assert(
    (type(origins) == dictionary)
      and (
        origins.len() == 0 or (origins.keys() == ("description", "tags"))
      ),
    message: "Invalid origins format. Please make sure to use #make-origins.",
  )

  assert(
    not (origins.len() > 0 and classes.len() > 0),
    message: "A class with sub-classes cannot have origins.",
  )

  (
    id: id,
    name: name,
    classes: classes,
    fields: fields,
    origins: origins,
  )
}


/// Generates a class field.
///
/// - name (str): Field name.
/// - value (dictionary, str): Field values. Can be either an enumeration (`enum-field`) or content (`content-field`).
/// - description (content): Field description.
/// -> dictionary
#let make-field(
  name,
  value,
  description,
) = {
  // parameter validation
  assert(type(name) == str, message: "Invalid format. `name` is not a string.")
  assert(type(description) == content, message: "Invalid format. `description` is not content.")
  assert(
    type(value) == dictionary or value == content-field,
    message: "Invalid format of `value`. Please use `make-enum-field` or `content-field`.",
  )

  return (
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
) = {
  // parameter validation
  assert(type(description) == content, message: "Invalid format. `description` is not content.")
  for (i, tag) in tags.pos().enumerate() {
    assert(type(tag) == array, message: "Invalid tag format. Tag " + str(i) + " is not an array.")
    for c in tag {
      assert(type(c) == str, message: "Invalid tag format. Tag " + str(i) + " is not a valid tag.")
    }
  }

  return (
    description: description,
    tags: tags.pos(),
  )
}
