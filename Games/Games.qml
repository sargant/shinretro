import QtQuick 2.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.15
import "qrc:/qmlutils" as PegasusUtils
import "../Global"

FocusScope {

    property int currentGameIndex: 0
    property var currentGame: {
        if (gv_games.count === 0)
            return null;
        if (games.state === "favorites")
            return currentCollection.games.get(filteredGamesFav.mapToSource(currentGameIndex))
        if (games.state === "multiplayer")
            return currentCollection.games.get(filteredGamesMulti.mapToSource(currentGameIndex))    
        return currentCollection.games.get(currentGameIndex)
    }

    property int gridVR: {
        if (gamesGridVR ===  "dynamic")
            return Math.min(Math.max(parseInt((gv_games.count +10) /20), 1), 5);
        else return  gamesGridVR
    }

    focus: games.focus
    state: "all"

    SortFilterProxyModel {
        id: filteredGamesFav
        sourceModel: currentCollection.games
        filters: ValueFilter { roleName: "favorite"; value: true; }
    }
    SortFilterProxyModel {
        id: filteredGamesMulti
        sourceModel: currentCollection.games
        filters: RangeFilter { roleName: "players"; minimumValue: 2; }
    }

    Behavior on focus {
        ParallelAnimation {
            PropertyAnimation {
                target: skew_color
                property: "anchors.leftMargin"
                from: parent.width * 0.97
                to: parent.width * 0.77
                duration: 250
            }
        }
    }

    // Background image
    BackgroundImage {
        id: backgroundimage
        game: currentGame
        anchors {
            left: parent.left; right: parent.right
            top: parent.top; bottom: parent.bottom
        }
        opacity: 0.255
    }

    
    // Skewed background
    Rectangle {
        id: skew_color
        readonly property var touch_colorBright: dataConsoles[clearShortname(currentCollection.shortName)].color
        readonly property var touch_colorDimm: touch_colorBright.replace(/#/g, "#56");
        readonly property var touch_color: {
            if (accentColor == "bright") {
                return touch_colorBright;
            } else {
                return touch_colorDimm;
            }
        }
        width: parent.width * 0.42
        height: parent.height
        antialiasing: true
        anchors {
            left: parent.left
            leftMargin: parent.width * 0.77
        }
        color: touch_color
        Behavior on color {
            ColorAnimation { duration: 250; }
        }

        transform: Matrix4x4 {
            property real a: 12 * Math.PI / 180
            matrix: Qt.matrix4x4(
                1,      -Math.tan(a),       0,      0,
                0,      1,                  0,      0,
                0,      0,                  1,      0,
                0,      0,                  0,      1
            )
        }
    }

    // Content
    Item {
        width: parent.width * 0.90
        anchors {
            top: parent.top
            bottom: parent.bottom
            bottomMargin: vpx(30)
            horizontalCenter: parent.horizontalCenter
        }

        // Game details
        Item {
            id: item_game_details
            width: parent.width
            height: parent.height * 0.5
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            Item {
                anchors.fill: parent

                // All game information
                Component {
                    id: cpnt_gameList_details

                    Item {
                        readonly property var currentGameGenre: currentGame.genre.split(" / ") || ""
                        anchors.fill: parent

                        // RELEASE DATE
                        Text {
                            id: txt_releaseYear
                            anchors {
                                top: parent.top; topMargin: -vpx(20)
                            }

                            text: currentGame.releaseYear || dataText[lang].games_na
                            font {
                                family: global.fonts.sans
                                weight: Font.Black
                                italic: true
                                pixelSize: vpx(140)
                            }
                            color: colorScheme[theme].main
                            layer.enabled: true
                            layer.effect: DropShadow {
                                spread: 1.0
                                verticalOffset: 5
                                horizontalOffset: 5
                                color: colorScheme[theme].secondary
                                radius: 5
                                samples: 11
                            }

                            Behavior on text {
                                PropertyAnimation {
                                    target: txt_releaseYear
                                    property: "opacity"
                                    from: 0
                                    to: 1
                                    duration: 600
                                    easing.type: Easing.OutExpo
                                }
                            }

                        }


                        // TITLE + DEVELOPER + PLAYERS + GENRES + DESCRIPTION
                        Column {
                            spacing: vpx(10)
                            width: parent.width
                            anchors {
                                bottom: parent.bottom; bottomMargin: vpx(20)
                            }

                            Text {
                                width: parent.width
                                text: currentGame.title
                                elide: Text.ElideRight
                                font {
                                    family: robotoSlabRegular.name
                                    pixelSize: vpx(32  * fontScalingFactor)
                                }
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                color: colorScheme[theme].text
                            }

                            Row {
                                spacing: vpx(5)

                                Text {
                                    text: dataText[lang].games_developedBy
                                    font {
                                        family: global.fonts.sans
                                        weight: Font.Light
                                        italic: true
                                        pixelSize: vpx(14  * fontScalingFactor)
                                    }
                                    color: colorScheme[theme].accent
                                }

                                Text {
                                    text: currentGame.developer
                                    font {
                                        family: global.fonts.sans
                                        weight: Font.Medium
                                        pixelSize: vpx(14  * fontScalingFactor)
                                    }
                                    color: colorScheme[theme].text
                                }
                            }

                            Row {
                                spacing: vpx(5)
                                // RATING
                                RatingStars {
                                    readonly property var rating: (currentGame.rating *5).toFixed(1)
                                    // anchors {
                                    //     top: parent.top; topMargin: parent.height * 0.1
                                    //     right: parent.right
                                    // }
                                }
                            }

                            Row {
                                spacing: vpx(10)

                                Rectangle {
                                    width: txt_players.contentWidth + vpx(20)
                                    height: txt_players.contentHeight + vpx(10)
                                    color: colorScheme[theme].secondary
                                    border {
                                        width: vpx(1)
                                        color: colorScheme[theme].secondary
                                    }

                                    Text {
                                        id: txt_players
                                        property var convertPlayer: currentGame.players > 1 ? "1-"+currentGame.players+" "+dataText[lang].games_players : dataText[lang].games_player
                                        anchors.centerIn: parent
                                        text: convertPlayer
                                        font {
                                            family: global.fonts.sans
                                            weight: Font.Black
                                            pixelSize: vpx(12  * fontScalingFactor)
                                        }
                                        color: colorScheme[theme].text
                                    }
                                }

                                Rectangle {
                                    width: txt_favorited.contentWidth + vpx(20)
                                    height: txt_favorited.contentHeight + vpx(10)
                                    color: colorScheme[theme].favorite.replace(/#/g, "#33");

                                    Text {
                                        id: txt_favorited
                                        anchors.centerIn: parent
                                        text: dataText[lang].games_favorited
                                        font {
                                            family: global.fonts.sans
                                            weight: Font.Black
                                            pixelSize: vpx(12  * fontScalingFactor)
                                        }
                                        color: colorScheme[theme].favorite
                                    }
                                    visible: currentGame.favorite
                                }

                                Repeater {
                                    model: currentGameGenre
                                    delegate: Rectangle {
                                        width: txt_genre.contentWidth + vpx(20)
                                        height: txt_genre.contentHeight + vpx(10)
                                        color: colorScheme[theme].secondary
                                        border {
                                            width: vpx(1)
                                            color: colorScheme[theme].secondary
                                        }

                                        Text {
                                            id: txt_genre
                                            anchors.centerIn: parent
                                            text: modelData
                                            font {
                                                family: global.fonts.sans
                                                weight: Font.Medium
                                                pixelSize: vpx(12  * fontScalingFactor)
                                            }
                                            color: colorScheme[theme].text
                                        }
                                        visible: (modelData !== "")
                                    }
                                }
                            }

                            //Description
                            Item {
                                width: parent.width
                                height: vpx(100)

                                PegasusUtils.AutoScroll {
                                    anchors.fill: parent
                                    Text {
                                        id: txt_game_description
                                        width: parent.width
                                        text: (currentGame.description || currentGame.summary) ? (currentGame.description || currentGame.summary) : dataText[lang].games_withoutDescription
                                        font {
                                            family: global.fonts.condensed
                                            weight: Font.Light
                                            pixelSize: vpx(14  * fontScalingFactor)
                                        }
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignJustify
                                        color: colorScheme[theme].text
                                    }
                                }
                            }
                        }
                    }
                }

                Loader {
                    id: loader_gameList_details
                    width: {
                        if (gridVR >= 3)
                            parent.width * 0.31
                        else parent.width * 0.67
                    }
                    height: {
                        if (gridVR >= 3)
                            parent.height * 0.95
                        else parent.height
                    }
                        
                    anchors {
                        top: {
                            if (gridVR >= 3)
                                parent.bottom
                            else parent.top
                        }
                        right: {
                            if (gridVR >= 3)
                                parent.right
                        }
                        left: {
                        if (gridVR < 3)
                                parent.left                         
                        }
                    }
                    asynchronous: true
                    sourceComponent: cpnt_gameList_details
                    active: games.focus && currentGame !== null
                    visible: status === Loader.Ready
                }
                Item {
                    width: parent.width * 0.31
                    height: parent.height * 0.9
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    Loader {
                        id: loader_top_video
                        anchors.fill: parent

                        asynchronous: true
                        sourceComponent: GameItemTopVideo  {}
                        active: games.focus && gamesLayout === "BoxArt-Grid"
                        visible: status === Loader.Ready
                    }
                    Loader {
                        id: loader_top_boxart
                        anchors.fill: parent

                        asynchronous: true
                        sourceComponent: GameItemTopBoxFront {}
                        active: games.focus && gamesLayout === "Screenshot-Grid"
                        visible: status === Loader.Ready
                    }
                }

            }

            visible: currentGame !== null
        }

        // No favorite found
        Item {
            anchors.centerIn: parent
            visible: currentGame === null && (games.state === "favorites")
            Rectangle {
                Text {
                    anchors.centerIn: parent
                    text: dataText[lang].global_noFavorites
                    color: colorScheme[theme].accentalt
                    font {
                        family: robotoSlabRegular.name
                        pixelSize: vpx(42  * fontScalingFactor)
                    }
                }
            }
        }
        // No multiplayer games found
        Item {
            anchors.centerIn: parent
            visible: currentGame === null && (games.state === "multiplayer")
            Rectangle {
                Text {
                    anchors.centerIn: parent
                    text: dataText[lang].global_noMultiplayer
                    color: colorScheme[theme].accentalt
                    font {
                        family: robotoSlabRegular.name
                        pixelSize: vpx(42  * fontScalingFactor)
                    }
                }
            }
        }


        // Games
        Item {
            id: games_bottom
            width: {
                if (gridVR >= 3)
                        parent.width * 0.67
                else parent.width
            }
            height: {
                if (gridVR >= 3)
                    parent.height * 0.9
                else parent.height * 0.5
            }
            anchors {
                bottom: parent.bottom
            }

            GridView {
                id: gv_games
                width: parent.width
                height: parent.height * 0.85
                cellWidth: width /gamesGridIPR
                cellHeight: height /gridVR
                anchors.horizontalCenter: parent.horizontalCenter

                clip: true

                preferredHighlightBegin: height
                preferredHighlightEnd: height * 0.5

                currentIndex: currentGameIndex
                onCurrentIndexChanged: currentGameIndex = currentIndex

                model: {
                    if (games.state === "favorites")
                        return filteredGamesFav
                    if (games.state === "multiplayer")
                        return filteredGamesMulti    
                    return currentCollection.games
                }
                delegate: Item {
                    property bool isCurrentItem: GridView.isCurrentItem
                    property bool isFocused: games.focus
                    property bool doubleFocus: isFocused && isCurrentItem

                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight

                    Item {
                        anchors {
                            fill: parent
                            margins: vpx(5)
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: colorScheme[theme].background
                            visible: !loader_gameList_boxart.visible && !loader_gameList_screenshot.visible 
                        }

                        Loader {
                            id: loader_gameList_boxart
                            anchors.fill: parent

                            asynchronous: true
                            sourceComponent: GameItemGridBoxFront {}
                            active: games.focus && gamesLayout === "BoxArt-Grid"
                            visible: status === Loader.Ready
                        }
                        Loader {
                            id: loader_gameList_screenshot
                            anchors.fill: parent

                            asynchronous: true
                            sourceComponent: GameItemGridScreenshot {selected: GridView.isCurrentItem}
                            active: games.focus && gamesLayout === "Screenshot-Grid"
                            visible: status === Loader.Ready
                        }
                    }
                }

                highlightRangeMode: GridView.ApplyRange
                snapMode: GridView.NoSnap

                focus: games.focus

                Component.onCompleted: {
                    positionViewAtIndex(currentGameIndex, GridView.SnapPosition)
                    gv_games.currentIndex = api.memory.get('gameIndex') || 0;
                }

                Keys.onPressed: {

                    if (event.isAutoRepeat) {
                        return
                    }

                    if (api.keys.isAccept(event)) {
                        //Accept game sound
                        sfxPlay.play();
                        event.accepted = true;
                        if (currentGame !== null) {
                            api.memory.set("currentCollectionIndex", currentCollectionIndex)
                            api.memory.set("currentMenuIndex", currentMenuIndex)
                            api.memory.set('gameIndex', gv_games.currentIndex);
                            currentGame.launch()
                        }
                    }

                    if (api.keys.isFilters(event)) {
                        //Accept game sound
                        sfxBack.play();
                        event.accepted = true;
                        if (games.state === "all") {
                            games.state = "favorites"
                        }
                        else if (games.state === "favorites") {
                            games.state = "multiplayer"
                        }
                        else {
                            games.state = "all"
                        }
                    }

                    if (api.keys.isCancel(event)) {
                        //Accept game sound
                        sfxBack.play();
                        event.accepted = true;
                        currentMenuIndex = 2
                    }

                    if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        if (currentGame !== null) {
                            currentGame.favorite = !currentGame.favorite
                        }
                    }

                    if (event.key == Qt.Key_Left ) {
                        //navigation sound
                        sfxNav.play();
                    }

                    if (event.key == Qt.Key_Right) {
                        //navigation sound
                        sfxNav.play();
                    }
                    if (event.key == Qt.Key_Down) {
                        //navigation sound
                        sfxNav.play();
                    }

                    if (event.key == Qt.Key_Up) {
                        sfxNav.play();
                    }
                }

                Keys.onReleased: {
                    if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
                        if (event.isAutoRepeat) {
                            event.accepted = false;
                            return;
                        }
                        else{
                            event.accepted = true;
                            sfxNav.play();
                            if (api.keys.isPageUp(event)) {
                                if (currentCollectionIndex >= api.collections.count - 1) {
                                    currentCollectionIndex = 0;
                                }
                                else {
                                    currentCollectionIndex++;
                                }
                            }   
                            else {
                                if (currentCollectionIndex <= 0)
                                    currentCollectionIndex = api.collections.count - 1
                                else
                                    currentCollectionIndex--;
                            }
                            api.memory.set("currentCollectionIndex", currentCollectionIndex)
                            currentGameIndex = 0
                        }
                    }
                }
            }
            
            //Navigation bar
            Component {
                id: cpnt_helper_nav
                Item {
                    Rectangle {
                        property int heightBar: parent.height - vpx(50)
                        anchors {
                            left: parent.left; 
                            leftMargin: parent.width + 30
                            top: parent.top; topMargin: vpx(6)
                        }
                        width: vpx(2)
                        height: heightBar * ( (currentGameIndex + 1) / gv_games.count )
                        color: colorScheme[theme].accent
                    }
                }
            }

            Loader {
                id: loader_helper_nav
                width: vpx(50)
                height: gv_games.height
                anchors {
                    right: gv_games.left; rightMargin: vpx(25)
                    top: gv_games.top;
                }
                asynchronous: true
                sourceComponent: cpnt_helper_nav
                active: games.focus && currentGame !== null
                visible: status === Loader.Ready
            }

        }

        // Bottom (buttons and counter)
        Item {
            width: parent.width
            height: vpx(30)
            anchors.bottom: parent.bottom

            Row {
                visible: osc === "No"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                spacing: vpx(20)

                Controls {
                    id: button_R

                    message: dataText[lang].global_back

                    text_color: colorScheme[theme].cancel
                    front_color: colorScheme[theme].cancel.replace(/#/g, "#26");
                    back_color: colorScheme[theme].cancel.replace(/#/g, "#26");
                    input_button: osdScheme[controlScheme].BTNR
                }

                Controls {
                    id: button_U

                    message: {
                        if (games.state === "favorites")
                            return dataText[lang].games_filterFavorites
                        if (games.state === "multiplayer")
                            return dataText[lang].games_filterMultiplayer    
                        return dataText[lang].games_filterAll
                    }
                    text_color: colorScheme[theme].filters
                    front_color: colorScheme[theme].filters.replace(/#/g, "#26");
                    back_color: colorScheme[theme].filters.replace(/#/g, "#26");
                    input_button: osdScheme[controlScheme].BTNU
                }

                Controls {
                    id: button_L

                    message: currentGame !== null && currentGame.favorite ? dataText[lang].games_removeFavorite : dataText[lang].games_addFavorite

                    text_color: colorScheme[theme].details
                    front_color: colorScheme[theme].details.replace(/#/g, "#26");
                    back_color: colorScheme[theme].details.replace(/#/g, "#26");
                    input_button: osdScheme[controlScheme].BTNL

                    visible: currentGame !== null
                }
            }

            Text {
                id: helper_count
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right;
                }
                text: (currentGameIndex + 1)+"/"+gv_games.count
                color: colorScheme[theme].text
                font {
                    family: robotoSlabLight.name
                    pixelSize: vpx(14  * fontScalingFactor)
                }
            }
        }
    }
}
