import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0

import "./"
import "../Pages"
import "../Controls2"
import "../Config"
import "../Controls2/TextTypes"

PageBase {
    id: root
    page: PageEnum.Start

    FlickableType {
        id: fl
        anchors.top: root.top
        anchors.bottom: root.bottom
        contentHeight: content.height

        ColumnLayout {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Image {
                id: image
                source: "qrc:/images/amneziaBigLogo.png"

                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: 32
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.preferredWidth: 344
                Layout.preferredHeight: 279
            }

            BodyTextType {
                Layout.fillWidth: true
                Layout.topMargin: 50
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                text: "Бесплатный сервис для создания личного VPN на вашем сервере. Помогаем получать доступ к заблокированному контенту, не раскрывая конфиденциальность даже провайдерам VPN."
            }

            BasicButtonType {
                Layout.fillWidth: true
                Layout.topMargin: 32
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                text: qsTr("У меня есть данные для подключения")

                onClicked: {
                    drawer.visible = true
                }
            }

            BasicButtonType {
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                defaultColor: "transparent"
                hoveredColor: Qt.rgba(1, 1, 1, 0.08)
                pressedColor: Qt.rgba(1, 1, 1, 0.12)
                disabledColor: "#878B91"
                textColor: "#D7D8DB"
                borderWidth: 1

                text: qsTr("У меня ничего нет")

//                onClicked: {
//                    UiLogic.goToPage(PageEnum.Start)
//                }
            }

            DropDownType {
                Layout.fillWidth: true

                text: "IP, логин и пароль от сервера"
                descriptionText: "IP, логин и пароль от сервера"

                menuModel: [
                    qsTr("SHA512"),
                    qsTr("SHA384"),
                    qsTr("SHA256"),
                    qsTr("SHA3-512"),
                    qsTr("SHA3-384"),
                    qsTr("SHA3-256"),
                    qsTr("whirlpool"),
                    qsTr("BLAKE2b512"),
                    qsTr("BLAKE2s256"),
                    qsTr("SHA1")
                ]
            }
            CheckBoxType {
//                text: qsTr("Auto-negotiate encryption")
            }
            CheckBoxType {
                text: qsTr("Auto-negotiate encryption")
                descriptionText: "dssaa"
            }

            Rectangle {
                implicitWidth: buttonGroup.implicitWidth
                implicitHeight: buttonGroup.implicitHeight

                Layout.leftMargin: 16
                Layout.rightMargin: 16

                color: "#1C1D21"
                radius: 16
                RowLayout {
                    id: buttonGroup

                    spacing: 0

                    HorizontalRadioButton {
                        implicitWidth: (root.width - 32) / 2
                        text: "ddsasdasd"
                    }
                    HorizontalRadioButton {
                        implicitWidth: (root.width - 32) / 2
                        text: "ddsasdasd"
                    }
                }
            }

            VerticalRadioButton {
                text: "dsasd"
                descriptionText: "asd"
                checked: true

                Layout.fillWidth: true
            }
            VerticalRadioButton {
                text: "dsasd"

                Layout.fillWidth: true
            }
        }

        Drawer {
            id: drawer

            edge: Qt.BottomEdge
            width: parent.width
            height: parent.height * 0.4375

            clip: true
            modal: true

            background: Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: -radius
                radius: 16
                color: "#1C1D21"
            }

            Overlay.modal: Rectangle {
                color: Qt.rgba(14/255, 14/255, 17/255, 0.8)
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.rightMargin: 16
                anchors.leftMargin: 16

                Header2TextType {
                    Layout.fillWidth: true
                    Layout.topMargin: 24
                    Layout.alignment: Qt.AlignHCenter

                    text: "Данные для подключения"
                    wrapMode: Text.WordWrap
                }

                LabelWithButtonType {
                    id: ip
                    Layout.fillWidth: true
                    Layout.topMargin: 32

                    text: "IP, логин и пароль от сервера"
                    buttonImage: "qrc:/images/controls/chevron-right.svg"

                    onClickedFunc: function() {
                        UiLogic.goToPage(PageEnum.WizardCredentials)
                        drawer.visible = false
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#2C2D30"
                }
                LabelWithButtonType {
                    Layout.fillWidth: true

                    text: "QR-код, ключ или файл настроек"
                    buttonImage: "qrc:/images/controls/chevron-right.svg"

    //                onClickedFunc: function() {
    //                    UiLogic.goToPage(PageEnum.Start)
    //                }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#2C2D30"
                }
            }
        }
    }
}