--[[
IT IS HIGHLY RECOMMENDED THAT YOU PLACE THE LOADER IN SERVERSCRIPTSERVICE!

Sezei.me + Axelius - A collab admin system written using NxEngine
::NANO:: [aka Project AGR]

-----------------------------

Nano originally was supposed to be a remake of the older system created by 0bBinary, called AGB (or AdminGUI Basic),
hence the original name; AGR (AdminGUI Rewritten)

After some thinking, we have decided to rename the system to Nano, due to how non-intrusive the system is.

Nano is a system created for the simplicity of use, while providing a modern, sleek and beautiful-to-look-at UI.

Info for developers can be found in the Developer Info localscript in the loader.

-----------------------------

Lead Contributors;
@Cytrexon - Frontend Development (Commands, UI design)
@0bBinary - Backend Development (Engine, UI framework)

For the contributors list, you can open the Credits frame and check it out freely.
]]

local debug = false; -- Enable debugging; This will disable auto-updates! Try to use the functions folder instead!

if debug then
	require(script.MainModule)(script);
else
	require(9215279390)(script);
end