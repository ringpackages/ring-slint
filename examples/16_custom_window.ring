load "slint.ring"

oApp = new SlintApp {
    loadUI("16_custom_window.slint")
    setCallback("close-window", :onClose)
    setCallback("opacity-changed", :onOpacityChanged)
    setCallback("color-selected", :onColorSelected)
    setCallback("start-drag", :onStartDrag)
    show()
    run()
}

func onClose
    ? "Closing translucent window"
    oApp.quit()

func onOpacityChanged
    nOpacity = oApp.callbackArg(1)
    oApp.setNumber("window-opacity", nOpacity)
    ? "Opacity: " + (nOpacity * 100) + "%"

func onColorSelected
    aNames = ["Red", "Amber", "Green", "Purple", "Cyan"]
    nIndex = oApp.callbackArg(1)
    ? "Accent: " + aNames[nIndex + 1]

func onStartDrag
    oApp.windowDrag()
