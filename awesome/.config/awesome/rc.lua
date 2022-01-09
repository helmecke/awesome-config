-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

-- disable tmux hotkeys in tmux
package.loaded['awful.hotkeys_popup.keys.tmux'] = {}
package.loaded['awful.hotkeys_popup.keys.vim'] = {}
package.loaded['awful.hotkeys_popup.keys.firefox'] = {}

-- Standard awesome library
local gears = require 'gears'
local awful = require 'awful'
require 'awful.autofocus'
-- Widget and layout library
local wibox = require 'wibox'
-- Theme handling library
local beautiful = require 'beautiful'
-- Notification library
local naughty = require 'naughty'
local menubar = require 'menubar'
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require 'awful.hotkeys_popup.keys'
local hotkeys_popup = require 'awful.hotkeys_popup'
local lain = require 'lain'

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify {
    preset = naughty.config.presets.critical,
    title = 'Oops, there were errors during startup!',
    text = awesome.startup_errors,
  }
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal('debug::error', function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify {
      preset = naughty.config.presets.critical,
      title = 'Oops, an error happened!',
      text = tostring(err),
    }
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. 'themes/onedark/theme.lua')

beautiful.hotkeys_font = 'MesloLGM Nerd Font 11'
beautiful.hotkeys_description_font = beautiful.hotkeys_font
beautiful.menu_font = beautiful.hotkeys_font
-- This is used later as the default terminal and editor to run.
awful.util.terminal = 'kitty'
local editor = os.getenv 'EDITOR' or 'nvim'
local editor_cmd = awful.util.terminal .. ' --title nvim zsh -c "' .. editor .. '"'

awful.util.tagnames = { '1', '2', '3', '4', '5' }

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = 'Mod4'

-- Table of layouts too cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair,
  awful.layout.suit.max,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
  {
    'hotkeys',
    function()
      hotkeys_popup.show_help(nil, awful.screen.focused())
    end,
  },
  { 'manual', awful.util.terminal .. ' -e man awesome' },
  { 'edit config', editor_cmd .. ' ' .. awesome.conffile },
  { 'restart', awesome.restart },
  {
    'quit',
    function()
      awesome.quit()
    end,
  },
}

local mymainmenu = awful.menu {
  items = {
    { 'awesome', myawesomemenu, beautiful.awesome_icon },
    { 'open terminal', awful.util.terminal },
  },
}

-- Menubar configuration
menubar.utils.terminal = awful.util.terminal -- Set the terminal for applications that require it
-- }}}

gears.wallpaper.set '#21252b'

awful.screen.connect_for_each_screen(function(s)
  beautiful.at_screen_connect(s)
end)
-- awful.screen.connect_for_each_screen(function(s)
--   -- Each screen has its own tag table.
--   awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, awful.layout.layouts[1])

--   s.quake = lain.util.quake {
--     app = terminal,
--     argname = '--name=%s',
--     height = 0.4,
--     border = 2,
--   }

--   -- Create a promptbox for each screen
--   s.mypromptbox = awful.widget.prompt()
--   -- Create an imagebox widget which will contain an icon indicating which layout we're using.
--   -- We need one layoutbox per screen.
--   s.mylayoutbox = awful.widget.layoutbox(s)
--   s.mylayoutbox:buttons(gears.table.join(
--     awful.button({}, 1, function()
--       awful.layout.inc(1)
--     end),
--     awful.button({}, 3, function()
--       awful.layout.inc(-1)
--     end),
--     awful.button({}, 4, function()
--       awful.layout.inc(1)
--     end),
--     awful.button({}, 5, function()
--       awful.layout.inc(-1)
--     end)
--   ))
--   -- Create a taglist widget
--   s.mytaglist = awful.widget.taglist {
--     screen = s,
--     filter = awful.widget.taglist.filter.all,
--     buttons = taglist_buttons,
--   }

--   -- Create a tasklist widget
--   s.mytasklist = awful.widget.tasklist {
--     screen = s,
--     filter = awful.widget.tasklist.filter.currenttags,
--     buttons = tasklist_buttons,
--   }

--   -- Create the wibox
--   s.mywibox = awful.wibar { position = 'top', screen = s }

