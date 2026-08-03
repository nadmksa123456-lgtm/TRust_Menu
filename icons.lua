--[[
	TRust Menu - Icon Registry

	ضع ملفات الصور الرقمية داخل مجلد assets بهذا الشكل:
	assets/0.png ... assets/6.png

	بعد رفع الصور إلى Roblox، استبدل قيمة AssetId لكل أيقونة.
]]

local Icons = {
	[0] = { Id = 0, Name = "Logo",     File = "assets/0.png", AssetId = "rbxassetid://0" },
	[1] = { Id = 1, Name = "Cube",     File = "assets/1.png", AssetId = "rbxassetid://0" },
	[2] = { Id = 2, Name = "Scope",    File = "assets/2.png", AssetId = "rbxassetid://0" },
	[3] = { Id = 3, Name = "View",     File = "assets/3.png", AssetId = "rbxassetid://0" },
	[4] = { Id = 4, Name = "User",     File = "assets/4.png", AssetId = "rbxassetid://0" },
	[5] = { Id = 5, Name = "Settings", File = "assets/5.png", AssetId = "rbxassetid://0" },
	[6] = { Id = 6, Name = "Pick",     File = "assets/6.png", AssetId = "rbxassetid://0" },
}

Icons.Root = "."

local function keyFromCall(selfOrKey, key)
	-- يدعم Icons:Get(1) و Icons.Get(1).
	if selfOrKey == Icons then
		return key
	end

	return selfOrKey
end

local function validEntry(key)
	key = tonumber(key)
	return key and Icons[key] or nil
end

local function normalizeAssetId(assetId)
	local numericId
	if type(assetId) == "number" then
		numericId = assetId
	elseif type(assetId) == "string" then
		numericId = assetId:match("^rbxassetid://(%d+)$") or assetId:match("^(%d+)$")
	end

	numericId = tonumber(numericId)
	if not numericId or numericId <= 0 or numericId % 1 ~= 0 then
		return nil
	end

	return "rbxassetid://" .. tostring(numericId)
end

local function joinPath(root, fileName)
	root = tostring(root or ""):gsub("[\\/]+$", "")
	if root == "" or root == "." then
		return fileName
	end
	return root .. "/" .. fileName
end

function Icons.Get(selfOrKey, key)
	return validEntry(keyFromCall(selfOrKey, key))
end

function Icons.File(selfOrKey, key)
	local entry = validEntry(keyFromCall(selfOrKey, key))
	return entry and entry.File or nil
end

function Icons.SetRoot(selfOrRoot, root)
	if selfOrRoot ~= Icons then root = selfOrRoot end
	if root == nil or root == "" then root = "." end
	Icons.Root = tostring(root)
	return Icons.Root
end

function Icons.Path(selfOrKey, key, root)
	local requestedKey
	if selfOrKey == Icons then
		requestedKey = key
	else
		requestedKey = selfOrKey
		root = key
	end

	local entry = validEntry(requestedKey)
	return entry and joinPath(root or Icons.Root, entry.File) or nil
end

function Icons.AssetId(selfOrKey, key)
	local entry = validEntry(keyFromCall(selfOrKey, key))
	return entry and normalizeAssetId(entry.AssetId) or nil
end

function Icons.Resolve(selfOrKey, key, root)
	local requestedKey
	if selfOrKey == Icons then
		requestedKey = key
	else
		requestedKey = selfOrKey
		root = key
	end

	local entry = validEntry(requestedKey)
	if not entry then
		return nil
	end

	-- AssetId المرفوع إلى Roblox هو الخيار الأفضل والأكثر توافقًا.
	local assetId = normalizeAssetId(entry.AssetId)
	if assetId then return assetId end

	-- دعم اختياري للملفات المحلية في البيئات التي توفر getcustomasset.
	local customAsset = getcustomasset or getsynasset
	if type(customAsset) == "function" then
		local filePath = joinPath(root or Icons.Root, entry.File)
		local fileExists = true
		if type(isfile) == "function" then
			local ok, exists = pcall(isfile, filePath)
			fileExists = ok and exists
		end
		if fileExists then
			local ok, result = pcall(customAsset, filePath)
			if ok and type(result) == "string" and result ~= "" then
				return result
			end
		end
	end

	-- لا نعيد rbxassetid://0 لأنه عنصر نائب غير قابل للعرض.
	return nil
end

return Icons
