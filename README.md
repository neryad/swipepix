# SwipePix

Fase 1 de SwipePix: acceso real a la galería, revisión por swipe y eliminación segura con revisión y confirmación.

## Ejecutar

Requiere Flutter 3.44.2 / Dart 3.12.2 y un dispositivo Android o iOS configurado.

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

Ejecutar estos comandos desde la carpeta que contiene este README. Se incluye `pubspec.lock` para reproducir las dependencias. go_router se limita a 17.x porque 18.0.1 arrastró dependencias que no compilaron con el SDK instalado.

## Implementado

- Bienvenida con explicación de privacidad y eliminación segura.
- Navegación con go_router: bienvenida, galería y ajustes.
- Riverpod para dependencias, estado de galería y preferencias.
- ES/EN con ARB y generación oficial de Flutter; claro/oscuro/sistema.
- Adaptador real photo_manager: solo imágenes, sin ubicación ni vídeos.
- Acceso completo, limitado, denegado, restringido y no solicitado.
- Permiso solicitado por acción explícita; relectura al regresar a la app.
- Selección limitada, ajustes del dispositivo, vacío, error y reintento.
- Miniaturas de 256 px y páginas de 60 fotos, más recientes primero.
- Carga automática de otra página al acercarse al final de la galería, conservando visibles las fotos ya cargadas.
- Protección contra respuestas antiguas y limpieza de fotos al revocar acceso.
- Cadenas nativas de permiso iOS ES/EN (siguen el idioma del sistema).
- Swipe a la izquierda para marcar y a la derecha para conservar, con botones equivalentes y deshacer.
- Revisión separada para retirar candidatas antes de borrar.
- Confirmación de SwipePix y confirmación adicional del sistema cuando la plataforma la solicite.
- Resultados parciales: solo desaparecen los IDs que el sistema devuelve como borrados; cancelaciones y fallos permanecen pendientes.
- Orden por fecha, en ambas direcciones, usando la consulta nativa de la galería.
- Orden global por tamaño real del archivo, calculado por lotes y mostrado en las miniaturas.
- Onboarding mostrado una sola vez; idioma, tema y orden guardados localmente.
- Sesión de swipe persistente con opción de continuar o empezar de nuevo.
- Revalidación de permisos e IDs al continuar: las fotos inaccesibles se retiran y el índice se ajusta.
- Tarjeta de sesión siempre visible en la galería, con estado vacío o progreso guardado.
- Acceso a “Ver introducción” desde Ajustes después de completar el onboarding.
- Progreso de revisadas, pendientes y marcadas durante la limpieza.
- Continuación por lotes de hasta 60 fotos sin repetir las que ya pertenecen a la sesión; el lote nuevo también se guarda localmente.

Las preferencias y la sesión de limpieza se guardan en el dispositivo mediante el almacenamiento ligero de Flutter. Solo se guardan preferencias, IDs y metadatos necesarios para reanudar; no se guardan copias de las fotos. Todavía no hay cálculo de espacio liberado. La primera selección de “Mayor tamaño” recorre los metadatos de la galería y puede tardar en bibliotecas grandes; no carga las imágenes originales. Las miniaturas de fotos en iCloud pueden requerir que el sistema las descargue: SwipePix no sube fotos a ningún servicio.

## Arquitectura por features

`lib/app`: composición, router y tema.

`lib/features/onboarding`: bienvenida.

`lib/features/settings`: preferencias y pantalla de ajustes.

`lib/features/gallery/domain`: modelos y contrato del repositorio sin APIs del plugin.

`lib/features/gallery/data`: adaptador de photo_manager, que encapsula el acceso nativo.

`lib/features/gallery/application`: controlador Riverpod con estado inmutable, paginación y permisos.

`lib/features/gallery/presentation`: widgets y ciclo de vida de la pantalla.

`lib/features/cleanup`: estado de la sesión, swipe, deshacer, revisión y borrado confirmado.

`lib/l10n`: traducciones y clases generadas. Editar los ARB, no las clases generadas.

Los widgets no llaman al plugin. El controlador depende de un repositorio sustituible en pruebas. No se añade una capa de casos de uso hasta que exista lógica que la justifique.

## Verificación de esta entrega

- `flutter analyze`: sin incidencias.
- `flutter test`: 33 pruebas aprobadas (permisos, revocación, errores, paginación automática, lotes sin duplicados, ordenamiento, persistencia, restauración, onboarding accesible, navegación, ES/EN, swipe, revisión, cancelación y borrado parcial).
- No se generó un APK en esta entrega; la app se ejecuta desde el entorno Flutter del usuario.
- Configuración y traducciones nativas iOS: archivos validados con `plutil`.
- Las pruebas utilizan repositorios simulados: no demuestran funcionamiento del permiso del sistema operativo.
- El acceso, la carga, el swipe, la revisión y el borrado de aproximadamente 3 fotos fueron confirmados por el usuario en un móvil. La plataforma y versión del SO no se registraron todavía.
- El emulador Pixel_10 instalado no arrancó: “Incompatible processor … neon”.
- Xcode requiere completar la instalación de componentes antes de validar iOS.
- Consultar `docs/device-validation.md` para cerrar la prueba nativa antes del swipe.

## Próximos incrementos

1. Validar permisos y miniaturas en Android e iOS reales; completar la matriz adjunta.
2. Validar swipe, cancelación, confirmación del sistema y borrado parcial con fotos prescindibles en Android e iOS.
3. Medir consumo de memoria y pulir el rendimiento con galerías grandes.
4. Medir espacio liberado solo cuando la plataforma permita verificarlo con fiabilidad.

## Referencias

- [photo_manager](https://pub.dev/packages/photo_manager)
- [Riverpod](https://riverpod.dev/)
- [go_router](https://pub.dev/packages/go_router)

Los requisitos se recuperaron del texto accesible de la conversación y de la solicitud actual. El archivo original de 19 KB no estaba adjunto y no se afirma haberlo reproducido.
