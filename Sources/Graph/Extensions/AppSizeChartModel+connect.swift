//
//  Copyright © Marc Rollin.
//

import AppSizeChart
import AppStoreConnect
import Foundation

extension AppSizeChartModel {

    init(
        app: Application,
        sizesByBuildsAndVersions: [SizesByBuildAndVersion],
        includeDownloadSize: Bool,
        includeInstallSize: Bool,
        referenceDeviceIdentifier: String?
    ) {
        self.init(
            appName: app.name,
            downloadSizes: includeDownloadSize
                ? sizesByBuildsAndVersions.map { sizes in
                    .init(
                        sizes: sizes,
                        category: .download,
                        referenceDeviceIdentifier: referenceDeviceIdentifier
                    )
                }
                : nil,
            installSizes: includeInstallSize
                ? sizesByBuildsAndVersions.map { sizes in
                    .init(
                        sizes: sizes,
                        category: .install,
                        referenceDeviceIdentifier: referenceDeviceIdentifier
                    )
                }
                : nil,
            referenceDeviceIdentifier: referenceDeviceIdentifier
        )
    }
}

private extension AppSizeChartModel.Size {
    enum Category {
        case download, install
    }

    init(sizes: SizesByBuildAndVersion, category: Category, referenceDeviceIdentifier: String? = nil) {
        let keyPath: KeyPath<BuildBundleFileSize, Int>

        switch category {
        case .download:
            keyPath = \.downloadBytes
        case .install:
            keyPath = \.installBytes
        }

        var sizeByDevice = sizes.fileSizes.reduce(into: [String: Int]()) { result, size in
            result[size.deviceModel] = size[keyPath: keyPath]
        }
        let universal = sizeByDevice.removeValue(forKey: AppSizeChartModel.universalIdentifier)
        let thinnedSizes = sizeByDevice.values

        self.init(
            version: sizes.version?.version ?? sizes.build.version,
            universal: universal,
            reference: referenceDeviceIdentifier != nil ? sizeByDevice[referenceDeviceIdentifier!] : nil,
            thinned: (thinnedSizes.min() ?? 0)...(thinnedSizes.max() ?? 0)
        )
    }
}
