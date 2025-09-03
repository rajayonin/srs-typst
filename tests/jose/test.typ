#import "/src/lib.typ" as srs

#let azuluc3m = rgb("#000e78")

#set text(
  lang: "es",
  region: "es",
)

#show ref: set text(azuluc3m)
#show link: set text(azuluc3m)

#set list(marker: ([•], [--]), indent: 1em)

#show figure: set figure.caption(position: top)
#show figure.caption: it => [
  #set text(azuluc3m, weight: "semibold")
  #set par(first-line-indent: 0em, justify: false)
  #context smallcaps(it.supplement)
  #context smallcaps(it.counter.display(it.numbering))
  #set text(black, weight: "regular")
  #set align(center)
  #smallcaps(it.body)
]

#show table: block.with(stroke: (y: 0.7pt))
#set table(
  row-gutter: -0.1em, // Row separation
  stroke: (_, y) => if y == 0 { (bottom: 0.2pt) },
)


#let scale-m-type = srs.make-enum-field(
  h: "Alto",
  m: "Medio",
  l: "Bajo",
)

#let scale-f-type = srs.make-enum-field(
  h: "Alta",
  m: "Media",
  l: "Baja",
)

#let stability-type = srs.make-enum-field(
  c: "Constante",
  i: "Inconstante",
  vu: "Inestable",
)

#let source-type = srs.make-enum-field(
  c: "Cliente",
  a: "Analista",
)

#let reference(id, text) = link(label("srs:" + id), text)

