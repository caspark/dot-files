#r "C:\Program Files\workspacer\workspacer.Shared.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.Bar\workspacer.Bar.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.ActionMenu\workspacer.ActionMenu.dll"
#r "C:\Program Files\workspacer\plugins\workspacer.FocusIndicator\workspacer.FocusIndicator.dll"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using workspacer;
using workspacer.Bar;
using workspacer.ActionMenu;
using workspacer.FocusIndicator;

Func<IWindow, Boolean> shouldManageWindow = window =>
{
    if (new[] {
        "MozillaWindowClass", // firefox
        "CASCADIA_HOSTING_WINDOW_CLASS", // windows terminal
        "vcxsrv/x X rl", // windows from vcxrsv (x window server - e.g. emacs)
        "dopus.lister", // directory opus lister
    }.Any(className => window.Class == className))
    {
        return true;
    }

    if (new[] { " - Visual Studio Code" }.Any(titleSuffix => window.Title.EndsWith(titleSuffix)))
    {
        return true;
    }

    return false;
};

Action<IConfigContext> configureKeybinds = context =>
{
    context.Keybinds.UnsubscribeAll();
    KeyModifiers mod = KeyModifiers.Win | KeyModifiers.LAlt;

    // Rebind everything for colemak bindings.
    // The original bindings are in SubscribeDefaults() of
    // https://github.com/rickbutton/workspacer/blob/master/src/workspacer/Keybinds/KeybindManager.cs

    context.Keybinds.Subscribe(MouseEvent.LButtonDown,
                () => context.Workspaces.SwitchFocusedMonitorToMouseLocation());

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.H,
        () => context.Enabled = !context.Enabled, "toggle enable/disable");

    context.Keybinds.Subscribe(mod, Keys.OemSemicolon,
        () => context.Workspaces.FocusedWorkspace.ResetLayout(), "reset layout");

    context.Keybinds.Subscribe(mod, Keys.Down,
        () => context.Workspaces.FocusedWorkspace.FocusNextWindow(), "focus next window");

    context.Keybinds.Subscribe(mod, Keys.Up,
        () => context.Workspaces.FocusedWorkspace.FocusPreviousWindow(), "focus previous window");

    context.Keybinds.Subscribe(mod, Keys.K,
        () => context.Workspaces.FocusedWorkspace.FocusPrimaryWindow(), "focus primary window");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.K,
        () => context.Workspaces.FocusedWorkspace.SwapFocusAndPrimaryWindow(), "swap focus and primary window");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.Down,
        () => context.Workspaces.FocusedWorkspace.SwapFocusAndNextWindow(), "swap focus and next window");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.Up,
        () => context.Workspaces.FocusedWorkspace.SwapFocusAndPreviousWindow(), "swap focus and previous window");

    context.Keybinds.Subscribe(mod, Keys.M,
        () => context.Workspaces.FocusedWorkspace.ShrinkPrimaryArea(), "shrink primary area");

    context.Keybinds.Subscribe(mod, Keys.O,
        () => context.Workspaces.FocusedWorkspace.ExpandPrimaryArea(), "expand primary area");

    context.Keybinds.Subscribe(mod, Keys.Oemcomma,
        () => context.Workspaces.FocusedWorkspace.IncrementNumberOfPrimaryWindows(), "increment # primary windows");

    context.Keybinds.Subscribe(mod, Keys.OemPeriod,
        () => context.Workspaces.FocusedWorkspace.DecrementNumberOfPrimaryWindows(), "decrement # primary windows");

    context.Keybinds.Subscribe(mod, Keys.H,
        () => context.Windows.ToggleFocusedWindowTiling(), "toggle tiling for focused window");

    // context.Keybinds.Subscribe(mod | KeyModifiers.LShift, Keys.Q, context.Quit, "quit workspacer");

    // context.Keybinds.Subscribe(mod, Keys.Q, context.Restart, "restart workspacer");

    context.Keybinds.Subscribe(mod, Keys.Left,
        () => context.Workspaces.SwitchToPreviousWorkspace(), "switch to previous workspace");

    context.Keybinds.Subscribe(mod, Keys.Right,
        () => context.Workspaces.SwitchToNextWorkspace(), "switch to next workspace");

    Action<Boolean> moveWindowToNext = (toNext) =>
    {
        IWindow window = context.Workspaces.FocusedWorkspace.FocusedWindow;
        IWorkspace target = toNext
                ? context.WorkspaceContainer.GetNextWorkspace(context.Workspaces.FocusedWorkspace)
                : context.WorkspaceContainer.GetPreviousWorkspace(context.Workspaces.FocusedWorkspace);
        int targetIdx = context.WorkspaceContainer.GetWorkspaces(context.Workspaces.FocusedWorkspace).ToList().IndexOf(target);
        context.Workspaces.MoveFocusedWindowToWorkspace(targetIdx);

        // unfortunately, after moving a window to another workspace, workspacer automatically asks
        // the next window in the current workspace to be focused, so if we switch away too quickly
        // then that window will be flashing to request focus. To avoid this, sleep for a bit before
        // switching to another workspace ourselves.
        Thread.Sleep(50);
        if (toNext) {
            context.Workspaces.SwitchToNextWorkspace();
        } else {
            context.Workspaces.SwitchToPreviousWorkspace();
        }

        // re-focus the window we just moved, so that we can move it to another workspace again if
        // we want
        window.Focus();
    };

    context.Keybinds.Subscribe(mod | KeyModifiers.Control, Keys.Left,
        () =>
        {
            moveWindowToNext(false);
        }, "move focused window to previous workspace");

    context.Keybinds.Subscribe(mod | KeyModifiers.Control, Keys.Right,
        () =>
        {
            moveWindowToNext(true);
        }, "move focused window to next workspace");

    context.Keybinds.Subscribe(mod, Keys.N,
        () => context.Workspaces.SwitchToWorkspace(0), "switch to workspace 1");

    context.Keybinds.Subscribe(mod, Keys.E,
        () => context.Workspaces.SwitchToWorkspace(1), "switch to workspace 2");

    context.Keybinds.Subscribe(mod, Keys.I,
        () => context.Workspaces.SwitchToWorkspace(2), "switch to workspace 3");

    context.Keybinds.Subscribe(mod, Keys.L,
        () => context.Workspaces.SwitchToWorkspace(3), "switch to workspace 4");

    context.Keybinds.Subscribe(mod, Keys.U,
        () => context.Workspaces.SwitchToWorkspace(4), "switch to workspace 5");

    context.Keybinds.Subscribe(mod, Keys.Y,
        () => context.Workspaces.SwitchToWorkspace(5), "switch to workspace 6");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.N,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(0), "move focused window to workspace 1");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.E,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(1), "move focused window to workspace 2");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.I,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(2), "move focused window to workspace 3");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.L,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(3), "move focused window to workspace 4");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.U,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(4), "move focused window to workspace 5");

    context.Keybinds.Subscribe(mod | KeyModifiers.LControl, Keys.Y,
        () => context.Workspaces.MoveFocusedWindowToWorkspace(5), "move focused window to workspace 6");
};

Action<IConfigContext> doConfig = (context) =>
{
    context.AddBar();
    context.AddFocusIndicator();
    var actionMenu = context.AddActionMenu();

    context.WorkspaceContainer.CreateWorkspaces("near", "each", "sit", "look", "urge", "yank");
    context.WindowRouter.AddFilter(shouldManageWindow);

    configureKeybinds(context);
};
return doConfig;
