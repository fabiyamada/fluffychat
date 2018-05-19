import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

PageHeader {
    id: header
    title: i18n.tr('FluffyChat')

    StyleHints { foregroundColor: "#5625BA" }

    extension: ProgressBar {
        id: requestProgressBar
        indeterminate: true
        width: parent.width
        visible: progressBarRequests > 0
    }
}
