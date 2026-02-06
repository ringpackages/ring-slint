load "slint.ring"

oApp = new SlintApp {
    loadUI("03_properties.slint")
    set("user-name", "Ring Developer")
    set("user-age", 25)
    setBool("is-active", true)
    setCallback("show-info", :onShowInfo)
    setCallback("toggle-active", :onToggleActive)
    show()
    run()
}

func onShowInfo
    cName = oApp.getProperty("user-name")
    nAge = oApp.getProperty("user-age")
    bActive = oApp.getProperty("is-active")
    ? "Name: " + cName
    ? "Age: " + nAge
    ? "Active: " + bActive

func onToggleActive
    bActive = oApp.getProperty("is-active")
    oApp.setBool("is-active", !bActive)
