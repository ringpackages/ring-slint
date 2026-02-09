load "slint.ring"

oApp = new SlintApp {
    loadUI("01_hello.slint")
    setCallback("greet", :onGreet)
    show()
    run()
}

func onGreet
    ? "Button clicked!"
    oApp.setString("message", "Hello from Ring!")