#let config = srs.make-config(
  language: "es",
  template-formatter: srs.defaults.table-template-formatter-maker(
    style: (columns: (8em, 1fr), align: left),
  ),
  item-formatter: srs.defaults.table-item-formatter-maker(
    style: (columns: (8em, 1fr), align: left),
  ),
  traceability-formatter: srs.defaults.table-traceability-formatter-maker(
    style: (row-gutter: 0em),
    rotation-angle: 0deg,
    column_size: 7em,
  ),

  /* *** R e q u i s i t o s *** --------------------------------------- *** */
  classes: (
    srs.make-class(
      "R",
      "Requisito",
      namer: srs.defaults.incremental-namer-maker(
        prefix: (tag, root-class-name, class-name, separator) => {
          tag.join("")
        },
        start: 1,
        width: 2,
      ),
      identifier: srs.defaults.identifier-maker(prefix: none),
      fields: (
        /* Requisito :: Descripción */
        srs.make-field(
          "Descripción",
          srs.content-field,
          [Descripción detallada del requisito],
        ),
        /* Requisito :: Necesidad */
        srs.make-field(
          "Necesidad",
          scale-f-type,
          [Prioridad del requisito para el usuario],
        ),
        /* Requisito :: Prioridad */
        srs.make-field(
          "Prioridad",
          scale-f-type,
          [Prioridad del requisito para el desarrollador],
        ),
        /* Requisito :: Estabilidad */
        srs.make-field(
          "Estabilidad",
          stability-type,
          [Indica la variabilidad del requisito a lo largo del proceso de
            desarrollo.],
        ),
        /* Requisito :: Verificabilidad */
        srs.make-field(
          "Verificabilidad",
          scale-f-type,
          [Capacidad de probar la valided del requisito.],
        ),
        /* Requisito :: Fuente */
        srs.make-field(
          "Fuente",
          source-type,
          [Quién ha propuesto el requisito.],
        ),
      ),
      classes: (
        srs.make-class("F", "Requisito funcionales", origins: srs.make-origins(
          [Caso de uso del que es origen este requisito.],
          srs.make-tag("CU"),
        )),
        srs.make-class("N", "Requisito no funcional", origins: srs.make-origins(
          [Caso de uso del que es origen este requisito.],
          srs.make-tag("CU"),
        )),
      ),
    ),
    /* *** C a s o s   d e   u s o *** ----------------------------------- *** */
    srs.make-class(
      "CU",
      "Caso de uso",
      namer: srs.defaults.field-namer-maker("Nombre"),
      identifier: srs.defaults.identifier-maker(prefix: none),
      fields: (
        /* Caso de uso :: Nombre */
        srs.make-field(
          "Nombre",
          srs.content-field,
          [Nombre del caso de uso, es una acción así que debe empezar con un
            verbo.],
        ),
        /* Caso de uso :: Alcance */
        srs.make-field(
          "Alcance",
          srs.make-enum-field(
            empotrado: [Dispositivo empotrado],
            entrenamiento: [Entrenamiento],
            todo: [Dispositivo empotrado y entrenamiento],
          ),
          [A qué subsistema o subsistemas específicos afecta el mismo. En este
            proyecto se diferencia la fase de entrenamiento del dispositivo
            empotrado con el sistema en tiempo real.],
        ),
        /* Caso de uso :: Nivel */
        srs.make-field(
          "Nivel",
          srs.make-enum-field(
            meta-de-usuario: [Meta de usuario],
            subfunción: [Subfunción],
          ),
          [«Meta de usuario» o «Subfunción». La subfunción se diferencia de la
            meta de usuario en que es un paso intermedio.],
        ),
        /* Caso de uso :: Actores principales */
        srs.make-field(
          "Actores principales",
          srs.content-field,
          [Los agentes que hacen uso de los servicios del sistema para alcanzar
            su objetivo.],
        ),
        /* Caso de uso :: Parte interesada */
        srs.make-field(
          "Parte interesada",
          srs.content-field,
          [Son los actores a quienes les concierne y qué quieren.],
        ),
        /* Caso de uso :: Precondiciones */
        srs.make-field(
          "Precondiciones",
          srs.content-field,
          [Qué debe ser cierto al inicio.],
        ),
        /* Caso de uso :: Postcondiciones */
        srs.make-field(
          "Postcondiciones",
          srs.content-field,
          [Qué se garantiza que es cierto al completar la operación.],
        ),
        /* Caso de uso :: Escenario de éxito principal */
        srs.make-field(
          "Escenario de éxito principal",
          srs.content-field,
          [La descrición de los pasos de las situación más típica.],
        ),
        /* Caso de uso :: Extensiones */
        srs.make-field(
          "Extensiones",
          srs.content-field,
          [Escenarios alternativos y ramificaciones del escenario principal.],
        ),
        /* Caso de uso :: Requisitos especiales */
        srs.make-field(
          "Requisitos especiales",
          srs.content-field,
          [Requisitos no funcionales relacionados.],
        ),
        /* Caso de uso :: Frecuencia con que ocurre */
        srs.make-field(
          "Frecuencia con que ocurre",
          srs.content-field,
          [Cada cuánto tiempo se espera que se utilice el caso de uso.],
        ),
      ),
    ),
    /* *** C o m p o n e n t e s *** ------------------------------------- *** */
    srs.make-class(
      "C",
      "Componente",
      namer: srs.defaults.field-namer-maker("Nombre"),
      identifier: srs.defaults.identifier-maker(prefix: none),
      fields: (
        /* Componente :: Nombre */
        srs.make-field(
          "Nombre",
          srs.content-field,
          [La función del componente en el sistema.],
        ),
        /* Componente :: Rol */
        srs.make-field(
          "Rol",
          srs.content-field,
          [La función del componente en el sistema.],
        ),
        /* Componente :: Dependencias */
        srs.make-field(
          "Dependencias",
          srs.content-field,
          [Componentes que dependen de este.],
        ),
        /* Componente :: Descripción */
        srs.make-field(
          "Descripción",
          srs.content-field,
          [Explicación de la funcionalidad del componente.],
        ),
        /* Componente :: Entradas */
        srs.make-field(
          "Entrada",
          srs.content-field,
          [Datos de entrada del componente.],
        ),
        /* Componente :: Salidas */
        srs.make-field(
          "Salida",
          srs.content-field,
          [Datos de salida del componente.],
        ),
      ),
    ),
    /* *** T e s t s *** ------------------------------------------------- *** */
    srs.make-class(
      "T",
      "Test",
      namer: srs.defaults.incremental-namer-maker(
        prefix: (class, _separator) => { class.tag.join("") },
        start: 1,
        width: 2,
      ),
      identifier: srs.defaults.identifier-maker(prefix: none),
      origins: srs.make-origins(
        [Requisito del que se deriva este _test_.],
        srs.make-tag("R", "F"),
        srs.make-tag("R", "N"),
      ),
      fields: (
        /* Test :: Descripción */
        srs.make-field(
          "Descripción",
          srs.content-field,
          [Descripción del _test_],
        ),
        /* Test :: Precondiciones */
        srs.make-field(
          "Precondiciones",
          srs.content-field,
          [Condiciones que deben cumplirse antes de ejecutar la prueba.],
        ),
        /* Test :: Postcondiciones */
        srs.make-field(
          "Postcondiciones",
          srs.content-field,
          [Condiciones que deben cumplirse después de ejecutar la prueba.],
        ),
        /* Test :: Evaluación */
        srs.make-field(
          "Evaluación",
          srs.make-enum-field(ok: "Correcta", err: "Errónea"),
          [Resultado de la prueba],
        ),
      ),
    ),
  ),
)