--   -- Add widgets to the wibox
--   s.mywibox:setup {
--     layout = wibox.layout.align.horizontal,
--     { -- Left widgets
--       layout = wibox.layout.fixed.horizontal,
--       s.mylayoutbox,
--       s.mytaglist,
--       s.mypromptbox,
--     },
--     s.mytasklist, -- Middle widget
--     { -- Right widgets
--       layout = wibox.layout.fixed.horizontal,
--       wibox.widget.systray(),
--       mycal,
--       mytextclock,
--       myvolume,
--     },
--   }
-- end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
  awful.button({}, 3, function()
    mymainmenu:toggle()
  end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

local clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal('request::activate', 'mouse_click', { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
local globalkeys = gears.table.join(
  awful.key({ modkey }, '`', function()
    awful.screen.focused().quake:toggle()
  end, {
    description = 'drop-down terminal',
    group = 'launcher',
  }),

  awful.key({ modkey, 'Shift' }, 'n', function()
    lain.util.add_tag(awful.layout.suit.tile)
  end, {
    description = 'create tag',
    group = 'tag',
  }),
  awful.key({ modkey, 'Shift' }, 'r', function()
    lain.util.rename_tag()
  end, {
    description = 'rename tag',
    group = 'tag',
  }),
  awful.key({ modkey, 'Shift' }, ']', function()
    lain.util.move_tag(1)
  end, {
    description = 'move to next tag',
    group = 'tag',
  }),
  awful.key({ modkey, 'Shift' }, '[', function()
    lain.util.move_tag(-1)
  end, {
    description = 'move to previous tag',
    group = 'tag',
  }),
  awful.key({ modkey, 'Shift' }, 'd', function()
    lain.util.delete_tag()
  end, {
    description = 'delete tag',
    group = 'tag',
  }),
  awful.key({ modkey }, 's', hotkeys_popup.show_help, { description = 'show help', group = 'awesome' }),
  awful.key({ modkey }, '[', awful.tag.viewprev, { description = 'view previous', group = 'tag' }),
  awful.key({ modkey }, ']', awful.tag.viewnext, { description = 'view next', group = 'tag' }),
  awful.key({ modkey }, 'Escape', awful.tag.history.restore, { description = 'go back', group = 'tag' }),

  awful.key({ modkey }, 'h', function()
    awful.client.focus.global_bydirection 'left'
  end, {
    description = 'focus next by direction',
    group = 'client',
  }),
  awful.key({ modkey }, 'j', function()
    local screen = awful.screen.focused()
    local layout = awful.layout.get(screen)

    if awful.layout.getname(layout) == 'max' then
      awful.client.focus.byidx(1)
    else
      awful.client.focus.global_bydirection 'down'
    end
  end, {
    description = 'focus next by direction',
    group = 'client',
  }),
  awful.key({ modkey }, 'k', function()
    local screen = awful.screen.focused()
    local layout = awful.layout.get(screen)

    if awful.layout.getname(layout) == 'max' then
      awful.client.focus.byidx(-1)
    else
      awful.client.focus.global_bydirection 'up'
    end
  end, {
    description = 'focus next by direction',
    group = 'client',
  }),
  awful.key({ modkey }, 'l', function()
    awful.client.focus.global_bydirection 'right'
  end, {
    description = 'focus next by direction',
    group = 'client',
  }),

  awful.key({ modkey, 'Shift' }, 'h', function()
    awful.client.swap.global_bydirection 'left'
  end, {
    description = 'swap next by direction',
    group = 'client',
  }),
  awful.key({ modkey, 'Shift' }, 'j', function()
    awful.client.swap.global_bydirection 'down'
  end, {
    description = 'swap next by direction',
    group = 'client',
  }),
  awful.key({ modkey, 'Shift' }, 'k', function()
    awful.client.swap.global_bydirection 'up'
  end, {
    description = 'swap next by direction',
    group = 'client',
  }),
  awful.key({ modkey, 'Shift' }, 'l', function()
    awful.client.swap.global_bydirection 'right'
  end, {
    description = 'swap next by direction',
    group = 'client',
  }),
  -- awful.key({ modkey }, 'j', function()
  --   awful.client.focus.byidx(1)
  -- end, {
  --   description = 'focus next by index',
  --   group = 'client',
  -- }),
  -- awful.key({ modkey }, 'k', function()
  --   awful.client.focus.byidx(-1)
  -- end, {
  --   description = 'focus previous by index',
  --   group = 'client',
  -- }),
  -- awful.key({ modkey, 'Shift' }, 'j', function()
  --   awful.client.swap.byidx(1)
  -- end, {
  --   description = 'swap with next client by index',
  --   group = 'client',
  -- }),
  -- awful.key({ modkey, 'Shift' }, 'k', function()
  --   awful.client.swap.byidx(-1)
  -- end, {
  --   description = 'swap with previous client by index',
  --   group = 'client',
  -- }),
  awful.key({ modkey, 'Control' }, 'j', function()
    awful.screen.focus_relative(1)
  end, {
    description = 'focus the next screen',
    group = 'screen',
  }),
  awful.key({ modkey, 'Control' }, 'k', function()
    awful.screen.focus_relative(-1)
  end, {
    description = 'focus the previous screen',
    group = 'screen',
  }),

  -- Layout manipulation
  -- awful.key({ modkey }, 'l', function()
  --   awful.tag.incmwfact(0.05)
  -- end, {
  --   description = 'increase master width factor',
  --   group = 'layout',
  -- }),
  -- awful.key({ modkey }, 'h', function()
  --   awful.tag.incmwfact(-0.05)
  -- end, {
  --   description = 'decrease master width factor',
  --   group = 'layout',
  -- }),
  -- awful.key({ modkey, 'Shift' }, 'h', function()
  --   awful.tag.incnmaster(1, nil, true)
  -- end, {
  --   description = 'increase the number of master clients',
  --   group = 'layout',
  -- }),
  -- awful.key({ modkey, 'Shift' }, 'l', function()
  --   awful.tag.incnmaster(-1, nil, true)
  -- end, {
  --   description = 'decrease the number of master clients',
  --   group = 'layout',
  -- }),
  awful.key({ modkey, 'Control' }, 'h', function()
    awful.tag.incncol(1, nil, true)
  end, {
    description = 'increase the number of columns',
    group = 'layout',
  }),
  awful.key({ modkey, 'Control' }, 'l', function()
    awful.tag.incncol(-1, nil, true)
  end, {
    description = 'decrease the number of columns',
    group = 'layout',
  }),
  awful.key({ modkey }, 'u', awful.client.urgent.jumpto, { description = 'jump to urgent client', group = 'client' }),
  awful.key({ modkey }, 'Tab', function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, {
    description = 'go back',
    group = 'client',
  }),

  -- Standard program
  awful.key({ modkey }, 'Return', function()
    awful.spawn(awful.util.terminal)
  end, {
    description = 'open a terminal',
    group = 'launcher',
  }),
  awful.key({ modkey, 'Shift' }, 'Return', function()
    awful.spawn(editor_cmd)
  end, {
    description = 'open a editor',
    group = 'launcher',
  }),
  awful.key({ modkey, 'Control' }, 'r', awesome.restart, { description = 'reload awesome', group = 'awesome' }),
  awful.key({ modkey, 'Shift' }, 'q', awesome.quit, { description = 'quit awesome', group = 'awesome' }),

  awful.key({ modkey, 'Control' }, 'c', function()
    awful.client.floating.toggle()
    awful.placement.centered(c)
    client.focus:raise()
  end, {
    description = 'center client',
    group = 'client',
  }),
  awful.key({ modkey }, 'space', function()
    awful.layout.inc(1)
  end, {
    description = 'select next',
    group = 'layout',
  }),
  awful.key({ modkey, 'Shift' }, 'space', function()
    awful.layout.inc(-1)
  end, {
    description = 'select previous',
    group = 'layout',
  }),

  awful.key({ modkey, 'Control' }, 'n', function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
      c:emit_signal('request::activate', 'key.unminimize', { raise = true })
    end
  end, {
    description = 'restore minimized',
    group = 'client',
  }),

  -- Prompt
  awful.key({ modkey }, 'r', function()
    awful.spawn.with_shell 'rofi -show'
    -- awful.screen.focused().mypromptbox:run()
  end, {
    description = 'run prompt',
    group = 'launcher',
  }),

  awful.key({ modkey }, 'x', function()
    awful.prompt.run {
      prompt = 'Run Lua code: ',
      textbox = awful.screen.focused().mypromptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. '/history_eval',
    }
  end, {
    description = 'lua execute prompt',
    group = 'awesome',
  }),
  -- Menubar
  awful.key({ modkey }, 'p', function()
    menubar.show()
  end, {
    description = 'show the menubar',
    group = 'launcher',
  }),
  awful.key(
    { modkey },
    '\\',
    naughty.destroy_all_notifications,
    { description = 'clear notifications', group = 'awesome' }
  )
)

local clientkeys = gears.table.join(
  awful.key({ modkey }, 'f', function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end, {
    description = 'toggle fullscreen',
    group = 'client',
  }),
  awful.key({ modkey }, 'q', function(c)
    c:kill()
  end, {
    description = 'close',
    group = 'client',
  }),
  awful.key(
    { modkey, 'Control' },
    'space',
    awful.client.floating.toggle,
    { description = 'toggle floating', group = 'client' }
  ),
  awful.key({ modkey, 'Control' }, 'Return', function(c)
    c:swap(awful.client.getmaster())
  end, {
    description = 'move to master',
    group = 'client',
  }),
  awful.key({ modkey }, 'o', function(c)
    c:move_to_screen()
  end, {
    description = 'move to screen',
    group = 'client',
  }),
  awful.key({ modkey }, 't', function(c)
    c.ontop = not c.ontop
  end, {
    description = 'toggle keep on top',
    group = 'client',
  }),
  awful.key({ modkey }, 'n', function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
  end, {
    description = 'minimize',
    group = 'client',
  }),
  awful.key({ modkey }, 'm', function(c)
    c.maximized = not c.maximized
    c:raise()
  end, {
    description = '(un)maximize',
    group = 'client',
  }),
  awful.key({ modkey, 'Control' }, 'm', function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end, {
    description = '(un)maximize vertically',
    group = 'client',
  }),
  awful.key({ modkey, 'Shift' }, 'm', function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end, {
    description = '(un)maximize horizontally',
    group = 'client',
  }),
  awful.key({}, 'XF86AudioPlay', function()
    awful.spawn.with_shell 'playerctl play-pause'
  end, {
    description = 'playerctl play toggle',
    group = 'media keys',
  }),
  awful.key({}, 'XF86AudioStop', function()
    awful.spawn.with_shell 'playerctl stop'
  end, {
    description = 'playerctl stop',
    group = 'media keys',
  }),
  awful.key({}, 'XF86AudioPrev', function()
    awful.spawn.with_shell 'playerctl previous'
  end, {
    description = 'playerctl previous',
    group = 'media keys',
  }),
  awful.key({}, 'XF86AudioNext', function()
    awful.spawn.with_shell 'playerctl next'
  end, {
    description = 'playerctl next',
    group = 'media keys',
  })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = gears.table.join(
    globalkeys,
    -- View tag only.
    awful.key({ modkey }, '#' .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        tag:view_only()
      end
    end, {
      description = 'view tag #' .. i,
      group = 'tag',
    }),
    -- Toggle tag display.
    awful.key({ modkey, 'Control' }, '#' .. i + 9, function()
      local screen = awful.screen.focused()
      local tag = screen.tags[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end, {
      description = 'toggle tag #' .. i,
      group = 'tag',
    }),
    -- Move client to tag.
    awful.key({ modkey, 'Shift' }, '#' .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end, {
      description = 'move focused client to tag #' .. i,
      group = 'tag',
    }),
    -- Toggle tag on focused client.
    awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9, function()
      if client.focus then
        local tag = client.focus.screen.tags[i]
        if tag then
          client.focus:toggle_tag(tag)
        end
      end
    end, {
      description = 'toggle focused client on tag #' .. i,
      group = 'tag',
    })
  )
end

-- Set keys
root.keys(globalkeys)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        'DTA', -- Firefox addon DownThemAll.
        'copyq', -- Includes session name in class.
        'pinentry',
      },
      class = {
        'Arandr',
        'Blueman-manager',
        'Gpick',
        'Kruler',
        'MessageWin', -- kalarm.
        'Sxiv',
        'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
        'Wpa_gui',
        'veromix',
        'xtightvncviewer',
        'Cisco AnyConnect Secure Mobility Client',
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        'Event Tester', -- xev.
      },
      role = {
        'AlarmWindow', -- Thunderbird's calendar.
        'ConfigManager', -- Thunderbird's about:config.
        'pop-up', -- e.g. Google Chrome's (detached) Developer Tools.
      },
    },
    properties = { floating = true },
  },

  -- Add titlebars to normal clients and dialogs
  {
    rule_any = { type = { 'normal', 'dialog' } },
    properties = { titlebars_enabled = false },
  },

  -- Set Firefox to always map on the tag named "2" on screen 1.
  {
    rule = { class = 'qutebrowser' },
    properties = { screen = awful.screen.primary, tag = '2' },
  },
  {
    rule = { instance = 'nvr' },
    properties = { screen = awful.screen.primary, tag = '1', switchtotag = true },
  },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then
    awful.client.setslave(c)
  end

  if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end

  if c.floating then
    awful.placement.centered(c)
  end
end)

client.connect_signal('property::floating', function(c)
  if c.floating and not c.maximized and not c.maximized_horizontal and not c.maximized_vertical then
    awful.placement.centered(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal('request::titlebars', function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      c:emit_signal('request::activate', 'titlebar', { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({}, 3, function()
      c:emit_signal('request::activate', 'titlebar', { raise = true })
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c):setup {
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal,
    },
    { -- Middle
      { -- Title
        align = 'center',
        widget = awful.titlebar.widget.titlewidget(c),
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal,
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal(),
    },
    layout = wibox.layout.align.horizontal,
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
  c:emit_signal('request::activate', 'mouse_enter', { raise = false })
end)

client.connect_signal('focus', function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal('unfocus', function(c)
  c.border_color = beautiful.border_normal
end)
-- }}}