import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

PageType {
    id: root

    Connections {
        target: PageController

        function onGoToPageHome() {
            tabBar.currentIndex = 0
            tabBarStackView.goToTabBarPage(PageController.getPagePath(PageEnum.PageHome))
        }

        function onShowErrorMessage(errorMessage) {
            popupErrorMessage.popupErrorMessageText = errorMessage
            popupErrorMessage.open()
        }
    }

    StackViewType {
        id: tabBarStackView

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: tabBar.top

        width: parent.width
        height: root.height - tabBar.implicitHeight

        function goToTabBarPage(page) {
            var pagePath = PageController.getPagePath(page)
            tabBarStackView.clear(StackView.PopTransition)
            tabBarStackView.replace(pagePath, { "objectName" : pagePath })
        }

        Component.onCompleted: {
            var pagePath = PageController.getPagePath(PageEnum.PageHome)
            tabBarStackView.push(pagePath, { "objectName" : pagePath })
            ServersModel.setCurrentlyProcessedServerIndex(ServersModel.getDefaultServerIndex())
            ContainersModel.setCurrentlyProcessedServerIndex(ServersModel.getDefaultServerIndex())
        }
    }

    TabBar {
        id: tabBar

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        topPadding: 8
        bottomPadding: 34
        leftPadding: 96
        rightPadding: 96

        background: Rectangle {
            color: "#1C1D21"
        }

        TabImageButtonType {
            isSelected: tabBar.currentIndex === 0
            image: "qrc:/images/controls/home.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageHome)
                ContainersModel.setCurrentlyProcessedServerIndex(ServersModel.getDefaultServerIndex())
            }
        }
        TabImageButtonType {
            isSelected: tabBar.currentIndex === 1
            image: "qrc:/images/controls/share-2.svg"
            onClicked: {}
        }
        TabImageButtonType {
            isSelected: tabBar.currentIndex === 2
            image: "qrc:/images/controls/settings-2.svg"
            onClicked: {
                tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
            }
        }
    }

    MouseArea {
        anchors.fill: tabBar
        anchors.leftMargin: 96
        anchors.rightMargin: 96
        cursorShape: Qt.PointingHandCursor
        enabled: false
    }

    Item {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        implicitHeight: popupErrorMessage.height

        PopupType {
            id: popupErrorMessage
        }
    }
}