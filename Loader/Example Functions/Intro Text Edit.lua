local module = {_nano = {}}

function module._nano.load(api)
	api.Strings["Intro_Top"] = "Welcome!"
	api.Strings["Intro_Middle"] = "Thanks for visiting my cool game!"
end

return module
