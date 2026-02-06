load "slint.ring"

cSlintSource = '
global Theme {
    out property <color> bg-base: #07070a;
    out property <color> bg-surface: #0f1014;
    out property <color> bg-elevated: #151519;
    out property <color> bg-overlay: #1a1b23;
    out property <color> primary: #8b5cf6;
    out property <color> primary-muted: #8b5cf640;
    out property <color> success: #22c55e;
    out property <color> text-primary: #f8fafc;
    out property <color> text-secondary: #94a3b8;
    out property <color> text-muted: #64748b;
    out property <color> border-subtle: #ffffff10;
    out property <color> border-muted: #ffffff15;
    out property <length> radius-md: 8px;
    out property <length> radius-lg: 12px;
    out property <length> space-sm: 8px;
    out property <length> space-md: 12px;
    out property <length> space-lg: 16px;
    out property <length> space-xl: 24px;
}

component ActionButton inherits Rectangle {
    in property <string> text;
    in property <bool> primary: false;
    callback clicked;
    
    height: 44px;
    min-width: 100px;
    horizontal-stretch: 1;
    border-radius: Theme.radius-md;
    background: primary 
        ? (touch.pressed ? #7c3aed : touch.has-hover ? #9366f9 : Theme.primary)
        : (touch.pressed ? Theme.bg-overlay : touch.has-hover ? Theme.bg-elevated : Theme.bg-surface);
    border-width: primary ? 0 : 1px;
    border-color: Theme.border-muted;
    
    animate background { duration: 150ms; easing: ease-out; }
    
    touch := TouchArea {
        mouse-cursor: pointer;
        clicked => { root.clicked(); }
    }
    
    Text {
        text: root.text;
        font-size: 13px;
        font-weight: 500;
        color: primary ? Theme.text-primary : Theme.text-secondary;
        horizontal-alignment: center;
        vertical-alignment: center;
    }
}

component StyledInput inherits Rectangle {
    in property <string> placeholder;
    in-out property <string> text;
    
    height: 48px;
    border-radius: Theme.radius-md;
    background: input.has-focus ? Theme.bg-elevated : Theme.bg-surface;
    border-width: input.has-focus ? 2px : 1px;
    border-color: input.has-focus ? Theme.primary : Theme.border-muted;
    
    animate border-color { duration: 150ms; }
    animate background { duration: 150ms; }
    
    HorizontalLayout {
        padding-left: Theme.space-lg;
        padding-right: Theme.space-lg;
        
        input := TextInput {
            text <=> root.text;
            font-size: 14px;
            color: Theme.text-primary;
            vertical-alignment: center;
        }
    }
    
    if input.text == "": Text {
        x: Theme.space-lg;
        text: placeholder;
        font-size: 14px;
        color: Theme.text-muted;
        vertical-alignment: center;
    }
}

export component DynamicApp inherits Window {
    title: "Dynamic UI";
    width: 440px;
    height: 400px;
    background: Theme.bg-base;
    
    callback greet();
    callback update-message(string);
    
    in-out property <string> user-name: "";
    in-out property <string> greeting: "Enter your name and click Greet!";
    
    VerticalLayout {
        padding: Theme.space-xl;
        spacing: Theme.space-lg;
        
        HorizontalLayout {
            spacing: Theme.space-md;
            
            Rectangle {
                width: 48px;
                height: 48px;
                border-radius: Theme.radius-md;
                background: @linear-gradient(135deg, Theme.primary 0%, #6366f1 100%);
                
                drop-shadow-blur: 12px;
                drop-shadow-color: Theme.primary.with-alpha(0.4);
                
                Text {
                    text: "⚡";
                    font-size: 24px;
                    horizontal-alignment: center;
                    vertical-alignment: center;
                }
            }
            
            VerticalLayout {
                alignment: center;
                spacing: 2px;
                
                Text {
                    text: "Dynamic Slint UI";
                    font-size: 22px;
                    font-weight: 700;
                    color: Theme.text-primary;
                }
                
                Text {
                    text: "Loaded from a Ring string";
                    font-size: 12px;
                    color: Theme.text-muted;
                }
            }
        }
        
        Rectangle {
            vertical-stretch: 1;
            background: Theme.bg-surface;
            border-radius: Theme.radius-lg;
            border-width: 1px;
            border-color: Theme.border-subtle;
            
            VerticalLayout {
                padding: Theme.space-xl;
                alignment: center;
                
                Text {
                    text: greeting;
                    font-size: 18px;
                    font-weight: 500;
                    color: Theme.text-primary;
                    horizontal-alignment: center;
                    wrap: word-wrap;
                }
            }
        }
        
        Rectangle {
            background: Theme.bg-surface;
            border-radius: Theme.radius-lg;
            border-width: 1px;
            border-color: Theme.border-subtle;
            
            VerticalLayout {
                padding: Theme.space-lg;
                spacing: Theme.space-md;
                
                StyledInput {
                    placeholder: "Enter your name...";
                    text <=> user-name;
                }
                
                HorizontalLayout {
                    spacing: Theme.space-sm;
                    
                    ActionButton {
                        text: "👋 Greet";
                        primary: true;
                        clicked => { greet(); }
                    }
                    
                    ActionButton {
                        text: "Hello";
                        clicked => { update-message("Hello there!"); }
                    }
                    
                    ActionButton {
                        text: "Goodbye";
                        clicked => { update-message("Goodbye, see you later!"); }
                    }
                }
            }
        }
    }
}
'

? "Loading Slint UI from string..."

oApp = new SlintApp {
    loadUIString(cSlintSource, "dynamic://app.slint")
    setCallback("greet", :onGreet)
    setCallback("update-message", :onUpdateMessage)
    show()
    run()
}

? "UI compiled successfully!"

func onGreet
    cName = oApp.getProperty("user-name")
    if len(cName) > 0
        oApp.set("greeting", "Hello, " + cName + "!")
    else
        oApp.set("greeting", "Please enter your name first!")
    ok
    ? "Greeted: " + cName

func onUpdateMessage
    cMessage = oApp.callbackArg(1)
    oApp.set("greeting", cMessage)
    ? "Message updated: " + cMessage
