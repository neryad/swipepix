# Validación nativa

Usar fotos de prueba. La eliminación requiere revisión, confirmación de SwipePix y la confirmación adicional que solicite el sistema.

| Caso | Resultado esperado | Estado |
|---|---|---|
| Android 12 o anterior: permitir | Miniaturas; permiso de lectura compatible | Pendiente |
| Android 13: permitir imágenes | Solo imágenes; sin vídeo/ubicación | Pendiente |
| Android 14+: selección limitada | Solo fotos permitidas; cambiar selección actualiza | Pendiente |
| iOS: acceso total y limitado | Fotos accesibles y gestión de selección | Pendiente |
| Denegar permiso | Explicación y acceso a ajustes, sin fotos | Pendiente |
| Denegar permanentemente | Abrir ajustes y recuperar al volver | Pendiente |
| Revocar en ajustes y regresar | Quitar fotos antiguas de pantalla | Pendiente |
| Cero fotos / selección sin imágenes | Estado vacío y recuperación | Pendiente |
| Más de 60 fotos | Cargar siguiente página, sin duplicados | Validado en móvil; modelo y SO pendientes |
| Foto eliminada externamente / iCloud sin red | Placeholder o error recuperable | Pendiente |
| ES/EN y claro/oscuro, texto grande | Sin cortes; contenido desplazable | Pendiente |
| Más recientes / más antiguas | Fechas en el orden elegido y paginación estable | Pendiente |
| Mayor tamaño | Índice completo, tamaños visibles y orden descendente | Pendiente |
| Cerrar y abrir durante swipe | Ofrece continuar en la foto correcta y conserva marcadas | Pendiente |
| Foto guardada eliminada externamente | Se retira al continuar y el progreso se ajusta | Pendiente |
| Preferencias tras reinicio | Mantiene idioma, tema y orden; no repite onboarding | Pendiente |

## Evidencia recibida

| Fecha | Dispositivo / SO | Resultado |
|---|---|---|
| 2026-09-20 | Móvil no especificado | Permiso concedido y fotos cargadas correctamente. Falta registrar plataforma, versión y casos de acceso limitado/revocación. |
| 2026-09-20 | Mismo móvil, plataforma no especificada | Flujo de swipe, revisión, confirmación y borrado real validado con aproximadamente 3 fotos. |
| 2026-09-20 | Mismo móvil, plataforma no especificada | Carga automática al final de la galería, continuación con el siguiente lote y ausencia de fotos repetidas confirmadas por el usuario. |

Registrar dispositivo, versión del SO, resultado y evidencia sin exponer fotos personales. El acceso básico y las miniaturas ya se verificaron en un móvil; los casos específicos de la matriz siguen pendientes.

## Contrato de eliminación

- Swipe y botones solo modifican una selección de IDs; nunca llaman a borrado.
- Mantener/omitir no modifica la galería.
- Revisar permite inspeccionar y retirar cada candidato.
- Cancelar confirmación no hace ninguna llamada nativa.
- Confirmar captura la selección revisada; bloquear doble envío.
- Revalidar acceso y existencia de los IDs antes de la operación.
- Eliminar de pendientes solo los IDs devueltos como eliminados por la API.
- Conservar cancelaciones, fallos parciales y IDs no borrados para revisión.
- Deshacer aplica a la selección previa al borrado; no prometer restaurar una eliminación nativa.
