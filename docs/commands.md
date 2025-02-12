# Commands

Commands listed in this file can be used in the config and CLI

**Table of contents**
- [close](#close)
- [close-all-windows-but-current](#close-all-windows-but-current)
- [enable](#enable)
- [exec-and-forget](#exec-and-forget)
- [exec-and-wait](#exec-and-wait)
- [flatten-workspace-tree](#flatten-workspace-tree)
- [focus](#focus)
- [fullscreen](#fullscreen)
- [join-with](#join-with)
- [layout](#layout)
- [mode](#mode)
- [move-node-to-workspace](#move-node-to-workspace)
- [move-through](#move-through)
- [move-workspace-to-monitor](#move-workspace-to-monitor)
- [reload-config](#reload-config)
- [resize](#resize)
- [split](#split)
- [workspace-back-and-forth](#workspace-back-and-forth)
- [workspace](#workspace)

## close

```
close
```

Closes the focused window

Normally, you don't need to use this command, because macOS has its own `cmd+w` binding. You might want to use the
command from CLI for scripting purposes

- Available since: 0.6.0-Beta
- The command doesn't have arguments

## close-all-windows-but-current

```
close-all-windows-but-current
```

On the focused workspace, closes all windows but current.

- The command doesn't have arguments.

## enable

```
enable (on|off|toggle)
```

The command allows to temporarily disable window management

When you disable AeroSpace, windows from currently invisible workspaces will be placed to the visible area of the screen

Key events are not intercepted when AeroSpace is disabled

- Available since: 0.5.0-Beta

## exec-and-forget

```
exec-and-forget <bash-command>
```

Runs `/bin/bash -c '$bash-command'`. Stdout, stderr and exit code are ignored.

For example, you can use this command to launch applications: `exec-and-forget open -n /System/Applications/Utilities/Terminal.app`

## exec-and-wait

```
exec-and-wait <bash-command>
```

Runs `/bin/bash -c '$bash-command'`, and waits until the command is terminated. Stdout, stderr and exit code are ignored.

Please prefer `exec-and-forget`, unless you need to wait for the termination.

You might want to wait for the termination if you have a list of commands, and you want `bash_command` to exit until you run the
next command.

Suppose that you have this binding in your config:
```toml
alt-enter = ['exec-and-wait open -n /System/Applications/Utilities/Terminal.app && sleep 1', 'layout floating']
```

It will open up Terminal.app and make it float. `sleep 1` is still required because `open` returns before the window appears.

## flatten-workspace-tree

```
flatten-workspace-tree
```

Flattens [the tree](./guide.md#tree) of currently focused workspace.

The command is useful when you messed up with your layout, and it's easier to "reset" it and start again.

- The command doesn't have arguments.

## focus

```
focus (left|down|up|right)
```

Sets focus to the nearest window in [the tree](./guide.md#tree) in the given direction.

[Contrary to i3](https://i3wm.org/docs/userguide.html#_focusing_moving_containers), `focus` command doesn't have a separate
argument to focus floating windows. From `focus` command perspective, floating windows are part of [the tree](./guide.md#tree).
The floating window parent container is determined as the smallest tiling container that contains the center of the floating
window.

This technique eliminates the need for an additional binding for floating windows.

`focus child|parent` [isn't yet supported](https://github.com/nikitabobko/AeroSpace/issues/5) because the necessaty of this
operation is under the question.

## fullscreen

```
fullscreen
```

Toggles the fullscreen mode for the currently focused window.

Switching to a different window within the same workspace while the current focused window is in fullscreen mode results
in the fullscreen window exiting fullscreen mode.

- Available since: 0.3.0-Beta
- The command doesn't have arguments.

## join-with

```
join-with (left|down|up|right)
```

Puts the currently focused window and the nearest node in the specified direction under a common parent container.

Given this layout
```
h_tiles
├── window 1
├── window 2 (focused)
└── window 3
```

`join-with right` will result in the following layout
```
h_tiles
├── window 1
└── v_tiles
    ├── window 2 (focused)
    └── window 3
```

> [!NOTE]
> `join-with` is a high-level replacement for i3's [split command](https://i3wm.org/docs/userguide.html#_splitting_containers).
> There is an observation that the only reason why you might want to split a node is to put several windows under a common
> "umbrella" parent. Unlike `split`, `join-with` can be used with
> [enable-normalization-flatten-containers](./guide.md#normalization)

## layout

```
layout (h_tiles|v_tiles|h_accordion|v_accordion|tiles|accordion|horizontal|vertical|tiling|floating)...
```

Changes layout of the focused window to the given layout.

If several layouts are supplied then finds the first layout that doesn't describe the currently active layout, and applies the
found layout.

`tiling` is the only argument that makes the focused floating window tiled.

## mode

```
mode <target-mode>
```

Activates the specified [binding mode](./guide.md#bindings-modes)

## move-node-to-workspace

```
move-node-to-workspace <target-workspace-name>
```

Moves currently focused window to the specified workspace

## move-through

```
move-through (left|down|up|right) [floating_pixel]
```

Moves the window in the given direction. The optional `floating_pixel` argument specifies how far the window should be moved if
it is floating. The default is 50 pixels

> [!NOTE]
> This command is an analog of [i3's move command](https://i3wm.org/docs/userguide.html#move_direction)

**Example 1**

Given this layout
```
h_tiles
├── window 1 (focused)
└── window 2
```

`move-through right` will result in the following layout
```
h_tiles
├── window 2
└── window 1 (focused)
```

**Example 2**

Given this layout
```
h_tiles
├── window 1
├── window 2 (focused)
└── v_tiles
    ├── window 3
    └── window 4
```

`move-through right` will result in the following layout
```
h_tiles
├── window 1
└── v_tiles
    ├── window 3
    ├── window 2 (focused)
    └── window 4
```

**Example 3**

Given this layout
```
h_tiles
├── window 1
└── v_tiles
    ├── window 3
    ├── window 2 (focused)
    └── window 4
```

`move-through left` will result in the following layout
```
h_tiles
├── window 1
├── window 2 (focused)
└── v_tiles
    ├── window 3
    └── window 4
```

**Implicit container example**

In some cases, `move-through` needs to implicitly create a container to fullfill your command.

Given this layout
```
h_tiles
├── window 1
├── window 2 (focused)
└── window 3
```

`move-through up` will result in the following layout
```
v_tiles
├── window 2 (focused)
└── h_tiles
    ├── window 1
    └── window 3
```

`v_tiles` is an implicitly created container.

## move-workspace-to-monitor

```
move-workspace-to-monitor (next|prev)
```

Moves currently focused workspace to the next or previous monitor

The command doesn't have effect on workspaces [that have monitor assignment](./guide.md#assign-workspaces-to-monitors)

- Deprecated name: `move-workspace-to-display`

## reload-config

```
reload-config
```

Reloads currently active config.

- The command doesn't have arguments.

## resize

```
resize (smart|width|height) [+|-]number
```

Resizes the currently active window

The dimension to resize is chosen by the first argument

- `width` changes width
- `height` changes height
- `smart` changes width if the parent has horizontal orientation, and it changes height if the parent has vertical orientation

Second argument controls how much the size is changes

- If the `number` is prefixed with `+` then the dimension is increased
- If the `number` is prefixed with `-` then the dimension is decreased
- If the `number` is prefixed with neither `+` nor `-` then the command changes the absolute value of the dimension

## split

```
split (horizontal|vertical|opposite)
```

**If the parent of currently focused window contains more than one child**, then the command

1. Creates a new tiling container
2. Replaces currently focused window with the container
3. Puts the currently focused window into the container as its the only child

The argument configures orientation of the newly created container. `opposite` means opposite orientation compared to the parent
container.

**If the parent of currently focused window contains only a single child** (the window itself), then `split` command changes the
orientation of the parent container

> [!IMPORTANT]
> `split` command does nothing if `enable-normalization-flatten-containers` is turned on. Consider using `join-with` if you want
> to keep `enable-normalization-flatten-containers` enabled

- Available since: 0.3.0-Beta

## workspace-back-and-forth

```
workspace-back-and-forth
```

Switches between currently focused workspace and previously focused workspace back and forth.

- The command doesn't have arguments.

## workspace

```
workspace <target-workspace-name>
```

Activates the specified workspace
