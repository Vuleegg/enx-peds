
showTextUi = function(text, slovo)
    SendNUIMessage({
        action = "textUIshow", 
        text = text,
        slovo = slovo,
    })
end

exports('showTextUi', showTextUi)

DisableTextUi = function()
    SendNUIMessage({
        action = "textUIhide"
    })
end

exports('DisableTextUi', DisableTextUi)