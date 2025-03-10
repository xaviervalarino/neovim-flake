local M = {}

---find_opt_file({'lua/x.lua'}) returns the first match of '(packpath)/opt/*/lua/x.lua'
---@param relPaths string[] @return string? pack_name, string? full_path
---@return boolean found,  string|string[] pathOrTriedPaths, string? pack_name
local function find_opt_file(relPaths)
  local triedPaths = {}
  -- I need to look for {pack}/pack/*/opt/{pack_name}/lua/...
  for _, packpath in ipairs(vim.opt.packpath:get()) do
    local groupsPath = vim.fs.joinpath(packpath, 'pack')
    if vim.fn.isdirectory(groupsPath) == 0 then
      goto continue
    end

    for group, typ in vim.fs.dir(groupsPath) do
      if typ ~= "directory" then
        goto continue3
      end

      local groupPath = vim.fs.joinpath(groupsPath, group)
      for pack_name, typ in vim.fs.dir(groupPath .. '/opt') do
        if typ ~= "directory" then
          goto continue4
        end

        local pack_path = vim.fs.joinpath(groupPath, 'opt', pack_name)
        for _, relPath in ipairs(relPaths) do
          local fullPath = vim.fs.joinpath(pack_path, relPath)
          if vim.fn.filereadable(fullPath) == 1 then
            return true, fullPath, pack_name
          end

          table.insert(triedPaths, fullPath)
        end

        ::continue4::
      end
      ::continue3::
    end
    ::continue::
  end

  return false, triedPaths
end

---@param mod string
---@return nil|string|fun() loader
function M.search(mod)
  local segments = {}
  for str in string.gmatch(mod, '[^.]+') do
    table.insert(segments, str)
  end

  local p = vim.fs.joinpath('lua', unpack(segments))
  local found, file_path, pack_name = find_opt_file({ p .. '.lua', vim.fs.joinpath(p, 'init.lua') })

  if not found then
    return 'no file:\n    ' .. table.concat(file_path --[[ @as string[] ]], '\n    ')
  end

  require('lz.n').trigger_load(pack_name)
  return assert(loadfile(file_path --[[@as string]]))
end

function M.register_loader()
  table.insert(package.loaders, M.search)
end

return M
