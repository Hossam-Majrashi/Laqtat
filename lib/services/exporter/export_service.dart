import 'export_service_stub.dart' hide getExportPlatform;
import 'export_service_io.dart'
    if (dart.library.js_interop) 'export_service_web.dart';

export 'export_service_stub.dart';

ExportPlatform createExporter() => getExportPlatform();
