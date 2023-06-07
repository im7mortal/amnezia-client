import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel 0.2

import PageEnum 1.0
import ProtocolEnum 1.0

import "../Controls2"
import "../Controls2/TextTypes"


ListView {
    id: menuContent

    property var rootWidth

    width: rootWidth
    height: menuContent.contentItem.height

    clip: true
    interactive: false

    ButtonGroup {
        id: containersRadioButtonGroup
    }

    delegate: Item {
        implicitWidth: rootWidth
        implicitHeight: content.implicitHeight

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.rightMargin: 16
            anchors.leftMargin: 16

            VerticalRadioButton {
                id: containerRadioButton

                Layout.fillWidth: true

                text: name
                descriptionText: description

                ButtonGroup.group: containersRadioButtonGroup

                imageSource: "qrc:/images/controls/download.svg"
                showImage: !isInstalled

                checkable: isInstalled
                checked: isDefault

                onClicked: {
                    if (checked) {
                        isDefault = true
                        menuContent.currentIndex = index
                        containersDropDown.menuVisible = false
                    } else {
                        ContainersModel.setCurrentlyInstalledContainerIndex(proxyContainersModel.mapToSource(index))
                        InstallController.setShouldCreateServer(false)
                        goToPage(PageEnum.PageSetupWizardProtocolSettings)
                        containersDropDown.menuVisible = false
                        menu.visible = false
                    }
                }

                MouseArea {
                    anchors.fill: containerRadioButton
                    cursorShape: Qt.PointingHandCursor
                    enabled: false
                }
            }

            DividerType {
                Layout.fillWidth: true
            }
        }

        Component.onCompleted: {
            if (isDefault) {
                root.currentContainerName = name
            }
        }
    }
}