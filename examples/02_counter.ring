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
    oApp.setNumber("counter", nCount)

func onDecrement
    nCount--
    oApp.setNumber("counter", nCount)

func onReset
    nCount = 0
    oApp.setNumber("counter", nCount)
