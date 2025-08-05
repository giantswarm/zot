# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.3.1] - 2025-08-05

## [2.3.1] - 2025-08-05

### Changed

- Upgrade to upstream Helm chart `v0.1.78` (patch release)

## [2.3.0] - 2025-07-15

### Changed

- Upgrade to upstream Helm chart `v0.1.75`
  - Added support for headless service, see: https://github.com/project-zot/helm-charts/pull/68

## [2.2.1] - 2025-07-01

### Changed

- Update Helm values schema

## [2.2.0] - 2025-06-26

### Changed

- Bump default `zot` image tag to `v2.1.5`.
- Migrate Deployment and PVC to a StatefulSet when persistency is enabled.

## [2.1.0] - 2025-03-19

### Changed

- Update to `project-zot/helm-charts` version `0.1.67`.
- Bump default `zot` image tag to `v2.1.2`.

## [2.0.1] - 2024-11-04

### Fixed

- Fixed duplicate entry in `ServiceMonitor` resources.

## [2.0.0] - 2024-10-09

### Changed

- Moved `.serviceMonitor` Helm values under `.metrics` to conform upstream chart.
  - Additionally, now `.metrics.enabled` and `.metrics.serviceMonitor.enabled` must both be set to true to
    deploy the ServiceMonitor to conform upstream.
- Bump default `zot` image tag to `v2.1.1`.

### Removed

- Removed `.serviceMonitor.namespace` as it was not used and upstream does not use it either.

## [1.1.0] - 2024-07-16

### Changed

- Update to `project-zot/helm-charts` version `0.1.58`.
  - Update Default Zot container image tag to version
    [v2.1.0](https://github.com/project-zot/zot/releases/tag/v2.1.0)

## [1.0.0] - 2024-06-17

### Added

- Added support for setting `.spec.template.spec.priorityClassName` for the Zot deployment via Helm value
  `.priorityClassName`. Defaults to empty string, meaning a priority class does not get set by default.
- Added setting to VPA to control max allowed CPU and memory. Defaults to `750m` and `2048Mi`.

### Changed

- Changed default service type to `ClusterIP`.
- Changed default node port to `32767` and it is added to the service only when service type is `NodePort`.
- Enabled `PVC` creation by default.
- Changed default resource requests to `300m` CPU and `1024Mi` memory, limits to `500m` CPU and `1536Mi`
  memory.

## [0.3.1] - 2024-04-08

- update to zot 2.0.3

## [0.3.0] - 2024-04-08

- added:
  - mount an emptyDir volume to /tmp

## [0.2.0] - 2024-04-03

- added:
  - an ability to use basic auth for service monitor

## [0.1.5] - 2024-03-19

- fixed:
  - remove extra quotes from the policy expection name

## [0.1.4] - 2024-03-19

## [0.1.4] - 2024-03-19

- fixed:
  - Add separating dashes to the pvc template

## [0.1.3] - 2024-03-19

- added:
  - Add a Kyverno Exception to allow PVCs

## [0.1.2] - 2024-03-13

- fixed:
  - Remove duplicating labels

## [0.1.1] - 2024-03-12

- fixed:
  - chart is now pushed to the correct catalog

## [0.1.0] - 2024-03-12

- initial release compatible with vintage and CAPI

[Unreleased]: https://github.com/giantswarm/zot/compare/v2.3.1...HEAD
[2.3.1]: https://github.com/giantswarm/zot/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/giantswarm/zot/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/giantswarm/zot/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/giantswarm/zot/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/giantswarm/zot/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/giantswarm/zot/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/giantswarm/zot/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/giantswarm/zot/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/giantswarm/zot/compare/v0.3.1...v1.0.0
[0.3.1]: https://github.com/giantswarm/zot/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/zot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/zot/compare/v0.1.5...v0.2.0
[0.1.5]: https://github.com/giantswarm/zot/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/giantswarm/zot/compare/v0.1.4...v0.1.4
[0.1.4]: https://github.com/giantswarm/zot/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/giantswarm/zot/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/giantswarm/zot/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/giantswarm/zot/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/zot/releases/tag/v0.1.0
