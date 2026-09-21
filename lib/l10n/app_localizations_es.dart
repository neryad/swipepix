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
      'Empieza conectando tu galería. Tus fotos permanecen en tu dispositivo; SwipePix nunca las sube.';

  @override
  String get safety =>
      'Tú tienes el control. El swipe solo marcará fotos. Borrar requerirá una revisión y confirmación aparte.';

  @override
  String get connect => 'Explorar mis fotos';

  @override
  String get gallery => 'Tu galería';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get recentPhotos => 'Fotos recientes';

  @override
  String photoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
      zero: 'Sin fotos todavía',
    );
    return '$_temp0';
  }

  @override
  String get galleryHeroTitle => 'Lista para limpiar';

  @override
  String get permissionIntro =>
      'Permite el acceso para ver tu galería. Puedes compartir solo las fotos que elijas.';

  @override
  String get allow => 'Permitir acceso a fotos';

  @override
  String get settings => 'Ajustes';

  @override
  String get openSettings => 'Abrir ajustes del dispositivo';

  @override
  String get limited => 'Solo las fotos seleccionadas';

  @override
  String get authorized => 'Acceso completo a fotos';

  @override
  String get denied =>
      'El acceso está denegado. Puedes reintentarlo o cambiarlo en los ajustes del dispositivo.';

  @override
  String get restricted =>
      'El acceso a fotos está restringido por este dispositivo.';

  @override
  String get unsupported =>
      'Abre SwipePix en Android o iOS para acceder a tus fotos.';

  @override
  String get manage => 'Cambiar fotos seleccionadas';

  @override
  String get empty =>
      'No hay fotos accesibles. Si el acceso es limitado, prueba seleccionando más fotos.';

  @override
  String get error =>
      'No se pudieron cargar tus fotos. Revisa el acceso y vuelve a intentarlo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar galería';

  @override
  String get more => 'Cargar más fotos';

  @override
  String get loadingMorePhotos => 'Cargando más fotos…';

  @override
  String get readOnly =>
      'Deslizar solo marca fotos; borrar siempre requiere revisión y confirmación.';

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
  String get allPhotos => 'Todas';

  @override
  String get largePhotos => 'Grandes';

  @override
  String get oldestPhotos => 'Antiguas';

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
      other: '$count fotos',
      one: '1 foto',
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
    return 'Revisarás las $count fotos cargadas.';
  }

  @override
  String get cleanupTitle => 'Revisar fotos';

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
  String get reviewMarked => 'Revisar marcadas';

  @override
  String get sessionComplete => 'Terminaste esta ronda';

  @override
  String get sessionCompleteBody =>
      'Revisa las fotos marcadas antes de decidir si quieres borrarlas.';

  @override
  String get nothingMarked => 'No marcaste ninguna foto para borrar.';

  @override
  String get continueNextBatch => 'Continuar con el siguiente lote';

  @override
  String get loadingNextBatch => 'Buscando más fotos…';

  @override
  String get noMorePhotos => 'No hay más fotos nuevas para revisar';

  @override
  String get backToGallery => 'Volver a la galería';

  @override
  String get deleteReviewTitle => 'Revisión antes de borrar';

  @override
  String get deleteReviewSafety =>
      'Estas fotos todavía no se han borrado. Quita cualquiera que quieras conservar.';

  @override
  String get removeFromDelete => 'Conservar esta foto';

  @override
  String get deleteSelected => 'Borrar fotos seleccionadas';

  @override
  String get confirmDeleteTitle => '¿Borrar definitivamente?';

  @override
  String confirmDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return 'Se solicitará borrar $_temp0 del dispositivo. El sistema puede pedir otra confirmación.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmDelete => 'Confirmar borrado';

  @override
  String get deleting => 'Esperando confirmación del sistema…';

  @override
  String deleteSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se borraron $count fotos',
      one: 'Se borró 1 foto',
    );
    return '$_temp0.';
  }

  @override
  String get deletePartial =>
      'Algunas fotos no se borraron o se canceló la confirmación. Siguen en la lista.';

  @override
  String get deleteAccessLost =>
      'No se pudo borrar. Revisa el permiso de fotos y vuelve a intentarlo.';

  @override
  String get previewUnavailable => 'No se pudo cargar esta foto.';

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
  String get restoringSession => 'Comprobando fotos…';

  @override
  String get sessionUnavailable =>
      'No se pudo recuperar la sesión. Revisa el permiso de fotos.';

  @override
  String get startNewCleanup => 'Empezar una limpieza nueva';

  @override
  String get replaceSessionTitle => '¿Reemplazar la sesión guardada?';

  @override
  String get replaceSessionBody =>
      'Se perderá el progreso y las fotos marcadas de la sesión anterior. Ninguna foto se borrará.';

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
      'SwipePix te ayuda a revisar tu galería de forma rápida y segura. Las fotos permanecen en tu dispositivo, y deslizar solo marca fotos para revisión. Nada se borra hasta que lo confirmas.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyBody =>
      'SwipePix solicita acceso a tu galería solo para mostrar fotos, organizar sesiones de revisión y solicitar el borrado en el dispositivo cuando tú confirmas. SwipePix no sube, vende ni comparte tus fotos. Tu progreso y preferencias se guardan localmente en este dispositivo.';

  @override
  String get termsConditions => 'Términos y condiciones';

  @override
  String get termsConditionsBody =>
      'SwipePix se ofrece para ayudarte a revisar y gestionar tus propias fotos. Tú eres responsable de confirmar qué fotos quieres borrar. Las solicitudes de borrado las gestiona el sistema del dispositivo y pueden requerir una confirmación adicional.';

  @override
  String get legalUpdated => 'Última actualización: 21 de septiembre de 2026';
}
