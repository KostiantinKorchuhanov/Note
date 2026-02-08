import QtQuick 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


ApplicationWindow {
    id: main
    visible: true
    width: 600
    height: 500
    title: "Notes"
    color: "transparent"

    ListModel {
        id: searchResultsModel
    }

    Component.onCompleted: {
        interact_database.get_last_note()
    }

    Connections {
        target: interact_database
        function onLast_changed(note, title) {
            mainTextArea.text = note
            noteName.text = title
        }
        function onSearch_results(results) {
            searchResultsModel.clear()
            for (var i = 0; i < results.length; i++)
                searchResultsModel.append(results[i])
            searchResults.visible = tempText.text.length > 0 && searchResultsModel.count > 0
        }
    }

    Rectangle {
        id: mainField
        anchors.fill: parent
        radius: 20

        Rectangle {
            id: searchPanel
            height: parent.height/20
            width: parent.width/3
            anchors.margins: 8
            anchors.top: parent.top
            anchors.left: parent.left
            radius: 20
            color: "#444444"

            TextInput {
                anchors.fill: parent
                anchors.margins: 4
                id: tempText
                text: ""
                font.pixelSize: searchPanel.height*0.5
                color: "#bcbcbc"
                wrapMode: TextInput.NoWrap
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignLeft

                onTextChanged: {
                    if (text.length > 0) {
                        interact_database.search_note(text)
                    }
                    searchResults.visible = text.length > 0 && searchResultsModel.count > 0
                }

            }
            Text {
                anchors.left: tempText.left
                anchors.verticalCenter: tempText.verticalCenter
                text: "Search..."
                color: "#737272"
                font.pixelSize: searchPanel.height*0.6
                visible: !tempText.text && !tempText.activeFocus
            }
        }

        ListView {
            id: searchResults
            anchors.top: searchPanel.bottom
            anchors.left: mainField.left
            anchors.margins: 8
            width: searchPanel.width
            height: searchPanel.height*5
            model: searchResultsModel
            z: 5
            visible: false

            delegate: Rectangle {
                height: searchPanel.height
                width: searchPanel.width
                color: index % 2 === 0 ? "#eeeeee" : "#dddddd"

                Row {
                    width: parent.width
                    spacing: 8
                    Text {
                            text: model.note_title
                            font.bold: true
                            font.pixelSize: searchPanel.height * 0.5
                            width: searchPanel.width*0.3
                    }
                    Text {
                            text: "Line " + model.line_number
                            font.pixelSize: searchPanel.height * 0.5
                            width: searchPanel.width*0.2
                    }
                    Text {
                            text: model.note_text
                            elide: Text.ElideRight
                            font.pixelSize: searchPanel.height * 0.5
                            width: parent.width*0.5
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        interact_database.select_note(model.note_id)
                        searchResultsModel.clear()
                        searchResults.visible = false
                    }
                }
            }
        }

        Rectangle {
            id: noteNameArea
            height: parent.height/20
            width: parent.width/3
            anchors.margins: 8
            anchors.top: parent.top
            anchors.left: searchPanel.right
            radius: 20
            color: "#444444"

            TextInput {
                id: noteName
                selectByMouse: true
                selectionColor: "#134f5c"
                anchors.fill: parent
                anchors.margins: 8
                onTextChanged: {
                    interact_database.save_note(mainTextArea.text, noteName.text)
                }
                font.pixelSize: noteNameArea.height*0.6
                wrapMode: TextInput.NoWrap
                verticalAlignment: TextEdit.AlignVCenter
                horizontalAlignment: TextEdit.AlignLeft
                color: "#737272"
            }
        }

        Button {
            id: createNote
            anchors.margins: 8
            anchors.top: parent.top
            anchors.left: noteNameArea.right
            width: parent.width/20
            height: parent.height/20

            background: Rectangle{
                radius: 10
                color: "#444444"
            }

            contentItem: Text{
                text: "+"
                font.pixelSize: createNote.height*0.8
                color: "#737272"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                interact_database.create_new_note()
            }
        }

        Button {
            id: deleteNote
            anchors.margins: 8
            anchors.top: parent.top
            anchors.right: mainField.right
            width: parent.width/20
            height: parent.height/20

            background: Rectangle{
                radius: 10
                color: "#444444"
            }

            contentItem: Image {
                id: deleteImage
                source: "../icons/delete.png"
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                width: parent.width * 0.6
                height: parent.height * 0.6
            }
            onClicked: {
                interact_database.delete_note()
            }
        }

        Rectangle {
            id: allNotes
            width: parent.width * 0.08
            anchors.top: searchPanel.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 8
            radius: 20
            color: "#c3c5c9"

            ListView {
                id: listOfNotes
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: notes_info

                delegate: Rectangle {
                    width: listOfNotes.width
                    height: 64
                    radius: 12
                    color: ListView.isCurrentItem ? "#3a3a3a" : "#333333"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4
                        Text {
                            text: title
                            color: "#e0e0e0"
                            font.bold: true
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAnywhere
                        }

                        Text {
                            text: note
                            color: "#e0e0e0"
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAnywhere
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            interact_database.select_note(model.id)
                            listOfNotes.currentIndex = index
                        }
                    }
                }
            }
        }

        Rectangle {
            id: textScene
            anchors.top: searchPanel.bottom
            anchors.left: allNotes.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            radius: 20
            color: "#bcbcbc"

            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: rowLayout.width
                contentHeight: rowLayout.height
                clip: true
                flickableDirection: Flickable.VerticalFlick

                Row {
                    id: rowLayout
                    spacing: 0
                    width: parent.width

                    Rectangle {
                        id: lineNumbers
                        width: 40
                        color: "#e6e6e6"
                        height: mainTextArea.contentHeight

                        Text {
                            anchors.fill: parent
                            padding: 6
                            font.pixelSize: mainTextArea.font.pixelSize
                            color: "#777"
                            text: {
                                var lines = mainTextArea.text.split("\n")
                                var out = ""
                                for (var i = 1; i <= lines.length; i++)
                                    out += i + "\n"
                                return out
                            }
                            wrapMode: Text.Wrap
                        }

                    }

                    TextArea {
                        id: mainTextArea
                        width: textScene.width - lineNumbers.width
                        height: Math.max(textScene.height, contentHeight)
                        selectByMouse: true
                        wrapMode: TextArea.WordWrap
                        font.pixelSize: searchPanel.height * 0.5
                        color: "#2e3b3d"
                        background: Rectangle { color: "transparent" }

                        onTextChanged: {
                            interact_database.save_note(mainTextArea.text, noteName.text)
                        }
                    }
                }
            }
        }


    }
}
