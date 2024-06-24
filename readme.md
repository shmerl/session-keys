# Session keys

Session keys is a plugin for Neovim that allows creating temporary key mappings that you can enable on demand
for a specific need (staring keys session) and then disable them when not needed anymore (stopping keys session),
which restores mappings to their original state.

This way you can define a number of sessions for different needs without worrying about reusing keys.

## Installation

With lazy.nvim:

```lua
   'shmerl/session-keys'
```

## Usage

You need to set up your session keys by adding mappings to `sessions` table which you can access it through
`require('session-keys').sessions`.

Give your session a name and then assign mappings per mode. See a detailed example below.

Usage of mode, rhs, lhs and opts is the same as described in `:help nvim_set_keymap`. See also `:help key-notation`.

## Example of setting up DAP debugging session keys for Neovim + Konsole

F5          - run, continue
F9          - toggle breakpoint
F10         - step over
F11         - step into      
Shift + F11 - step out

F8          - disconnect
Shift + F8  - terminate

Shift + F5  - run last

F7          - pause thread
Ctrl + F5   - reverse continue
Shift + F10 - step back

**Note**: in Konsole, function keys with modifiers result in keycodes that neovim understands as higher function keys
  such as F17, F22 and etc., so those are used below:

  Shift + F5  = F17
  Ctrl + F5   = F29
  Shift + F8  = F20
  Shift + F11 = F23
  Shift + F10 = F22

  For details on how to determine it, see: https://github.com/neovim/neovim/issues/7384

```lua
local dap = require('dap')

require('session-keys').sessions.dap = {
   n = { -- table for mode 'n'
     { lhs = '<F5>',  rhs = '', opts = { callback = function() dap.continue() end, nowait = true, noremap = true } },
     { lhs = '<F9>',  rhs = '', opts = { callback = function() dap.toggle_breakpoint() end, nowait = true, noremap = true } },
     { lhs = '<F10>', rhs = '', opts = { callback = function() dap.step_over() end, nowait = true, noremap = true } },
     { lhs = '<F11>', rhs = '', opts = { callback = function() dap.step_into() end, nowait = true, noremap = true } },
     { lhs = '<F23>', rhs = '', opts = { callback = function() dap.step_out() end, nowait = true, noremap = true } },

     { lhs = '<F8>',  rhs = '', opts = { callback = function() dap.disconnect() end, nowait = true, noremap = true } },
     { lhs = '<F20>', rhs = '', opts = { callback = function() dap.terminate() end, nowait = true, noremap = true } },

     { lhs = '<F17>', rhs = '', opts = { callback = function() dap.run_last() end, nowait = true, noremap = true } },

     { lhs = '<F7>',  rhs = '', opts = { callback = function() dap.pause() end, nowait = true, noremap = true } },
     { lhs = '<F29>', rhs = '', opts = { callback = function() dap.reverse_continue() end, nowait = true, noremap = true } },
     { lhs = '<F22>', rhs = '', opts = { callback = function() dap.step_back() end, nowait = true, noremap = true } }
   }
}
```

Once you enabled this set up, you can start your named session (in this case `dap`) as follows:

```vim
:lua require('session-keys'):start('dap')
```

Do some debugging using F5, F9 etc. When you are done, stop the session with:

```vim
:lua require('session-keys'):stop('dap')
```

This will restore your key mappings to what they were before you started the session.

You can define and start multiple sessions. To see the list of currently active sessions:

```
:lua require('session-keys'):show_active()
```

## Currently not supported

Session hierarchy isn't handled. I.e., if you start a bunch of sessions that conflict with each other and then stop them in the wrong order,
you'll mess up your mappings until next neovim restart, so make sure to stop sessions in the right sequence to get back to the original state.

Supporting sessions' hierarchy could be added later.