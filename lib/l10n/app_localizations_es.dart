// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SwipePix';

  @override
  String get welcome => 'Haz espacio para lo que importa';

  @override
  String get intro =>
      'Empieza conectando tu galería. Tus fotos y videos permanecen en tu dispositivo; SwipePix nunca los sube.';

  @override
  String get safety =>
      'Tú tienes el control. El swipe solo marcará elementos. Borrar requerirá una revisión y confirmación aparte.';

  @override
  String get connect => 'Explorar mi galería';

  @override
  String get gallery => 'Tu galería';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get recentPhotos => 'Medios recientes';

  @override
  String photoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin medios todavía',
    );
    return '$_temp0';
  }

  @override
  String get galleryHeroTitle => 'Lista para limpiar';

  @override
  String get permissionIntro =>
      'Permite el acceso para ver tu galería. Puedes compartir solo las fotos y videos que elijas.';

  @override
  String get allow => 'Permitir acceso a fotos y videos';

  @override
  String get settings => 'Ajustes';

  @override
  String get openSettings => 'Abrir ajustes del dispositivo';

  @override
  String get limited => 'Solo fotos y videos seleccionados';

  @override
  String get authorized => 'Acceso completo a fotos y videos';

  @override
  String get denied =>
      'El acceso a fotos y videos está denegado. Puedes reintentarlo o cambiarlo en los ajustes del dispositivo.';

  @override
  String get restricted =>
      'El acceso a fotos y videos está restringido por este dispositivo.';

  @override
  String get unsupported =>
      'Abre SwipePix en Android o iOS para acceder a tu galería.';

  @override
  String get manage => 'Cambiar medios seleccionados';

  @override
  String get empty =>
      'No hay fotos ni videos accesibles. Si el acceso es limitado, prueba seleccionando más medios.';

  @override
  String get error =>
      'No se pudo cargar tu galería. Revisa el acceso y vuelve a intentarlo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar galería';

  @override
  String get more => 'Cargar más medios';

  @override
  String get loadingMorePhotos => 'Cargando más medios…';

  @override
  String get readOnly =>
      'Deslizar solo marca elementos; borrar siempre requiere revisión y confirmación.';

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Según el sistema';

  @override
  String get theme => 'Apariencia';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get thumbnailError => 'Vista previa no disponible';

  @override
  String get photo => 'Foto';

  @override
  String get sessionSettings =>
      'Estas preferencias se guardan en este dispositivo.';

  @override
  String get startCleanup => 'Empezar a revisar';

  @override
  String get quickCleanup => 'Limpieza rápida';

  @override
  String get allPhotos => 'Todos';

  @override
  String get largePhotos => 'Archivos grandes';

  @override
  String get oldestPhotos => 'Antiguos';

  @override
  String get albums => 'Álbumes';

  @override
  String get chooseWhatToClean => 'Elige qué limpiar';

  @override
  String get seeAll => 'Ver todo';

  @override
  String albumPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get noAlbums =>
      'Los álbumes aparecerán aquí cuando el dispositivo los comparta.';

  @override
  String get albumNotFound => 'Este álbum ya no está disponible.';

  @override
  String get startAlbumCleanup => 'Limpiar este álbum';

  @override
  String reviewedShort(int current, int total) {
    return '$current de $total revisadas';
  }

  @override
  String loadedSessionCount(int count) {
    return 'Revisarás los $count elementos cargados.';
  }

  @override
  String get cleanupTitle => 'Revisar medios';

  @override
  String get swipeHint => 'Izquierda para eliminar · derecha para conservar';

  @override
  String get mark => 'Marcar';

  @override
  String get keep => 'Conservar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get deleteOverlay => 'ELIMINAR';

  @override
  String get keepOverlay => 'CONSERVAR';

  @override
  String photoMetadata(String date, String size) {
    return '$date  •  $size';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String reviewProgress(int current, int total) {
    return '$current de $total';
  }

  @override
  String cleanupProgressSummary(int reviewed, int remaining, int marked) {
    return 'Revisadas: $reviewed · Pendientes: $remaining · Marcadas: $marked';
  }

  @override
  String markedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marcadas',
      one: '1 marcada',
      zero: 'Ninguna marcada',
    );
    return '$_temp0';
  }

  @override
  String get reviewMarked => 'Revisar elementos';

  @override
  String get sessionComplete => 'Terminaste esta ronda';

  @override
  String get sessionCompleteBody =>
      'Revisa los elementos marcados antes de decidir si quieres borrarlos.';

  @override
  String get nothingMarked => 'No marcaste nada para borrar.';

  @override
  String get continueNextBatch => 'Continuar con el siguiente lote';

  @override
  String get loadingNextBatch => 'Buscando más medios…';

  @override
  String get noMorePhotos => 'No hay más elementos nuevos para revisar';

  @override
  String get backToGallery => 'Volver a la galería';

  @override
  String get deleteReviewTitle => 'Revisión antes de borrar';

  @override
  String get deleteReviewSafety =>
      'Estos elementos todavía no se han borrado. Quita cualquiera que quieras conservar.';

  @override
  String get removeFromDelete => 'Conservar este elemento';

  @override
  String get deleteSelected => 'Borrar elementos seleccionados';

  @override
  String deleteReviewedPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Borrar $count elementos revisados',
      one: 'Borrar 1 elemento revisado',
    );
    return '$_temp0';
  }

  @override
  String get deleting => 'Esperando confirmación del sistema…';

  @override
  String get confirmDeleteTitle => '¿Borrar definitivamente?';

  @override
  String confirmDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return 'Se solicitará borrar $_temp0 del dispositivo. El sistema puede pedir otra confirmación.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmDelete => 'Confirmar borrado';

  @override
  String deleteSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se borraron $count elementos',
      one: 'Se borró 1 elemento',
    );
    return '$_temp0.';
  }

  @override
  String get deletePartial =>
      'Algunos elementos no se borraron o se canceló la confirmación. Siguen en la lista.';

  @override
  String get deleteAccessLost =>
      'No se pudo borrar. Revisa el permiso de galería y vuelve a intentarlo.';

  @override
  String get previewUnavailable => 'No se pudo cargar este elemento.';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get newestFirst => 'Más recientes';

  @override
  String get oldestFirst => 'Más antiguas';

  @override
  String get largestFirst => 'Mayor tamaño';

  @override
  String get calculatingSizes => 'Calculando tamaños de la galería…';

  @override
  String get continueCleanup => 'Continuar limpieza';

  @override
  String continueCleanupDetail(int current, int total) {
    return 'Progreso guardado: $current de $total';
  }

  @override
  String get restoringSession => 'Comprobando medios…';

  @override
  String get sessionUnavailable =>
      'No se pudo recuperar la sesión. Revisa el permiso de galería.';

  @override
  String get startNewCleanup => 'Empezar una limpieza nueva';

  @override
  String get replaceSessionTitle => '¿Reemplazar la sesión guardada?';

  @override
  String get replaceSessionBody =>
      'Se perderá el progreso y los elementos marcados de la sesión anterior. Nada se borrará.';

  @override
  String get viewIntroduction => 'Ver introducción';

  @override
  String get savedCleanupTitle => 'Sesión de limpieza';

  @override
  String get noSavedCleanup =>
      'No hay una limpieza pendiente. Empieza una nueva para guardar tu progreso.';

  @override
  String get youWillFree => 'Liberarás aproximadamente:';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get swipeToOrganize => 'Desliza para organizar';

  @override
  String get skip => 'Omitir';

  @override
  String get aboutSwipePix => 'Acerca de SwipePix';

  @override
  String get aboutSwipePixBody =>
      'SwipePix te ayuda a revisar tu galería de fotos y videos de forma rápida y segura. Los medios permanecen en tu dispositivo, y deslizar solo marca elementos para revisión. Nada se borra hasta que lo confirmas.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyBody =>
      'SwipePix está diseñada como una herramienta local para revisar fotos y videos. La app solicita acceso a tu galería solo para mostrar fotos y videos, crear sesiones de revisión, calcular metadatos de tamaño cuando estén disponibles y pedir al sistema operativo del dispositivo que borre elementos seleccionados después de tu confirmación.\n\nSwipePix no sube fotos ni videos. SwipePix no vende ni comparte tus fotos ni videos. En la app de producción actual, SwipePix no usa SDKs de publicidad, SDKs de analítica, píxeles de rastreo, SDKs de reportes de fallos, cuentas ni almacenamiento en la nube.\n\nLos datos guardados en este dispositivo pueden incluir tu idioma, apariencia, preferencia de orden, estado del onboarding, progreso de la sesión de limpieza, identificadores de medios necesarios para reanudar una sesión y metadatos limitados como fechas, duraciones o tamaños de archivo. Estos datos se guardan localmente en el almacenamiento de la app del dispositivo y se usan solo para la funcionalidad de la app.\n\nLos servicios de la plataforma pueden procesar el permiso de galería, el acceso limitado a medios seleccionados y la confirmación de borrado según el comportamiento del sistema de Apple o Google/Android. Si tu dispositivo usa servicios como iCloud Photos o Google Photos, esos servicios dependen del proveedor del dispositivo o de la cuenta, no de SwipePix.\n\nSwipePix no recopila intencionalmente información personal de menores y no está dirigida a menores.\n\nOpciones de privacidad: puedes revocar o limitar el acceso a la galería desde los ajustes del dispositivo. Puedes eliminar los datos locales borrando la app de tu dispositivo. Si la app agrega analítica, cuentas, sincronización en la nube, anuncios, pagos o cualquier procesamiento fuera del dispositivo, esta política y las declaraciones de privacidad de las tiendas deben actualizarse antes del lanzamiento.\n\nContacto: usa el contacto del desarrollador indicado en App Store o Google Play. Antes del lanzamiento público, reemplaza esta frase con el nombre de la entidad legal y un correo dedicado de privacidad.';

  @override
  String get termsConditions => 'Términos y condiciones';

  @override
  String get termsConditionsBody =>
      'Estos Términos regulan tu uso de SwipePix. Si no estás de acuerdo, no uses la app.\n\nServicio. SwipePix te ayuda a revisar fotos y videos en tu propio dispositivo. Deslizar a la izquierda solo marca un elemento para revisión de borrado. Los elementos no se borran hasta que revisas los elementos marcados y solicitas al sistema operativo del dispositivo que los borre. El sistema puede mostrar una confirmación adicional.\n\nTu responsabilidad. Tú eres responsable de decidir qué fotos o videos conservar o borrar y de mantener copias de seguridad de medios importantes antes de usar funciones de limpieza. SwipePix no puede garantizar la recuperación de medios después de que el sistema operativo complete el borrado.\n\nSin asesoría profesional. SwipePix se ofrece como herramienta utilitaria y no brinda asesoría legal, de gestión de almacenamiento, archivo, seguridad ni otro tipo de asesoría profesional.\n\nUso permitido. Puedes usar SwipePix solo con fines legales y solo con fotos y videos a los que tienes derecho de acceder y gestionar. No puedes intentar aplicar ingeniería inversa, abusar, interrumpir o usar indebidamente la app o servicios relacionados.\n\nPrivacidad. La Política de privacidad explica qué datos se procesan y guardan. En la app de producción actual, SwipePix está pensada para procesar fotos y videos localmente y no subirlos, venderlos ni compartirlos.\n\nDescargo. SwipePix se ofrece “tal cual” y “según disponibilidad”, sin garantías de ningún tipo en la máxima medida permitida por la ley. No garantizamos que la app funcionará sin interrupciones, sin errores o que será compatible con todos los dispositivos, configuraciones de galería o versiones del sistema operativo.\n\nLimitación de responsabilidad. En la máxima medida permitida por la ley, SwipePix y su desarrollador no serán responsables por daños indirectos, incidentales, especiales, consecuentes, ejemplares o punitivos, ni por pérdida de datos, pérdida de fotos, pérdida de ganancias o interrupción de negocio que surja de o se relacione con tu uso de la app.\n\nArbitraje y renuncia a demandas colectivas. Cualquier disputa, reclamación o controversia que surja de estos Términos o de SwipePix se resolverá mediante arbitraje individual final y vinculante, en lugar de en tribunales, excepto cuando cualquiera de las partes pueda presentar una reclamación individual en un tribunal de reclamos menores si califica. Tú y SwipePix renuncian al derecho a juicio por jurado y al derecho a participar en una demanda colectiva, consolidada, representativa, de fiscal general privado o similar. El arbitraje será administrado por la American Arbitration Association (AAA) bajo sus reglas de arbitraje de consumo aplicables, salvo que las partes acuerden otra cosa. El árbitro solo podrá otorgar remedios de forma individual. Esta sección no impide que cualquiera de las partes solicite medidas cautelares o equitativas por uso indebido de propiedad intelectual o acceso no autorizado.\n\nCambios. Estos Términos pueden actualizarse antes o después del lanzamiento. Si hay un cambio material, actualiza el aviso dentro de la app y la página pública de Términos.';

  @override
  String get legalUpdated => 'Última actualización: 25 de septiembre de 2026';

  @override
  String get video => 'Video';

  @override
  String get media => 'Medio';

  @override
  String videoDuration(String duration) {
    return '$duration';
  }

  @override
  String get videoPreviewTitle => 'Vista previa de video';

  @override
  String get loadingVideo => 'Cargando video…';

  @override
  String get videoPreviewUnavailable => 'No se pudo reproducir este video.';
}