#let make-item(id, class, origins: (), fields) = {
  srs.make-item(id, class, origins: origins, ..fields)
}

#let reqs = srs.create(
  config: config,

  /* *** C a s o s   d e   u s o *** ----------------------------------- *** */

  // Caso de uso : Leer señal de encefalograma
  make-item("uc-sample", srs.make-tag("CU"), (
    Nombre: [Leer señal de encefalograma],
    Alcance: "empotrado",
    Nivel: "subfunción",
    "Actores principales": [],
    "Parte interesada": [
      - Paciente: Quiere que la señal de encefalograma para detectar un posible
        ataque epiléptico sea continua y no se detenga bajo ningún concepto.
      - Doctor: Quiere poder utilizar tanto señales reales como señales
        pregrabadas como señales sintéticas para hacer estudios y entrenar el
        modelo.
    ],
    Precondiciones: [
      El sensor tiene alimentación y se ha activado por _software_.],
    Postcondiciones: [
      El resultado es un valor real que está dentro de un rango válido.],
    "Escenario de éxito principal": [
      1. El sensor mide un valor analógico en bruto en un instante.
      2. El sensor convierte dicho valor a otro con las unidades esperadas.
      3. El sensor escribe el valor en la señal.
    ],
    Extensiones: [
      1. Desconexión del sensor
        1. El sensor notifica al paciente
        2. El sensor escribe el valor máximo del rango válido, para no detener
          el sistema ni dejar esperando al resto de actores.
      2. Si el valor después de convertirlo fuera mayor que el límite superior
        del rango válido.
        1. El sensor escribe un _log_.
        2. El sensor escribe el valor máximo del rango válido y continúa con la
          operación.
      3. Si el valor después de convertirlo fuera menor que el límite inferior
        del rango válido.
        1. El sensor escribe un _log_.
        2. El sensor escribe el valor mínimo del rango válido y continúa con la
          operación.
    ],
    "Requisitos especiales": [
      - Debe leer 256 muestras por segundo.
      - Debe leer a un ritmo constante.
      - Los valores leídos deben estar en un rango válido.
    ],
    "Frecuencia con que ocurre": [Continuo],
  )),

  // Caso de uso : Detectar ataque
  make-item("uc-detect", srs.make-tag("CU"), (
    Nombre: [Detectar ataque],
    Alcance: "todo",
    Nivel: "meta-de-usuario",
    "Actores principales": [Paciente],
    "Parte interesada": [
      - Detector: Quiere clasificar las distintas épocas de la señal para
        entrenar el modelo o hacer estudios..
      - Paciente: Quiere saber si está teniendo un ataque epiléptico.
    ],
    Precondiciones: [
      El modelo debe estar cargado, y el sensor debe estar activo.],
    Postcondiciones: [Ninguna],
    "Escenario de éxito principal": [
      1. El detector espera a tener una época de señal del sensor.
      2. El detector pasa un filtro de paso bajo y paso alto a la época.
      3. El detector decide que la época no es un artefacto (pestañeo, ...).
      4. El detector computa las características de la señal (`max_distance`,
        ...).
      5. El detector computa la distancia entre la época y cada uno de los
        patrones.
      6. Retorna que es un ataque epiléptico.
    ],
    Extensiones: [
      1. En el paso 3., si se trata de un artefacto.
        1. Como es un artefacto, no hace falta continuar, retorna que no es un
          ataque.
      2. En el paso 4. si para alguna de las características el valor cae fuera
        de los rangos definidos por el modelo (_batch_).
        1. No es un ataque epiléptico, retorna que no lo es.
      3. En el paso 5. si para ninguno de los patrones la distancia es lo
        suficientemente pequeña (determinada por el modelo).
        1. No es un ataque epiléptico, lo retorna.
    ],
    "Requisitos especiales": [
      - Debe procesar una época y compararla hasta con tres patrones por
        segundo.
    ],
    "Frecuencia con que ocurre": [Cotinua (una vez por segundo)],
  )),

  // Caso de uso : Entrenar modelo
  make-item("uc-train", srs.make-tag("CU"), (
    Nombre: [Entrenar el modelo],
    Alcance: "entrenamiento",
    Nivel: "meta-de-usuario",
    "Actores principales": [Doctor],
    "Parte interesada": [
      - Doctor: Quiere obtener el modelo y su eficacia.
      - Paciente: Quiere un modelo eficaz para detectar sus posibles ataques
        epilépticos.
    ],
    Precondiciones: [
      Una señal continua con los intervalos de ataque epiléptico etiquetados.],
    Postcondiciones: [
      Un modelo válido con los rangos de características de la señal y los
      patrones de la propia señal que optimicen la puntuación $F_1$ del sistema.
      Además de la precisión, la sensibilidad y su puntuación $F_1$.],
    "Escenario de éxito principal": [
      1. El doctor graba la señal de un paciente durante un periodo largo de
        tiempo.
      2. El doctor etiqueta los intervalos de la propia señal en los que está
        ocurriendo un ataque.
      3. El sensor pasa un filtro de paso bajo y paso alto a la señal.
      4. El detector marca en la señal las secciones con artefactos.
      5. El optimizador (externo) toma el detector y optimiza los parámetros del
        modelo para maximizar la puntuación $F_1$.
      6. El optimizador retorna el modelo preparado en un archivo.
    ],
    Extensiones: [
      1. Puntuación $F_1$ baja.
        1. El doctor estudiará por qué ocurre.
        2. El doctor reconfigura el optimizador y vuelve a intentar generar el
          modelo.
    ],
    "Requisitos especiales": [
      - La puntuación $F_1$ debe ser superior al $99%$.
      - Debe haber una interfaz compatible con la implementación de referencia.
      - Los resultados deben asemejarse a los de la implementación de
        referencia.
    ],
    "Frecuencia con que ocurre": [
      Escasa: el modelo se entrene una sola vez por paciente y tarda mucho en
      hacerlo],
  )),


  /* *** R e q u i s i t o s *** --------------------------------------- *** */

  /* *** Requisitos funcionales ---------------------------------------- *** */


  make-item(
    "rf-binding",
    srs.make-tag("R", "F"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe existir una interfaz con Python 3 (_binding_) en forma de módulo,
        que se integre con la base de código antigua y permita entrenar el
        modelo],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rf-classify",
    srs.make-tag("R", "F"),
    origins: (srs.make-tag("CU", "uc-detect"),),
    (
      Descripción: [
        El sistema debe clasificar una época dada en ataque o no ataque.
      ],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "c",
      Verificabilidad: "l",
      Fuente: "c",
    ),
  ),

  make-item(
    "rf-notify",
    srs.make-tag("R", "F"),
    origins: (srs.make-tag("CU", "uc-detect"),),
    (
      Descripción: [
        El sistema debe notificar al paciente si está teniendo un ataque
        epiléptico.
      ],
      Necesidad: "m",
      Prioridad: "h",
      Estabilidad: "c",
      Verificabilidad: "m",
      Fuente: "a",
    ),
  ),

  make-item(
    "rf-read",
    srs.make-tag("R", "F"),
    origins: (srs.make-tag("CU", "uc-sample"),),
    (
      Descripción: [
        El sistema debe leer señales de encefalograma de un lector de señales de
        encefalograma.
      ],
      Necesidad: "l",
      Prioridad: "l",
      Estabilidad: "i",
      Verificabilidad: "l",
      Fuente: "a",
    ),
  ),

  make-item(
    "rf-replicate",
    srs.make-tag("R", "F"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        El sistema debe tener el mismo compotamiento que la implementación de
        referencia.
      ],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  /* *** Requisitos NO funcionales (Restricciones) --------------------- *** */

  make-item(
    "rnf-muestras-por-segundo",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-sample"),),
    (
      Descripción: [
        El sensor de encefalograma en el dispositivo empotrado debe leer a razón
        de 256 muestras por segundo.],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "i",
      Verificabilidad: "m",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-ritmo-de-muestreo",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-sample"),),
    (
      Descripción: [
        El sensor debe leer muestras a un ritmo constante, es decir],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "i",
      Verificabilidad: "m",
      Fuente: "a",
    ),
  ),

  make-item(
    "rnf-épocas-por-segundo",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-detect"),),
    (
      Descripción: [
        El detector de encefalograma deberá procesar como mínimo una época de
        1280 muestras por segundo en el peor de los casos.],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "i",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-no-fallo",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-sample"), srs.make-tag("CU", "uc-detect")),
    (
      Descripción: [
        El sistema no puede terminar de forma abrupta bajo ningún concepto.],
      Necesidad: "l",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "m",
      Fuente: "a",
    ),
  ),

  make-item(
    "rnf-f1",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        La puntuación $F_1$ o _$F_1$ score_ para un modelo entrenado debe ser
        superior al $99%$ y se calcula como:
        $F_1 = (2 dot.c "PRE" dot.c "SEN")/("PRE" + "SEN")$, donde
        $"SEN" = "TP"/("TP"+"FN")$ y $"PRE" = "TP"/("TP"+"FP")$. Donde _TP_ son
        los verdaderos positivos; _FN_, los falsos negativos; y _FP_, los falsos
        positivos.],
      Necesidad: "l",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "l",
      Fuente: "a",
    ),
  ),

  make-item(
    "rnf-max-distance-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $10^(-6)$ en la función
        `max_distance` con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-energy-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $10^(-6)$ en la función
        `energy` con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-dtw-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $10^(-3)$ en la función
        `dtw` con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-psd-1-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $0.5$ en la función `PSD 1`
        con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-psd-2-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $0.5$ en la función `PSD 2`
        con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-psd-3-error",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-train"),),
    (
      Descripción: [
        Debe haber un error medio absoluto de máximo $0.5$ en la función `PSD 3`
        con respecto a la implementación original en Python 3.
      ],
      Necesidad: "m",
      Prioridad: "l",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-better",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-detect"),),
    (
      Descripción: [
        El sistema debe detectar más rápido un ataque epiléptico que la
        implementación de referencia, comparado en el mismo dispositivo.
      ],
      Necesidad: "h",
      Prioridad: "h",
      Estabilidad: "c",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  make-item(
    "rnf-embed",
    srs.make-tag("R", "N"),
    origins: (srs.make-tag("CU", "uc-detect"), srs.make-tag("CU", "uc-sample")),
    (
      Descripción: [
        El sistema debe funcionar en un dispositivo empotrado de bajo consumo.
        Preferiblemente con un procesador RISC-V como el ESP32C3 o el ESP32C6.
      ],
      Necesidad: "h",
      Prioridad: "m",
      Estabilidad: "vu",
      Verificabilidad: "h",
      Fuente: "c",
    ),
  ),

  /* *** C o m p o n e n t e s *** ------------------------------------- *** */

  make-item("c-validador", srs.make-tag("C"), (
    Nombre: [Validador],
    Rol: [Dado un modelo computa su puntuación $F_1$.],
    Descripción: [
      Este componente lo que hace es ejecutar el modelo junto a un conjunto de
      prueba para obtener la puntuación $F_1$ que nos da cómo de bueno es el
      propio modelo.
    ],
    Dependencias: [
      #reference("c-detector", [Detector])
    ],
    Entrada: [
      - Detección: Utiliza las detecciones generadas por el #reference(
          "c-detector",
          [detector],
        ) computar la puntuación $F_1$.
    ],
    Salida: [
      - Puntuación $F_1$ del modelo.
    ],
  )),

  make-item("c-entrenador", srs.make-tag("C"), (
    Nombre: [Entrenador],
    Rol: [Entrenar el modelo para un paciente],
    Descripción: [
      El componente genera múltiples modelos (_batches_) y los valida contra el
      #reference("c-validador", [validador]), el cual utiliza para optimizar la
      puntuación $F_1$ del modelo resultante.
    ],
    Dependencias: [#reference("c-validador", [Validador])],
    Entrada: [
      - Los datos del paciente.
    ],
    Salida: [
      - Un _batch_ o modelo.
    ],
  )),

  make-item("c-detector", srs.make-tag("C"), (
    Nombre: [Detector],
    Rol: [Clasificar una época de señal.],
    Descripción: [
      A partir de un modelo generado (_batch_), clasifica épocas de señal en dos
      categorías: «zona libre de ataque epiléptico» y en «zona con ataque
      epiléptico».
    ],
    Dependencias: [#reference("c-lector", [Lector])],
    Entrada: [
      - _Batch_: o modelo generado.
      - Señal: generada por el #reference("c-lector", [lector]).
    ],
    Salida: [
      - Clasificación de cada época de la señal.
    ],
  )),

  make-item("c-lector", srs.make-tag("C"), (
    Nombre: [Lector],
    Rol: [Leer muestras de encefalograma.],
    Descripción: [
      Leer de manera continua, constante e ininterrumpida muestras de señal de
      encefalogramo de un sensor.
    ],
    Dependencias: [_Ninguna_],
    Entrada: [_Ninguna_],
    Salida: [
      - Señal leída.
    ],
  )),

  /* *** T e s t s *** ------------------------------------------------- *** */

  /*

  make-item("t-", srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", ""),
              srs.make-tag("R", "F", "")),
  (
    Descripción: [
    ],
    Precondiciones: [
    ],
    Postcondiciones: [
    ],
    Evaluación: "ok/err",
  )),

  */

  make-item(
    "t-python3-module",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "F", "rf-binding"),),
    (
      Descripción: [La interfaz de Python 3 funciona.],
      Precondiciones: [
        1. Existe un fichero `.so` en Linux, `.dll` en Windows, con el nombre
          del módulo `seizures`.
        2. El comando `ldd` muestra que está enlazado con la biblioteca estándar
          de Python con misma versión que el intérprete en uso.
        3. Desde la consola interactiva de Python 3, ejecutar `import seizures`
      ],
      Postcondiciones: [
        El intérprete de Python 3 no termina inesperadamente y se puede acceder
        a todas las funciones definidas desde #box([C++]), todas ellas con el
        mismo nombre que la implementación de referencia en Python 3.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-classify-true",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "F", "rf-classify"),
      srs.make-tag("R", "F", "rf-notify"),
    ),
    (
      Descripción: [El detector identifica ataques.],
      Precondiciones: [
        1. Se utiliza una señal sintética de 1280.
        2. Se generan un _batch_ específico para dicha época. Donde las
          características sean las características de las señal sintética y el
          patrón sea la propia señal.
        3. Se ejecuta el algoritmo con el _batch_ generado y la señal sintética.
      ],
      Postcondiciones: [
        La distancia utilizando el algortimo de deformación dinámica del tiempo
        debe dar una distancia cercana a 0. Y todas las características son las
        mismas que las del _batch_, así que están todas en rango. El detector
        debe notificar de que hay un ataque.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-classify-false-feature",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "F", "rf-classify"),
      srs.make-tag("R", "F", "rf-notify"),
    ),
    (
      Descripción: [El detector identifica que no es un ataque por las
        características.],
      Precondiciones: [
        1. Se utiliza una señal sintética de 1280.
        2. Se genera un _batch_ con patrón idéntico a la señal sintética. Los
          rangos de las características serán $[0, infinity)$.
        3. Para cada una de las características se cambia el rango a $[0, 0)$ y
          a $[0, x)$, donde $x$ es el valor computado de la característica de la
          señal sintética. Y se ejecuta el algoritmo con la misma señal
          sintética.
      ],
      Postcondiciones: [
        La distancia debe estar cerca de 0, pues es la misma señal. Para cada
        una de las características $[0, 0)$ es un rango vacío, así que como no
        está en el rango no debería notificar de que hay ataque. De la misma
        manera, cuando es $[0, x)$, tampoco debería notificar de que hay ataque
        porque $x in.not [0, x)$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-classify-false-dtw",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "F", "rf-classify"),
      srs.make-tag("R", "F", "rf-notify"),
    ),
    (
      Descripción: [El detector identifica que no es atauqe por el patrón.],
      Precondiciones: [
        1. Se genera un _batch_ con todas las características en el rango
          $[0, infinity)$. Y como patrón una señal sintética sintética de 1280
          muestras.
        2. A continuación se genera una nueva señal sintética de 1280 muestras y
          se computa su deformación dinámica del tiempo (DTW) contra la señal
          sintética generada en el paso anterior (la del patrón).
        3. Se utiliza el detector con la segunda señal sintética con dos rangos
          para el valor DTW del _batch_: $[0, 0)$ y $[0, x)$ donde x es el valor
          computado.
      ],
      Postcondiciones: [
        No hay ataque, así que no lo notifica. El caso para el intervalo vacío
        $[0, 0)$ siempre debe dar falso, y como el intervalo $[0, x)$ es
        abierto, nunca lo detecta como ataque.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-classify-true-many-patterns",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "F", "rf-classify"),
      srs.make-tag("R", "F", "rf-notify"),
    ),
    (
      Descripción: [El detector identifica ataques.],
      Precondiciones: [
        1. Se generan $n$ muestras sintéticas.
        2. Se genera un _batch_ con las $n$ muestras sintéticas como patrones.
          Las características son los rangos $[0, x]$ donde $x$ es el mayor
          valor computado para cada una de las características de cada una de
          las muestras sintéticas.
        3. Se ejecuta el algoritmo para cada muestra sintética.
      ],
      Postcondiciones: [
        Notifica de que hay ataque en todas y cada una de ellas. La distancia de
        cada una de los patrones a sí mismo tiende a cero. Además no se descarta
        ningún patrón porque la característica máxima del rango, también es la
        mayor de dicha característica para cada uno de los patrones.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-read",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "F", "rf-read"),),
    (
      Descripción: [Leer de un sensor de encefalograma],
      Precondiciones: [
        1. Conectar el sensor un pin de la placa.
      ],
      Postcondiciones: [
        Debe mostrar los valores leídos.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-muestras-por-segundo",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "N", "rnf-muestras-por-segundo"),
      srs.make-tag("R", "N", "rnf-ritmo-de-muestreo"),
    ),
    (
      Descripción: [El sensor lee a razón de 256 muestras por segundo],
      Precondiciones: [
        1. El sensor está conectado.
        2. Esperar a que pase un segundo
        3. Comprobar cuántas muestras a leído y cada cuánto
      ],
      Postcondiciones: [
        El sensor debe haber leído un total de 256 muestras cada segundo, a una
        muestra por cada una ducentésima quincuagésima sexta parte de un
        segundo.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-épocas-por-segundo",
    srs.make-tag("T"),
    origins: (
      srs.make-tag("R", "N", "rnf-épocas-por-segundo"),
      srs.make-tag("R", "N", "rnf-better"),
    ),
    (
      Descripción: [El sensor procesa como mínimo una época por segundo],
      Precondiciones: [
        1. Generar una señal sintética de un $x dot.c 256, x >= 5$ muestras.
        2. Generar un _batch_ con todas las características en el rango
          $[0, infinity)$, con tres patrones y con las distancias de la
          deformación dinámica del tiempo (DTW) en el rango $[0, 0)$.
        3. Ejecutar el algoritmo de detección con dicha señal y dicho _batch_.
        4. Comprobar cuánto tarda la época más lenta.
      ],
      Postcondiciones: [
        Es el peor caso, pues como todas las características tienen un rango
        $[0, infinity)$ tiene que computarlas todas, los patrones tiene que
        compararlos todos también porque ninguno está en rango (para que sea un
        ataque alguno debe estar en rango). El tiempo total debe ser menor de un
        segundo por época.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-no-fallo",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-no-fallo"),),
    (
      Descripción: [El programa no puede terminar de manera abrupta.],
      Precondiciones: [
        1. El programa escrito en SPARK y Ada compila.
      ],
      Postcondiciones: [
        Si compila tenemos la certeza de que no puede saltar ninguna excepción
        en tiempo de ejecución, porque el probador de teoremas nos garantiza
        ausencia de excepciones en tiempo de ejecución.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-max-distance-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-max-distance-error"),),
    (
      Descripción: [El error medio absoluto de la `max_distance` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `max_distance` para
          cada época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de
        `max_distance` es $5.25 dot.c 10^(−7) < 10^(-6)$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-energy-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-energy-error"),),
    (
      Descripción: [El error medio absoluto de la `energy` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `energy` para cada
          época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de
        `energy` es $3.21 dot.c 10^(−8) < 10^(-6)$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-dtw-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-dtw-error"),),
    (
      Descripción: [El error medio absoluto de la `dtw` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `dtw` para cada
          época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de `dtw`
        es $2.3 dot.c 10^(−4) < 10^(-3)$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-psd-1-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-psd-1-error"),),
    (
      Descripción: [El error medio absoluto de la `PSD 1` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `PSD 1` para cada
          época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de
        `PSD 1` es $0.34 < 0.5$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-psd-2-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-psd-2-error"),),
    (
      Descripción: [El error medio absoluto de la `PSD 2` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `PSD 2` para cada
          época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de
        `PSD 2` es $0.16 < 0.5$.
      ],
      Evaluación: "ok",
    ),
  ),

  make-item(
    "t-psd-3-error",
    srs.make-tag("T"),
    origins: (srs.make-tag("R", "N", "rnf-psd-3-error"),),
    (
      Descripción: [El error medio absoluto de la `PSD 3` es aceptable],
      Precondiciones: [
        1. Para una señal sintética lo suficientemente larga.
        2. Utilizar la versión de referencia para computar `PSD 3` para cada
          época.
      ],
      Postcondiciones: [
        De acuerdo con los resultado para uno de los pacientes el error de
        `PSD 3` es $0.42 < 0.5$.
      ],
      Evaluación: "ok",
    ),
  ),
)


#srs.show-template(reqs, srs.make-tag("CU"), "cu-template")
@srs:cu-template

#srs.show-items(
  reqs,
  srs.make-tag("CU"),
  // custom formatter bc use cases are ✨special✨
  formatter: srs.defaults.table-item-formatter-maker(
    style: (columns: (8em, 1fr), align: left),
    breakable: true,
  ),
)
@srs:uc-detect

#srs.show-template(reqs, srs.make-tag("R", "F"), "rf-template")
@srs:rf-template

#srs.show-items(reqs, srs.make-tag("R", "F"))
@srs:rf-binding


=== Requisitos no funcionales
#srs.show-template(reqs, srs.make-tag("R", "N"), "rnf-template")
@srs:rnf-template

#srs.show-items(reqs, srs.make-tag("R", "N"))
@srs:rnf-better


#srs.show-template(reqs, srs.make-tag("C"), "comp-template")
@srs:comp-template

#srs.show-items(
  reqs,
  srs.make-tag("C"),
  formatter: srs.defaults.table-item-formatter-maker(
    style: (columns: (8em, 1fr), align: left),
    breakable: false,
  ),
)
@srs:c-detector

#srs.show-traceability(reqs, srs.make-tag("R", "N"))

#srs.show-traceability(reqs, srs.make-tag("R", "F"))
