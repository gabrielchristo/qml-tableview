import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import Qt.labs.qmlmodels 1.0

ApplicationWindow {

    id: root
    visible: true
    width: 640; height: 480
    title: qsTr("QML TableView Example - by Gabriel Christo")

    property var combobox_model: ["Value 1", "Value 2", "Value 3"] // combobox stringlist
    property var horizontal_header_data: ["Combobox", "Checkbox", "TextFields", "Spinbox", "Slider"] // table header

    // updates model's row number
    function update_table_model(new_rows_number){
        // row data model (must be paired with table model)
        let row_data = {
            combobox_index: 0,
            checkbox_state: 0,
            textfield_1_string: "",
            textfield_2_string: "",
            spinbox_value: 0,
            slider_value: 0
        }
        if(new_rows_number === 0 || isNaN(new_rows_number)){
            tablemodel.clear()
        }
        else if(new_rows_number > tablemodel.rowCount){
            for(let i = tablemodel.rowCount; i < new_rows_number; i++) tablemodel.appendRow(row_data)
        }
        else if(new_rows_number < tablemodel.rowCount){
            tablemodel.removeRow(new_rows_number, tablemodel.rowCount - new_rows_number)
        }
        tableview.forceLayout() // forces tableview update
    }

    // file dialog to pick json file
    FileDialog {
        id: filedialog
        title: "Select a json file"
        folder: shortcuts.documents
        nameFilters: ["Json (*.json)"]
        onAccepted: {
            tablemodel.rows = JSON.parse(JsonUtils.getFileContent(filedialog.fileUrl)) // updates model with json data
            rowsnumber.text = tablemodel.rowCount // updating textfield value
        }
    }

    Column {

        height: parent.height; width: parent.width

        RowLayout {
            spacing: 10
            height: 0.1 * parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            Label { text: "Rows:" }
            TextField {
                id: rowsnumber; text: "0"; selectByMouse: true
                validator: IntValidator{}
                onTextEdited: update_table_model(parseInt(this.text))
            }
            Button {
                text: "Create Json"
                // passing table model data as string to backend
                onClicked:{
                    JsonUtils.saveJson(JSON.stringify(tablemodel.rows))
                 }
            }
            Button {
                text: "Load Json"
                onClicked: filedialog.open() // dialog to select json file
            }
        }

        TableView {
            id: tableview
            width: 0.85 * parent.width; height: 0.8 * parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true // clip content to table dimensions
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: false // forces table to destroy delegates
            columnSpacing: 1 // in case of big/row spacing, you need to take care of width/height providers (to get along with it)

            // margins to vertical/horizontal headers
            leftMargin: verticalHeader.width
            topMargin: horizontalHeader.height

            // scrollbar config
            ScrollBar.horizontal: ScrollBar{
                //policy: "AlwaysOn"
            }
            ScrollBar.vertical: ScrollBar{
                //policy: "AlwaysOn"
            }
            ScrollIndicator.horizontal: ScrollIndicator { }
            ScrollIndicator.vertical: ScrollIndicator { }

            // width and height providers
            property var columnWidths: [100, 80, 120, 100, 100]
            columnWidthProvider: function(column){ return columnWidths[column] }
            rowHeightProvider: function (column) { return 25 }

            // table horizontal header
            Row {
                id: horizontalHeader
                y: tableview.contentY
                z: 2
                Repeater {
                    model: tableview.columns
                    Label {
                        width: tableview.columnWidthProvider(modelData); height: 30
                        text: horizontal_header_data[index]
                        padding: 10
                        verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        background: Rectangle { color: "#b5b5b5" }
                    }
                }
            }

            // table vertical header
            Column {
                id: verticalHeader
                x: tableview.contentX
                z: 2
                Repeater {
                    model: tableview.rows
                    Label {
                        width: 30; height: tableview.rowHeightProvider(modelData)
                        text: index
                        padding: 10
                        verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                        color: "white"
                        background: Rectangle { color: "#b5b5b5" }
                    }
                }
            }

            // defining model columns' roles
            model: TableModel {
                id: tablemodel
                TableModelColumn{ display: "combobox_index" }
                TableModelColumn{ display: "checkbox_state" }
                TableModelColumn{ display: "textfield_1_string"; edit: "textfield_2_string" } // using two roles
                TableModelColumn{ display: "spinbox_value" }
                TableModelColumn{ display: "slider_value" }
            }

            // defining custom delegates and model connection
            delegate: DelegateChooser {
                DelegateChoice {
                    column: 0
                    delegate: ComboBox { // here we need to be careful: conflict between table model and combobox model
                        currentIndex: display
                        model: combobox_model
                        onActivated: display = this.currentIndex // we've only used 'display' keyword, because combobox model doesnt have this as role name
                    }
                }
                DelegateChoice {
                    column: 1
                    delegate: CheckBox {
                        checkState: model.display
                        onToggled: model.display = this.checkState
                    }
                }
                DelegateChoice {
                    column: 2
                    delegate: RowLayout { // two textfields in same column model
                        spacing: 0
                        TextField {
                            implicitWidth: parent.width / 2
                            text: model.display
                            placeholderText: "x"
                            selectByMouse: true
                            onTextEdited: model.display = this.text
                        }
                        TextField {
                            implicitWidth: parent.width / 2
                            text: model.edit
                            placeholderText: "y"
                            selectByMouse: true
                            onTextEdited: model.edit = this.text
                        }
                    }
                }
                DelegateChoice {
                    column: 3
                    delegate: SpinBox {
                        value: model.display
                        from: 0; to: 99
                        stepSize: 1
                        onValueModified: model.display = this.value
                    }
                }
                DelegateChoice {
                    column: 4
                    delegate: Slider {
                        value: model.display
                        from: 0; to: 32
                        stepSize: 1
                        onMoved: model.display = this.value
                    }
                }
            }
        }

    }

}
