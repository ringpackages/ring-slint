load "slint.ring"

nCount = 0

oApp = new SlintApp {
    setStyle("native")
    loadUI("02_counter.slint")
    setCallback("increment", :onIncrement)
    setCallback("decrement", :onDecrement)
    setCallback("reset", :onReset)
    show()
    run()
}

func onIncrement
    nCount++
    oApp.set("counter", nCount)

func onDecrement
    nCount--
    oApp.set("counter", nCount)

func onReset
    nCount = 0
    oApp.set("counter", nCount)
