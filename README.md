Informe Técnico: Herramienta de Análisis Estructural de Vigas

1.	TÍTULO - GRUPO

Proyecto: Herramienta de Análisis Estructural de Vigas

Entorno de Desarrollo: MATLAB (Scripting modular y persistencia de datos .mat)

Integrantes del Grupo: Juan Martín Trujillo – Carlos Andrés Muñoz 

2.	DESCRIPCIÓN DEL PROYECTO

Este proyecto consiste en una aplicación interactiva desarrollada en MATLAB concebida para el análisis numérico y mecánico de vigas simplemente apoyadas. El sistema integra de extremo a extremo la gestión de datos, el cálculo analítico estático y la visualización gráfica avanzada.

La arquitectura general de la aplicación se encuentra organizada en cuatro módulos fundamentales encadenados mediante un flujo persistente controlado por un bucle while true. Esta estructura permite a ingenieros y estudiantes evaluar de forma consecutiva múltiples configuraciones de carga sin perder el estado del programa. Las características principales incluyen una base de datos externa en formato binario (.mat), un menú de consola intuitivo estructurado con bifurcaciones switch-case, y rutinas automáticas optimizadas para trazar con absoluta precisión los diagramas estructurales.

3.	JUSTIFICACIÓN

En la práctica de la ingeniería estructural, la evaluación rápida de vigas bajo múltiples sistemas de cargas es indispensable en las etapas de pre-diseño. El desarrollo de esta herramienta se justifica por la necesidad de automatizar los procesos de cálculo manual repetitivo, reduciendo la probabilidad de errores en la integración de diagramas mecánicos y optimizando los tiempos de análisis.

A diferencia de los scripts convencionales que borran los datos al finalizar el proceso, esta aplicación implementa un almacenamiento binario dinámico a través del archivo vigasDB.mat. La persistencia de datos garantiza que las simulaciones se guarden, consulten o eliminen de forma segura entre sesiones, proveyendo un entorno robusto y escalable. Además, se identifica y soluciona el error conocido como INPUT from EVALC, instruyendo la ejecución directa en consola o en el editor para blindar la estabilidad del flujo de trabajo.
 
4.	DESARROLLO

El núcleo del programa se divide en cuatro grandes bloques funcionales conectados lógica y operativamente:

Módulo de Base de Datos e Inicialización: Al iniciar, el programa emplea la función isfile para comprobar la existencia del archivo indexado. Si no existe, inicializa una estructura vacía mediante la instrucción struct('id', {}, 'longitud', {}, 'cargas_puntuales', {}, 'cargas_distribuidas', {}). En caso de existir, invoca load para recuperar las simulaciones previas de forma transparente.

Módulo 1 — Crear Nueva Simulación: Recoge los datos geométricos de la viga y sus solicitaciones mediante solicitudes por consola (input). Las cargas puntuales se definen matricialmente en formato [posición, magnitud] y las distribuidas como [x_1, x_2, q]. Genera de forma automatizada un identificador único consecutivo evaluando si la base de datos está vacía (newID = 1) o tomando el ID final e incrementándolo (newID = vigas(end).id + 1), guardando el resultado en disco de inmediato.

Módulo 2 — Analizar Simulación Guardada: Valida la existencia de datos mediante isempty. Posteriormente, recorre y lista las simulaciones vigentes formateando las matrices de cargas con la función mat2str. Una vez que el usuario selecciona un ID válido, se efectúa un indexado lógico para extraer las variables mecánicas (selData = vigas([vigas.id] == id_sel)).

Cálculo de Reacciones en Apoyos
El módulo de análisis aplica con rigor las ecuaciones fundamentales del equilibrio estático de la mecánica de sólidos:

ΣF_y = 0	y	ΣM_A = 0

Para procesar las fuerzas, el algoritmo itera acumulativamente:

•	Cargas Puntuales: Valida las dimensiones de la matriz y acumula las magnitudes a la fuerza total (F_{total}) y los momentos asociados (P · x) con respecto al nodo de apoyo izquierdo A.

•	Cargas Distribuidas: Calcula la fuerza equivalente para cada tramo definido entre a y b mediante la relación de área F_d = q · (b - a), localizando su centroide de acción en x_{eq} = a + (b - a)/2 para sumarlo al equilibrio general de momentos.

Finalmente, despeja de forma analítica el valor de las reacciones: R_B = M_A / L y R_A = -F_{total} - R_B, imprimiendo los resultados en pantalla con un formato riguroso de dos decimales (fprintf).
 
Generación Automática de Diagramas Estructurales

Para construir las funciones de distribución interna, la longitud de la viga se discretiza en 500 puntos empleando linspace(0, L, 500). Las funciones vectoriales de Cortante (V(x)) y Momento Flector (M(x)) se evalúan punto a punto por el principio de superposición:

•	Fuerza Cortante V(x): Inicia con el valor de la reacción R_A y resta sucesivamente el valor de las cargas puntuales superadas en la coordenada analizada (x_i \ge posición). En las cargas distribuidas, se deduce la porción de carga activa 
q · (x_i - a) si el punto se encuentra dentro del tramo cargado, o el total q · (b - a) si la coordenada ya rebasó el límite superior.

•	Momento Flector M(x): Integra directamente el comportamiento del cortante evaluando las expresiones algebraicas acumuladas. Se suma la contribución lineal del apoyo R_A · x_i, el efecto de los momentos puntuales P · (x_i - x), y el aporte parabólico de tramos distribuidos, calculado como q · (x_i - a)^2 / 2 en el interior de la franja y q · (b - a) · (x_i - x_{centroide}) en las zonas exteriores.

Módulo 3 — Borrar Simulación: Diseñado para purgar registros obsoletos mediante indexado lógico vacío (vigas([vigas.id] == id_del) = []). Inmediatamente después del borrado, el sistema ejecuta un bucle iterativo que renumera consecutivamente todos los IDs restantes desde 1 hasta la longitud actual del arreglo, mitigando inconsistencias e indexaciones erróneas antes de sobreescribir el disco con save.

5.	RESULTADOS

La herramienta genera salidas de texto ordenadas y claras que detallan el balance estático del sistema físico evaluado y despliega una ventana de gráficos con los diagramas mecánicos resueltos. Los diagramas se trazan de manera automatizada correlacionando perfectamente las discontinuidades de cortante con los máximos y mínimos de momento flector a lo largo de toda la luz de la viga.

Video de Presentación del Proyecto

A continuación, se presenta el enlace a la demostración del software y la validación de sus módulos operativos:

Ver Video Explicativo en YouTube
https://youtu.be/qhKxPXNrFs0

6.	CONCLUSIONES

•	La metodología modular estructurada bajo un bucle permanente garantiza una navegación fluida, previniendo detenciones inesperadas gracias al control de entradas inválidas mediante la cláusula otherwise.
 
•	La integración de una base de datos binaria independiente (.mat) resuelve de forma definitiva la persistencia de datos de ingeniería entre diferentes sesiones de trabajo, ofreciendo un almacenamiento flexible que crece dinámicamente con las celdas de la estructura (struct).

•	La técnica de re-indexación automática consecutiva implementada en el módulo de eliminación blinda la integridad referencial de la herramienta, garantizando que futuras consultas apunten siempre a los vectores correctos.

•	La discretización segmentada en 500 nodos proporciona un balance óptimo entre eficiencia computacional y precisión gráfica, permitiendo capturar curvas parabólicas suaves y transiciones abruptas en los diagramas de fuerza cortante y momento flector.
