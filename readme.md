# Session keys

Session keys is a plugin for Neovim that allows creating temporary key mappings that you can enable on demand
for a specific need (starting keys session) and then disable them when not needed anymore (stopping keys session),
which restores mappings to their original state.

This way you can define a number of sessions for different needs without worrying about reusing keys.

## Installation

With lazy.nvim:

```lua
   'shmerl/session-keys'
```

## Usage

You need to set up your session keys by adding mappings to `sessions` table which you can access through
`require('session-keys').sessions`.

Give your session a name and then assign mappings per mode. See a detailed example below.

Usage of mode, rhs, lhs (and opts if any) is the same as described in `:help vim.keymap.set`.

See also `:help key-notation`.

## Example of setting up DAP debugging session keys for Neovim + Konsole

```lua
session_keys.sessions.dap = {
   n = { -- mode 'n'
     { lhs = '<F5>',  rhs = function() require('dap').continue() end },
     { lhs = '<F9>',  rhs = function() require('dap').toggle_breakpoint() end },
     { lhs = '<F10>', rhs = function() require('dap').step_over() end },
     { lhs = '<F11>', rhs = function() require('dap').step_into() end },
     { lhs = '<F23>', rhs = function() require('dap').step_out() end },

     { lhs = '<F8>',  rhs = function() require('dap').disconnect() end },
     { lhs = '<F20>', rhs = function() require('dap').terminate() end },

     { lhs = '<F17>', rhs = function() require('dap').run_last() end },

     { lhs = '<F7>',  rhs = function() require('dap').pause() end },
     { lhs = '<F29>', rhs = function() require('dap').reverse_continue() end },
     { lhs = '<F22>', rhs = function() require('dap').step_back() end }
   }
}
```

Explanation:

```
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
```

**Note**: in Konsole, function keys with modifiers result in keycodes that neovim understands as higher function keys
  such as F17, F22 and etc., so those are used below:

```
Shift + F5  = F17
Ctrl + F5   = F29
Shift + F8  = F20
Shift + F11 = F23
Shift + F10 = F22
```

  For details on how to determine it, see: https://github.com/neovim/neovim/issues/7384

  Consult log generated by:

```
nvim -V3log
:q
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

To toggle a session back and forth between active and inactive you can do:

```vim
:lua require('session-keys'):toggle('dap')
```

Toggle especially can be assigned to its own permanent key mapping for easier control.

You can define and start multiple sessions. To see the list of currently active sessions:

```vim
:lua require('session-keys'):show_active()
```

## Known limitations

### Local buffer mapping

Sessions by nature of being defined without relation to buffers are currently assuming global buffer mappings.

Local buffer mappings scenario isn't supported, so avoid using `buffer` in the opts for keys.

Not sure yet if there is a use case for local buffers, but it could be added in theory if there would be one.

### Session hierarchy

Session hierarchy isn't handled. I.e., if you start a bunch of sessions that conflict with each other and then stop them in the wrong order,
you'll mess up your mappings until next neovim restart, so make sure to stop sessions in the right sequence to get back to the original state.

Supporting sessions' hierarchy could be added later.
