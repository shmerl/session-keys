local SessionKeys = {
   sessions = {},
   backups = {}
}

-- returns maparg style mapping if exists
local function get_mapping(mode, lhs)
   local mappings = vim.api.nvim_get_keymap(mode)
   for _, val in pairs(mappings) do
      if (lhs == val.lhs) then
         return val
      end
   end

   return nil
end

local function session_active(self, session_name)
   return self.backups[session_name] ~= nil
end

-- TODO: handle session deactivation by disabling them hierarchically i.e. disabling earlier started session should first disable all later ones in reverse order too
function SessionKeys:start(session_name)
   local session_mappings = self.sessions[session_name]

   if (session_mappings == nil) then
      error(string.format("Incorrect keys session %s specified!", session_name))
   end

   if (session_active(self, session_name)) then
      error(string.format("Keys session %s is already active!", session_name))
   end

   self.backups[session_name] = {}

   -- back up original mappings
   for mode, mode_mappings in pairs(session_mappings) do
      for _, mode_mapping in pairs(mode_mappings) do
         local current_mapping = get_mapping(mode, mode_mapping.lhs)
         if current_mapping ~= nil then
            table.insert(self.backups[session_name], current_mapping)
         end
      end
   end

   -- set custom mappings
   for mode, mode_mappings in pairs(session_mappings) do
      for _, mode_mapping in pairs(mode_mappings) do
         vim.keymap.set(mode, mode_mapping.lhs, mode_mapping.rhs, mode_mapping.opts)
      end
   end
end

function SessionKeys:stop(session_name)
   local session_mappings = self.sessions[session_name]

   if (session_mappings == nil) then
      error(string.format("Incorrect keys session %s specified!", session_name))
   end

   if (not session_active(self, session_name)) then
      error(string.format("Keys session %s is already inactive!", session_name))
   end

   -- delete custom mappings
   for mode, mode_mappings in pairs(session_mappings) do
      for _, mode_mapping in pairs(mode_mappings) do
         -- passing mode_mapping.opts here, but local buffers aren't going
         -- to work anyway due to backup only considering global buffer currently
         vim.keymap.del(mode, mode_mapping.lhs, mode_mapping.opts)
      end
   end

   -- restore original mappings
   for _, mapping in pairs(self.backups[session_name]) do
      vim.fn.mapset(mapping)
   end

   self.backups[session_name] = nil
end

function SessionKeys:toggle(session_name)
   local session_mappings = self.sessions[session_name]

   if (session_mappings == nil) then
      error(string.format("Incorrect keys session %s specified!", session_name))
   end

   if (session_active(self, session_name)) then
      self:stop(session_name)
   else
      self:start(session_name)
   end
end

function SessionKeys:show_active()
   print("Active keys sessions: ")
   for name, session in pairs(self.backups) do
      print(name)
   end
end

return SessionKeys
