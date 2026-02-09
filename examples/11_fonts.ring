load "slint.ring"

oApp = new SlintApp {
    loadUI("11_fonts.slint")
    setCallback("tab-changed", :onTabChanged)
    show()
    run()
}

func onTabChanged
    nTab = oApp.callbackArg(1)
    oApp.setNumber("current-tab", nTab)
