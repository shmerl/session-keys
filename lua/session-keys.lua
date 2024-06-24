local SessionKeys = {
   sessions = {},
   backups = {}
}

-- returns maparg style mapping if exists
function get_mapping(mode, lhs)
   local mappings = vim.api.nvim_get_keymap(mode)
   for _, val in pairs(mappings) do
      if (lhs == val.lhs) then
         return val
      end
   end

   return nil
end

-- TODO: handle session deactivation by disabling them hierarchically i.e. disabling earlier started session should first disable all later ones in reverse order too
function SessionKeys:start(session_name)
   local session_mappings = self.sessions[session_name]

   if (session_mappings == nil) then
      error(string.format("Incorrect keys session %s specified!", session_name))
   end

   if (self.backups[session_name] ~= nil) then
      error(string.format("Keys session %s is already active!", session_name))
   end

   self.backups[session_name] = {}

   for mode, mode_mappings in pairs(session_mappings) do
      for _, mode_mapping in pairs(mode_mappings) do
         local current_mapping = get_mapping(mode, mode_mapping.lhs)
         if current_mapping ~= nil then
            table.insert(self.backups[session_name], current_mapping)
         end
      end
   end

   for mode, mode_mappings in pairs(session_mappings) do
      for _, mode_mapping in pairs(mode_mappings) do
         vim.api.nvim_set_keymap(mode, mode_mapping.lhs, mode_mapping.rhs, mode_mapping.opts)
      end
   end
end

function SessionKeys:stop(session_name)
   local session_mappings = self.sessions[session_name]

   if (session_mappings == nil) then
      error(string.format("Incorrect keys session %s specified!", session_name))
   end

   if (self.backups[session_name] == nil) then
      error(string.format("Keys session %s is already inactive!", session_name))
   end

   for _, mapping in pairs(self.backups[session_name]) do
      vim.fn.mapset(mapping)
   end

   self.backups[session_name] = nil
end

function SessionKeys:show_active()
   print("Active keys sessions: ")
   for name, session in pairs(self.backups) do
      print(name)
   end
end

return SessionKeys
