//! Localization support


#let SUPPORTED-LANGUAGES = ("en", "es")


#let TEMPLATE = (
  en: (name, root-class) => {
    if lower(name).contains(lower(root-class)) {
      ["#name" template]
    } else ["#name" #root-class template]
  },
  es: (name, root-class) => {
    if lower(name).contains(lower(root-class)) {
      [Plantilla de "#name"]
    } else [Plantilla de #root-class "#name"]
  },
)

#let FIELD = (
  en: "Field",
  es: "Campo",
)

#let DESCRIPTION = (
  en: "Description",
  es: "Descripción",
)

#let ORIGINS = (
  en: "Origins",
  es: "Orígenes",
)

#let TRACEABILITY_MATRIX = (
  en: "Traceability Matrix",
  es: "Matriz de Trazabilidad",
)
