# SwipePix

- Arquitectura por features con presentación, aplicación y dominio/datos cuando corresponda.
- Usar Riverpod; mantener llamadas a photo_manager dentro de data.
- Swipe y galería nunca llaman al borrado; solo la revisión confirmada puede hacerlo.
- Borrado futuro exige revisión, confirmación y manejo de resultados parciales.
- Todas las cadenas visibles en ES/EN mediante ARB.
- Ejecutar flutter analyze y flutter test al cambiar lógica.
- No confundir pruebas simuladas con validación nativa; registrar evidencia en docs/device-validation.md.
- No subir fotos ni registrar rutas/identificadores privados en logs.
