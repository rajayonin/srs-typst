//! Localization support


#let SUPPORTED-LANGUAGES = ("en", "es")


/* FORMATTERS */

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



/* CLASSES */

#let base-classes = (
  R: (
    name: (en: "Requirement", es: "Requisito"),
    fields: (
      description: (
        name: (en: "Description", es: "Descripción"),
        description: (
          en: [Detailed description of the requirement],
          es: [Especificación del requisito en un lenguaje claro, conciso y no
            ambiguo.],
        ),
      ),
      necessity: (
        name: (en: "Necessity", es: "Necesidad"),
        description: (
          en: [Priority of the requirement of the user],
          es: [Prioridad del requisito para el usuario],
        ),
      ),
      priority: (
        name: (en: "Priority", es: "Prioridad"),
        description: (
          en: [Priority of the requirement for the developer],
          es: [Prioridad del requisito para el desarrollador],
        ),
      ),
      stability: (
        name: (en: "Stability", es: "Estabilidad"),
        description: (
          en: [Indicates the requirement's variability through the development
            process],
          es: [Indica si el requisito se modifica durante el desarrollo],
        ),
      ),
      verifiability: (
        name: (en: "Verifiability", es: "Verificabilidad"),
        description: (
          en: [Ability to test the vailidity of the requirement],
          es: [Capacidad de comprobar la validez del requisito],
        ),
      ),
    ),
  ),
)
