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

## Configuration

You need to set up your session keys by adding mappings to `sessions` table which you can access through
`require('session-keys').sessions`.

Give your session a name and then assign mappings per mode. See a detailed example below.

Usage of mode, rhs, lhs (and opts if any) is the same as described in `:help vim.keymap.set`,
except that mode (key of the table) has to be a single value, not a list.

See also `:help key-notation`.

### Example of setting up DAP debugging session keys for Neovim + Konsole

```lua
require('session-keys').sessions.dap = {
   n = { -- mode 'n'
      { lhs = '<F5>',  rhs = function() require('dap').continue() end, opts = { desc = 'Run, continue' } },
      { lhs = '<F17>', rhs = function() require('dap').run_to_cursor() end, opts = { desc = 'Run to cursor' } },
      { lhs = '<F9>',  rhs = function() require('dap').toggle_breakpoint() end, opts = { desc = 'Toggle breakpoint' } },
      { lhs = '<F10>', rhs = function() require('dap').step_over() end, opts = { desc = 'Step over' } },
      { lhs = '<F11>', rhs = function() require('dap').step_into() end, opts = { desc = 'Step into' } },
      { lhs = '<F23>', rhs = function() require('dap').step_out() end, opts = { desc = 'Step out' } },

      { lhs = '<F8>',  rhs = function() require('dap').terminate() end, opts = { desc = 'Terminate' } },
      { lhs = '<F20>', rhs = function() require('dap').disconnect({ terminateDebuggee = false }) end, opts = { desc = 'Disconnect' } },
      { lhs = '<F29>', rhs = function() require('dap').run_last() end, opts = { desc = 'Run last' } },

      { lhs = '<F6>',  rhs = function() require('dap').down() end, opts = { desc = 'Go down in current stacktrace without stepping' } },
      { lhs = '<F18>', rhs = function() require('dap').up() end, opts = { desc = 'Go up in current stacktrace without stepping' } },

      { lhs = '<F7>',  rhs = function() require('dap').pause() end, opts = { desc = 'Pause thread' } },

      { lhs = '<F41>', rhs = function() require('dap').reverse_continue() end, opts = { desc = 'Reverse continue' } },
      { lhs = '<F22>', rhs = function() require('dap').step_back() end, opts = { desc = 'Step back' } }
   }
}
```

Explanation:

```
F5        - run, continue
Shift-F5  - run to cursor
F9        - toggle breakpoint
F10       - step over
F11       - step into
Shift-F11 - step out

F8       - terminate
Shift-F8 - disconnect
Ctrl-F5  - run last

F6       - go down in current stacktrace without stepping
Shift-F6 - go up in current stacktrace without stepping

F7       - pause thread

Ctrl-Shift-F5 - reverse continue
Shift-F10     - step back
```

DAP function calls above are wrapped in `function() ... end` to allow lazy loading of DAP plugin if needed.
If you don't need that, you can simply use something like `rhs = require('dap').continue` for simplicity.

**Note**: in Konsole, function keys with modifiers result in keycodes that neovim understands as higher function keys
  such as F17, F22 and etc., so those are used above:

```
Shift-F5      = F17
Ctrl-F5       = F29
Ctrl-Shift-F5 = F41
Shift-F6      = F18
Shift-F8      = F20
Shift-F11     = F23
Shift-F10     = F22

```

To check the combo codes, try for example:

```
showkey --ascii
```

Or simply

```
cat
```

And then try some combo like Shift-F5. It will show something like `^[[15;2~`

Then find that sequence in keys.log generated by:

```
nvim -V3keys.log
:q
```

It can be shown as something like `key_f17`. Then use `<F17>` for such mapping.

For details, see: https://github.com/neovim/neovim/issues/7384

## Usage

Once you enabled this set up, you can start your named session (in the above case - `dap`) as follows:

```vim
:lua require('session-keys'):start('dap')
```

Do some debugging using F9, F5, etc. When you are done, stop the session with:

```vim
:lua require('session-keys'):stop('dap')
```

This will restore your key mappings to what they were before you started the session.

To toggle a session back and forth between active and inactive you can do:

```vim
:lua require('session-keys'):toggle('dap')
```

Toggle especially can be assigned to its own permanent key mapping for easier control.

For example:

```lua
-- Alt-F11 (= F59) for toggling dap session keys itself
vim.keymap.set('n', '<F59>', function() require('session-keys'):toggle('dap') end)

```

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
