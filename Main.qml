import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.7

import "components"

Rectangle {
    // Main Container
    id: container
		property string user: "seb"

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    // Inherited from SDDMComponents
    TextConstants {
        id: textConstants
    }

    // Set SDDM actions
    Connections {
        target: sddm
        onLoginSucceeded: {
        }

        onLoginFailed: {
            error_message.color = "#dc322f"
            error_message.text = textConstants.loginFailed
        }
    }

    // Set Font
    FontLoader {
        id: textFont; name: config.displayFont
    }

    // Background Fill
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    // Set Background Image
    Image {
        id: image1
        anchors.fill: parent
        //source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    // Clock and Login Area
    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            id: login_container

            y: parent.height * 0.8
            //y: clock.y + clock.height + 30
						x: parent.width * 0.46
						//x: clock.x + clock.width + 30 
            width: parent.width * 0.08
            height: parent.height * 0.08
            color: "transparent"
            //anchors.left: clock.left

            Rectangle {
                id: password_row
                height: parent.height * 0.36
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                transformOrigin: Item.Center
                anchors.margins: 10

                PasswordBox {
                    id: password_input_box
                    height: parent.height
                    width: parent.width * 1
                    font: textFont.name
                    color: "#25000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height // this sets button width, this way its a square
									  anchors.left: parent.left
                    anchors.leftMargin: config.passwordLeftMargin
                    borderColor: "transparent"
                    textColor: "lightGray"
                    tooltipBG: "#25000000"
                    tooltipFG: "#dc322f"
                    image: "components/resources/warning_red.png"
                    onTextChanged: {
                        if (password_input_box.text == "") {
                            clear_passwd_button.visible = false
                        }
                        if (password_input_box.text != "" && config.showClearPasswordButton != "false") {
                            clear_passwd_button.visible = true
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(user, password_input_box.text, session.index)
                            event.accepted = true
                        }
                    }

                    KeyNavigation.backtab: login_button
                    KeyNavigation.tab: login_button
                }

                Button {
                    id: clear_passwd_button
                    height: parent.height
                    width: parent.height
                    color: "transparent"
                    text: "x"
                    font: textFont.name

                    border.color: "transparent"
                    border.width: 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.leftMargin: 0
                    anchors.rightMargin: parent.height

                    disabledColor: "#dc322f"
                    activeColor: "#393939"
                    pressedColor: "#2aa198"

                    onClicked: {
                        password_input_box.text=''
                        password_input_box.focus = true
                    }
                }

                Button {
                    id: login_button
                    height: parent.height
										width: parent.width * 0.08
                    color: "#393939"
                    text: ">"
                    border.color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: password_input_box.right
                    anchors.right: parent.right
                    disabledColor: "#dc322f"
                    activeColor: "darkGray"
                    pressedColor: "#2aa198"
                    textColor: "lightGray"
                    font: textFont.name

                    onClicked: sddm.login(user, password_input_box.text, session.index)

                    KeyNavigation.backtab: password_input_box
                    KeyNavigation.tab: reboot_button
                }

                Text {
                    id: error_message
                    height: parent.height
                    font.family: textFont.name
                    font.pixelSize: 12
                    color: "lightGray"
                    anchors.top: password_input_box.bottom
                    anchors.left: password_input_box.left
                    anchors.leftMargin: 0
                }
            }

        }
    }

    // Top Bar
    Rectangle {
        id: actionBar
        width: parent.width
        height: parent.height * 0.04
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        visible: config.showTopBar != "false"

        Row {
            id: row_left
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 10

            ComboBox {
                id: session
                width: 145
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                arrowColor: "transparent"
                textColor: "#505050"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                model: sessionModel
                index: sessionModel.lastIndex

                KeyNavigation.backtab: shutdown_button
                KeyNavigation.tab: password_input_box
            }

            ComboBox {
                id: language

                model: keyboard.layouts
                index: keyboard.currentLayout
                width: 50
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                arrowColor: "transparent"
                textColor: "white"
                borderColor: "transparent"
                hoverColor: "#5692c4"

                onValueChanged: keyboard.currentLayout = id

                Connections {
                    target: keyboard

                    onCurrentLayoutChanged: combo.index = keyboard.currentLayout
                }

                rowDelegate: Rectangle {
                    color: "transparent"

                    Text {
                        anchors.margins: 4
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        verticalAlignment: Text.AlignVCenter

                        text: modelItem ? modelItem.modelData.shortName : "zz"
                        font.family: textFont.name
                        font.pixelSize: 14
                        //color: "white"
                        color: "#505050"
                    }
                }
                KeyNavigation.backtab: session
                KeyNavigation.tab: password_input_box
            }
        }

        Row {
            id: row_right
            height: parent.height
            anchors.right: parent.right
            anchors.margins: 5
            spacing: 10

            ImageButton {
                id: reboot_button
                height: parent.height
                source: "components/resources/reboot.svg"

                visible: sddm.canReboot
                onClicked: sddm.reboot()
                KeyNavigation.backtab: login_button
                KeyNavigation.tab: shutdown_button
            }

            ImageButton {
                id: shutdown_button
                height: parent.height
                source: "components/resources/shutdown.svg"
                visible: sddm.canPowerOff
                onClicked: sddm.powerOff()
                KeyNavigation.backtab: reboot_button
                KeyNavigation.tab: session
            }
        }
    }

    Component.onCompleted: {
        image1.source = config.background_img_day
				actionBar.visible = true
        login_button.visible = true
        password_input_box.focus = true

        if (config.showLoginButton == "false") {
            login_button.visible = true
            password_input_box.anchors.rightMargin = 0
            clear_passwd_button.anchors.rightMargin = 0
        }
        clear_passwd_button.visible = false
    }
}

