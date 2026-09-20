import 'frame_extractor_stub.dart' hide getPlatformExtractor;
import 'frame_extractor_io.dart'
    if (dart.library.js_interop) 'frame_extractor_web.dart';

export 'frame_extractor_stub.dart';

FrameExtractorPlatform createExtractor() => getPlatformExtractor();
