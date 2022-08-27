return {
	InGui = true; -- Whether or not this is a GUI command. Regardless of true or false, the command is still available to be used as a chat command if active.
	Name = "CommandNameHere"; -- The name of the command, alternatively you can make the command get the name from the script name using script.Name.
	Credit = {}; -- Add the people who made this command here; Must be UserIds. Example: {123, 135};
	Description = {
		Short = "Command Short Description."; -- Description that is shown when you hover over the command in the UI.
		Long = "Makes the target player do something."; -- Description that is shown when you click on the command in the UI.
	};
	Color = Color3.new(1, 0.227450, 0.678431); -- The color of the command in the UI.
	Fields = {
		[1] = {
			Required = true; -- Whether or not this field is required.
			Internal = "target"; -- The internal name of the field; It will be used as fields.[Internal]; For example; Internal = "target" will result in fields.target
			Text = "Target"; -- The text that is shown in the UI for this field.
			Type = "Player"; -- To get the list of all types, you can check out the UICommand module.
			Changed = function(player, api, newval)
                -- This function is called when the client changes the value of the field.
                -- player is the player who changed the value; api is the general environment API; newval is the new value.
			end,
		};
	};
	SpecificPerm = nil; -- This commands need a specific permission.
	ForEveryone = false; -- This command can be ran by everyone.
	OnRun = function(player,fields,api) -- player is the user who executed the command; fields is a table of the fields made out of the 'Internal' part of the fields; api is the general environment API.
        local target = fields.target;



		-- Command Successful; return true
        -- Command Failed; return false

        return true
	end;
	OnOpen = function(player, api)
        -- This function is called when the client opens the command.
        -- player is the player who opened the command; api is the general environment API.
	end;
}
