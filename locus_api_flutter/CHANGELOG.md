# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Locus API Flutter plugin
- Support for displaying points in Locus Map
- Support for displaying tracks in Locus Map
- Navigation control functionality
- Track recording control (start, stop, pause, resume)
- Locus Map application status checking
- Support for multiple Locus Map versions (Free, Pro, Classic)
- Comprehensive error handling with PlatformException
- Complete example application demonstrating all features
- Detailed documentation and API reference

### Features
- **Point Display**: Display single or multiple geographical points
- **Track Display**: Display GPS tracks with multiple track points
- **Navigation**: Start navigation to specific destinations
- **Track Recording**: Full control over track recording functionality
- **Status Monitoring**: Get real-time information about Locus Map state
- **Multi-Version Support**: Compatible with all Locus Map variants
- **Error Handling**: Robust error handling and user feedback

### Technical Details
- Built on Locus API Android 0.9.64
- Minimum Android API level 21
- Flutter 3.3.0+ compatibility
- Kotlin-based Android implementation
- Method channel communication between Flutter and native Android
- Comprehensive data models for all Locus objects

### Documentation
- Complete README with usage examples
- API reference documentation
- Setup instructions for Android
- Example application with all features demonstrated
- Error handling guidelines