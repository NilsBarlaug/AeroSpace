# AeroSpace Guide

**Table of contents**

- [Configuring AeroSpace](#configuring-aerospace)
  - [Binding modes](#bindings-modes)
  - [Commands](#commands)
- [Tree](#tree)
  - [Layouts](#layouts)
  - [Normalization](#normalization)
  - [Floating windows](#floating-windows)
- [Emulation of virtual workspaces](#emulation-of-virtual-workspaces)
  - [A note on mission control](#a-note-on-mission-control)
  - [A note on 'Displays have separate Spaces'](#a-note-on-displays-have-separate-spaces)
- ['on-window-detected' callback](#on-window-detected-callback)
- [Multiple monitors](#multiple-monitors)
  - [Assign workspaces to monitors](#assign-workspaces-to-monitors)

## Configuring AeroSpace

AeroSpace will read config file from `~/.aerospace.toml`. Please see the following config samples:

- The default config: [default-config.toml](../config-examples/default-config.toml)
- i3 like config: [i3-like-config-example.toml](../config-examples/i3-like-config-example.toml)
- [Search for configs by other users on GitHub](https://github.com/search?q=%28path%3A**%2F.aerospace.toml+OR+path%3A**%2Faerospace.toml%29&type=code) for inspiration

The [default-config.toml](../config-examples/default-config.toml) also serves as a documentation, since it contains
all possible plain configuration keys with comments. Non-trivial configuration options are mentioned further in this
guide.

AeroSpace uses TOML format for the config. TOML is easy to read, and it supports comments. See [TOML site for more
info](https://toml.io/en/)

### Binding modes

You can create multiple sets of bindings by creating different binding modes. When you switch to a different binding mode, all
the bindings from the current mode are deactivated, and only the bindings specified in the new mode become active. The initial
binding mode that AeroSpace starts out with is "main".

This feature is absolutely identical to the one [in i3](https://i3wm.org/docs/userguide.html#binding_modes)

Working with binding modes consists of two parts: 1. defining a binding to switch to the binding mode and 2. declaring the binding
mode itself.

```toml
[mode.main.binding] # Declare 'main' binding mode
alt-r = 'mode resize' # 1. Define a binding to switch to 'resize' mode

[mode.resize.binding] # 2. Declare 'resize' binding mode
minus = 'resize smart -50'
equal = 'resize smart +50'
```

### Commands

AeroSpace is controlled by commands. For more info see [the list of all available commands](./commands.md).

## Tree

AeroSpace stores all windows and containers in a tree. AeroSpace tree tiling model is [inspired by
i3](https://i3wm.org/docs/userguide.html#tree).

**Definition.** Each non-leaf node is called a "Container"

> [!WARNING]
> i3 has a different terminology. In i3, terms "container" and "node" are the same.

- Each workspace contains its own single root node
- Each container can contain arbitrary number of children nodes
- Windows are the only possible leaf nodes. Windows contain zero children nodes
- Every container has two properties:
  1. [Layout](#layouts) (Possible values: `tiles`, `accordion`)
  2. Orientation (Possible values: `horizontal`, `vertical`)

When we say "layout of the window", we refer to the layout of the window's parent container.

It's easier to understand tree tiling model by looking at examples

![](./.assets/h_tiles.png)
![](./.assets/tree.png)

You can nest containers as deeply as you want to.

You can navigate in the tree in 4 possible cardinal directions (left, down, up, right). You use [focus
command](./commands.md#focus) to do that.

The tree structure can be changed with three commands:
- [move-through](./commands.md#move-through)
- [join-with](./commands.md#join-with)
- [split](./commands.md#split)

### Layouts

In total, AeroSpace provides 4 possible layouts:
- `h_tiles` horizontal tiles (in i3, it's called "horizontal split") (deprecated name: `h_list`)
- `v_tiles` vertical tiles (in i3, it's called "vertical split") (deprecated name: `v_list`)
- `h_accordion` horizontal accordion (analog of i3's "tabbed layout")
- `v_accordion` vertical accordion (analog of i3's "stacked layout")

From the previous section, you're already familiar with the `tiles` layout.

Accordion is a layout where windows are placed on top of each other.
- The horizontal accordion shows left and right paddings to visually indicate the presence of other windows in those directions.
- The vertical accordion shows top and bottom paddings to visually indicate the presence of other windows in those directions.

Horizontal accordion looks like this

<img src="./.assets/h_accordion.png" width="70%" height="70%">

Vertical accordion looks like this

<img src="./.assets/v_accordion.png" width="70%" height="70%">

Just like in a `tiles` layout, you can use the [focus](./commands.md#focus) command to navigate an accordion layout.

You can navigate the windows in an `h_accordion` by using the `focus (left|right)` command, while in a `v_accordion`, you can
navigate the windows using the `focus (up|down)` command.

Accordion padding is configurable via `accordion-padding` option (see [default-config.toml](../config-examples/default-config.toml))

### Normalization

By default, AeroSpace does two types of tree normalizations:
- Containers that have only one child are "flattened". The root container is an exception, it is allowed to have a single window
  child. Configured by `enable-normalization-flatten-containers`
- Containers that nest into each other must have opposite orientations. Configured by
  `enable-normalization-opposite-orientation-for-nested-containers`

**Example 1**

According to the first normalization, such layout isn't possible:
```
h_tiles (root node)
└── v_tiles
    └── window 1
```

it will be immediately transformed into
```
v_tiles (new root node)
└── window 1
```

**Example 2**

According to the second normalization, such layout isn't possible:
```
h_tiles
├── window 1
└── h_tiles
    ├── window 2
    └── window 3
```

it will be immediately transformed into
```
h_tiles
├── window 1
└── v_tiles
    ├── window 2
    └── window 3
```

Normalizations makes it easier to understand the tree structure by looking at how windows are placed on the screen.

You can disable normalizations by placing these lines into your config:
```toml
enable-normalization-flatten-containers = false
enable-normalization-opposite-orientation-for-nested-containers = false
```

### Floating windows

Normally, floating windows are not considered to be part of the [tiling tree](#tree). But it's not the case with
[`focus`](./commands.md#focus) command.

From [`focus`](./commands.md#focus) command perspective, floating windows are part of [the tree](#tree). The floating window
parent container is determined as the smallest tiling container that contains the center of the floating window.

This technique eliminates the need for an additional binding for focusing floating windows.

## Emulation of virtual workspaces

Native macOS Spaces have a lot of problems.

- The animation for Spaces switching is slow
  - You can't disable animation for Spaces switching (you can only make it slightly faster by turning on `Reduce motion` setting,
    but it's suboptimal)
- You have a limit of Spaces (up to 16 Spaces with one monitor)
- You can't create/delete/reorder Space and move windows between Spaces with hotkeys (you can only switch between Spaces with
  hotkeys)
- Apple doesn't provide public API to communicate with Spaces (create/delete/reorder/switch Space and move windows between Spaces)

Since Spaces are so hard to deal with, AeroSpace reimplements Spaces and calls them "Workspaces". The idea is that if the
workspace isn't active then all of its windows are placed outside of the visible area of the screen, at the bottom right corner.
Once you switch back to the workspace, (e.g. by the means of [`workspace`](./commands.md#workspace) command) windows are placed
back to the visible area of the screen.

When you quit the AeroSpace or when the AeroSpace is about to crash, AeroSpace will place all windows back to the visible area of
the screen.

AeroSpace shows the name of currently active workspace in its tray icon (top right corner), to give users a visual feedback on
what workspace is currently active.

> [!NOTE]
> For better or worse, macOS doesn't allow to place windows outside of the visible area entirely. You will still be able to see a
> few pixels of "hidden" windows at the bottom right corner of your screen. That means, that if AeroSpace crashes badly you will
> still be able to manually "unhide" the windows by dragging these few pixels to the center of the screen.

The supposed workflow of using AeroSpace workspaces is to only have one macOS Space (or as many as monitors you have, if `Displays
have separate Spaces` is enabled) and don't interact with macOS Spaces anymore.

### A note on mission control

For some reason, mission control doesn't like that AeroSpace puts a lot of windows at the bottom right corner of the screen.
Mission control shows windows too small even if it has enough space to show them bigger.

To workaround it, you can enable `System Settings -> Desktop & Dock -> Group windows by application` setting. For some weird
reason, it helps.

### A note on 'Displays have separate Spaces'

AeroSpace doesn't care about `System Settings -> Desktop & Dock -> Displays have separate Spaces` setting. It works equally good
whether this option is enabled or disabled.

Overview of 'Displays have separate Spaces'

|                                                            | 'Displays have separate Spaces' is enabled | 'Displays have separate Spaces' is disabled |
|------------------------------------------------------------|--------------------------------------------|---------------------------------------------|
| When the first monitor is in fullscreen                    | 😊 Second monitor operates independently   | 😔 Second monitor is unusable black screen  |
| Is it possible for window to span across several monitors? | 😔 No                                      | 😊 Yes                                      |
| macOS status bar ...                                       | ... is displayed on both monitors          | ... is displayed only on main monitor       |

## 'on-window-detected' callback

- Available since: 0.6.0-Beta

You can use `on-window-detected` callback to run commands every time a new window is detected.

Here is a showcase example that uses all the possible configurations:

```toml
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'                # Application ID exact match
if.app-name-regex-substring = 'settings'                 # Case insensetive regex substring
if.window-title-regex-substring = 'substring'            # Case insensetive regex substring
if.during-aerospace-startup = true                       # Run the callback only if the window detected during AeroSpace startup
check-further-callbacks = true                           # Check further callbacks. if not specified the default value is false
run = ['layout floating', 'move-node-to-workspace S']    # The callback itself
```

`run` commands are run only if the detected window matches all the specified conditions. If no conditions are specified then
`run` is run every time a new window is detected.

Several callbacks can be declared in the config. The callbacks are processed in the order they are declared. By default, the first
callback that matches the criteria is run, and further callbacks are not considered. (The behavior can be overridden with
`check-further-callbacks` option)

For now, only [`move-node-to-workspace`](./commands.md#move-node-to-workspace) and [`layout`](./commands.md#layout) commands are
supported in the `run` callback. Please post your use cases to [the issue](https://github.com/nikitabobko/AeroSpace/issues/20) if
you want other commands to get supported.

Available window conditions are:

| Condition TOML key                | Condition Type     | Condition description                                                                                                                  |
|-----------------------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| `if.app-id`                       | String exact match | Application ID exact match of the detected window                                                                                      |
| `if.app-name-regex-substring`     | Regex substring    | Application name regex substring of the detected window                                                                                |
| `if.window-title-regex-substring` | Regex substring    | Window title regex substring of the detected window                                                                                    |
| `if.during-aerospace-startup`     | Boolean            | If `true` then run the callback only during AeroSpace startup.<br/>If `false` then run callback only **NOT** during AeroSpace startup. |

- `if.during-aerospace-startup = true` is useful if you want to do the initial app arrangement only on startup.
- `if.during-aerospace-startup = false` is useful if you want to relaunch AeroSpace, but the callback has side effects that you
  don't want to run on every relaunch (e.g. the callback opens new windows).

There are several ways to know `app-id`:
- Take a look at precomposed [list of popular application IDs](./popular-apps-ids.md)
- You can use [`aerospace list-apps`](./cli-commands.md#list-apps) CLI command to get IDs of running applications
- `mdls -name kMDItemCFBundleIdentifier -r /Applications/App.app`

> [!IMPORTANT]
> Some windows initialize their title after the window appears. `window-title-regex-substring` may not work as expected for such
> windows

Examples of automations:

- Assign apps on particular workspaces
  ```toml
  [[on-window-detected]]
  if.app-id = 'org.alacritty'
  run = 'move-node-to-workspace T' # mnemonics T - Terminal
  
  [[on-window-detected]]
  if.app-id = 'com.google.Chrome'
  run = 'move-node-to-workspace W' # mnemonics W - Web browser

  [[on-window-detected]]
  if.app-id = 'com.jetbrains.intellij'
  run = 'move-node-to-workspace I' # mnemonics I - IDE
  ```
- Make all windows float by default
  ```toml
  [[on-window-detected]]
  check-further-callbacks = true
  run = 'layout floating'
  ```
- Float 'System Settings' app
  ```toml
  [[on-window-detected]]
  if.app-id = 'com.apple.systempreferences'
  run = 'layout floating'
  ```

## Multiple monitors

- The pool of workspaces is shared between monitors
- Each monitor shows its own workspace. The showed workspaces are called "visible" workspaces
- Different monitors can't show the same workspace at the same time
- Each workspace (even invisible, even empty) has a monitor assigned to it
- By default, all workspaces are assigned to the "main" monitor (You can find the "main" monitor in `System -> Displays`)

When you switch to a workspace:
1. AeroSpace takes the assigned monitor of the workspace and makes the workspace visible on the monitor
2. AeroSpace focuses the workspace

You can move workspace to a different monitor with [`move-workspace-to-monitor`](./commands.md#move-workspace-to-monitor) command. 

The idea of making pool of workspaces shared is based on **the observation** that most users have a limited set of workspaces on
their secondary monitors. Secondary monitors are frequently dedicated to specific tasks (browser, shell), or for monitoring
various activities such as logs and dashboards. Thus, using one workspace per each secondary monitors and "the rest" on the main
monitor often makes sense.

> [!NOTE]
> The only difference between AeroSpace and i3 is switching to empty workspaces. When you switch to an empty workspace, AeroSpace
> puts the workspace on an assigned monitor; i3 puts the workspace on currently active monitor.
> - I find that AeroSpace model works better with **the observation** listed above.
> - AeroSpace model is more consistent (it works the same for empty workspaces and non-empty workspaces)

### Assign workspaces to monitors

- Available since: 0.5.0-Beta

You can use `workspace-to-monitor-force-assignment` syntax to assign workspaces to always appear on particular monitors

```toml
[workspace-to-monitor-force-assignment]
1 = 1                            # Sequence number of the monitor from left to right. 1-based indexing
2 = 'main'                       # Main monitor
3 = 'secondary'                  # Non-main monitor in case when there are only two monitors
4 = 'built-in'                   # Case insensitive regex substring
5 = '^built-in retina display$'  # Case insensitive regex match
6 = ['secondary', 'dell']        # You can specify multiple patterns. The first matching pattern will be used
```

- Left hand side of the assignment is the workspace name
- Right hand side of the assignment is the monitor pattern

Supported monitor patterns:
- `'main'` - "Main" monitor (you can see find your "main" monitor in `System Settings -> Displays -> Use as`)
- `'secondary'` - Non-main monitor in case when there are only two monitors
- `number` (e.g. `1`, `2`) - Sequence number of the monitor from left to right. 1-based indexing
- `regex_pattern` (e.g. `dell`, `built-in`) - Case insensitive regex substring pattern

You can specify multiple patterns as an array. The first matching pattern will be used

[`move-workspace-to-monitor`](./commands.md#move-workspace-to-monitor) command has no effect for workspaces that have monitor assignment
