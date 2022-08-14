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
@0bBinary - Backend Development (Client & Server engines)

For the contributors list, you can open the Credits frame and check it out freely.

---------------------------------------------------------
MAKE SURE THE LOADER YOU GOT CAME FROM THE AXELIUS GROUP (or @0bBinary for the Nightly module), OR DIRECTLY FROM THE SME GITHUB!
If you didn't, you likely have gotten a malicious clone of
Nano, which might add backdoored code alongside no auto-updates (which is bad).

Neither Axelius, SME, nor any of the contributors are responsible for damage that
might happen when using these malicious modules.
---------------------------------------------------------

]]

local debug = false; -- Enable debugging; This will disable auto-updates! Try to use the functions folder instead! (Recommended to be FALSE)
local nightly = false; -- Enable nightly builds; If you feel like trying out new versions before everyone ele, you can enable this; However, they are not guaranteed to be stable, and may corrupt the stored data.


-- Feel free to add your own branches, but make sure you know what you're doing!

-- Default branch IDs;
-- Stable / Main - 9215279390;
-- Unstable / Nightly - 10057728709;

local REQ = { -- Bypass the require ban that Roblox started imposing on smaller creators; if they play dirty, so will we - More info and reasoning: https://devforum.roblox.com/t/creator-marketplace-improving-model-safety/1795854
	UIRE = require;
}

local NANO = {
	MODULE = {
		ID = "9215279390";
		BETA = "10057728709";
		LOCAL = script.MainModule;
	}
}

if debug then
	REQ.UIRE(NANO.MODULE.LOCAL)(script);
elseif nightly then
	REQ.UIRE(tonumber(NANO.MODULE.BETA))(script);
else
	REQ.UIRE(tonumber(NANO.MODULE.ID))(script);
end