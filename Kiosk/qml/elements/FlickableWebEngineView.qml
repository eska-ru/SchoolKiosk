// Copyright 2019 Utility Tool Kit Open Source Contributors
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License.  You may obtain a copy
// of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations under
// the License.
//
// Author: Innokentiy Alaytsev <alaitsev@gmail.com>
//
// File name: qml/Utk/Qml/FlickableWebEngineView.qml
//
// Description: The QML FlickableWebEngineView QtQuick 2 component.


import QtQuick 2.7

import QtWebEngine 1.3


Item {
    property alias url:webView.url

    property bool userDragImgEnabled: false;
    property bool userSelectEnabled: false;


    readonly property string kDisableUserDragCssId:
    "utk_qml_flickable_web_engine_view_disable_user_drag_css";

    readonly property string kDisableUserSelectCssId:
    "utk_qml_flickable_web_engine_view_disable_user_select_css";

    readonly property string kDisableUserDragCss:
    "{                                  \\                    \
        -webkit-user-drag: none;        \\                    \
        -khtml-user-drag: none;         \\                    \
        -moz-user-drag: none;           \\                    \
        -ms-user-drag: none;            \\                    \
        user-drag: none;                \\                    \
    }";

    readonly property string kDisableUserSelectCss:
    "{                                  \\                    \
        -webkit-touch-callout: none;    \\                    \
        -webkit-user-select: none;      \\                    \
        -khtml-user-select: none;       \\                    \
        -moz-user-select: none;         \\                    \
        -ms-user-select: none;          \\                    \
        user-select: none;              \\                    \
    }";


    WebEngineScript {
        id: disableUserDragScript;
        name: kDisableUserDragCssId;
        injectionPoint: WebEngineScript.DocumentReady;
        sourceCode: applyCssJavaScript ("img", kDisableUserDragCss, kDisableUserDragCssId);
        worldId: WebEngineScript.MainWorld;
    }

    WebEngineScript {
        id: disableUserSelectScript;
        name: kDisableUserSelectCssId;
        injectionPoint: WebEngineScript.DocumentReady;
        sourceCode: applyCssJavaScript ("body", kDisableUserSelectCss, kDisableUserSelectCssId);
        worldId: WebEngineScript.MainWorld;
    }


    Flickable {
        id: flickable;
        anchors.fill : parent;

        clip: true;

        WebEngineView {
            id: webView;

            anchors.fill : parent;

            scale: 1;

            Component.onCompleted: {
                webView.userScripts = currentUserScripts();

            }

            onLoadingChanged: {
                if (loadRequest.status !== WebEngineView.LoadSucceededStatus) {
                    return;
                }

                flickable.contentHeight = 0;
                flickable.contentWidth = flickable.width;

                runJavaScript (
                    "document.documentElement.scrollHeight;",
                    function (actualPageHeight) {
                        flickable.contentHeight = Math.max (
                            actualPageHeight, flickable.height);
                    });

                runJavaScript (
                    "document.documentElement.scrollWidth;",
                    function (actualPageWidth) {
                        flickable.contentWidth = Math.max (
                            actualPageWidth, flickable.width);
                    });

            }
        }
    }


    onUserDragImgEnabledChanged: {
        if (userDragImgEnabled &&
            (webView.loadRequest.status === WebEngineView.LoadSucceededStatus)) {
            runJavaScript (revertCssJavaScript (kDisableUserDragCssId));
        }
        else {
            webView.userScripts = currentUserScripts ();
        }
    }


    onUserSelectEnabledChanged: {
        if (userSelectEnabled &&
            (webView.loadRequest.status === WebEngineView.LoadSucceededStatus)) {
            runJavaScript (revertCssJavaScript (kDisableUserSelectCssId));
        }
        else {
            webView.userScripts = currentUserScripts ();
        }
    }


    function currentUserScripts () {
        var userScriptsToSkip = [
            disableUserDragScript.name,
            disableUserSelectScript.name
        ];

        var updatedUserScripts = [];

        for (var i in webView.userScripts) {
            var script = webView.userScripts[ i ];

            if (-1 === userScriptsToSkip.indexOf (script.name)) {
                updatedUserScripts.push (script);
            }
        }

        if (!userDragImgEnabled) {
            updatedUserScripts.push (disableUserDragScript);
        }

        if (!userSelectEnabled) {
            updatedUserScripts.push (disableUserSelectScript);
        }

        return updatedUserScripts;
    }


    function applyCssJavaScript (selector, css, cssId) {
        var applyCssJavaScript =
            "(function () {                                               \
                cssElement = document.createElement ('style');            \
                                                                          \
                head = document.head ||                                   \
                    document.getElementsByTagName ('head')[ 0 ];          \
                                                                          \
                head.appendChild (cssElement);                            \
                                                                          \
                cssElement.type = 'text/css';                             \
                cssElement.id = '%1';                                     \
                                                                          \
                if (cssElement.styleSheet)                                \
                {                                                         \
                    cssElement.styleSheet.cssText = '%2 %3';              \
                }                                                         \
                else                                                      \
                {                                                         \
                    cssElement.appendChild (                              \
                        document.createTextNode ('%2 %3'));               \
                }                                                         \
            })();";

        return applyCssJavaScript
            .arg (cssId)
            .arg (selector)
            .arg (css);
    }


    function revertCssJavaScript (cssId) {
        var revertCssJavaScript =
            "(function () {                                               \
                 var element = document.getElementById('%1');             \
                                                                          \
                 if (element) {                                           \
                     element.outerHTML = '';                              \
                                                                          \
                     delete element;                                      \
                 }                                                        \
            })()";

        return revertCssJavaScript.arg (cssId);
    }
}
