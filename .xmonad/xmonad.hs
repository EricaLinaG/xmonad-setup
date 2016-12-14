--
-- xmonad config
-- Author: Eric Gebhart
-- http://github.com/EricGebhart
--
--
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

import System.IO
import System.Exit
import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators
-- Actions
-- impor XMonad.Actions.PhysicalScreens
import XMonad.Actions.FloatKeys
import XMonad.Actions.WindowGo
import XMonad.Actions.CycleWindows

import XMonad.Actions.CycleWS      -- (16) general workspace-switching
                                   --      goodness
import XMonad.Actions.CycleRecentWS -- (17) cycle between workspaces
                                    --      in most-recently-used order
import XMonad.Actions.Warp         -- (18) warp the mouse pointer
import XMonad.Actions.Submap       -- (19) create keybinding submaps
import XMonad.Actions.Search hiding (Query, images)
import XMonad.Actions.TopicSpace
import XMonad.Actions.GridSelect
import XMonad.Actions.WithAll      -- (22) do something with all windows on a workspace
import qualified XMonad.Actions.DynamicWorkspaceOrder as DO
import XMonad.Actions.DynamicWorkspaces
-- Hooks.
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops

-- Layouts
import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.MultiToggle
import XMonad.Layout.Spacing
-- import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Renamed  -- this replaces named.
import XMonad.Layout.Named
import XMonad.Layout.LayoutScreens
import XMonad.Layout.WorkspaceDir  -- (11) set working directory
import XMonad.Layout.ResizableTile -- (5)  resize non-master windows too
import XMonad.Layout.LayoutHints
import XMonad.Layout.MultiColumns
import XMonad.Layout.OneBig
import XMonad.Layout.TwoPane
import XMonad.Layout.DwmStyle
import XMonad.Layout.IM
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import qualified XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.Tabbed
import XMonad.Layout.Circle
import qualified XMonad.Layout.Grid as G
import XMonad.Layout.GridVariants ( Grid(..) )
import XMonad.Layout.HintedTile
import XMonad.Layout.Accordion
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ThreeColumns
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.Magnifier as Mag
import XMonad.Layout.LayoutModifier ( ModifiedLayout(..) )

-- Prompts ---------------------------------------------------
import XMonad.Prompt                -- (23) general prompt stuff.
import XMonad.Prompt.Man            -- (24) man page prompt
import XMonad.Prompt.AppendFile     -- (25) append stuff to my NOTES file
import XMonad.Prompt.Ssh            -- (26) ssh prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Input          -- (26) generic input prompt, used for
                                    --      making more generic search
                                    --      prompts than those in
                                    --      XMonad.Prompt.Search
import XMonad.Prompt.Workspace      -- (27) prompt for a workspace

-- Utilities
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.List
import Data.Ratio ((%))
import Data.Maybe (fromMaybe, fromJust)

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Paste
import XMonad.Util.NamedScratchpad
import XMonad.Util.Scratchpad
import XMonad.Util.XSelection
import XMonad.Util.EZConfig

import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8

import Control.Arrow hiding ((|||), (<+>))

-------------------------------------------------------------------------
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.

myModMask = mod4Mask

-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

------------------------------------------------------------------------
-- Terminal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "urxvt"
myShell = "zsh"

------------------------------------------------------------------------
-- Colors and borders
--
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#000000" -- "#ffb6b0"
myActiveBorderColor  = "#007c7c"

myFont = "Source Code Pro"
myMonoFont = "Source Code Pro"
myfontwsize = "xft:" ++ myFont ++ ":size=16"

-- theme settings for tabs and deco layouts.
myTheme :: Theme
myTheme = def
          {fontName = "xft:" ++ myFont ++ ":pixelsize=14"
          , decoHeight = 20
          , decoWidth = 400
          , activeColor = myFocusedBorderColor
          , inactiveColor = "#262626"
          , urgentColor = "#073642"
          , activeBorderColor = myFocusedBorderColor
          , inactiveBorderColor = "#586e75"
          , urgentBorderColor = "#586e75"
          , activeTextColor = "#CEFFAC"
          , inactiveTextColor = "#839496"
          , urgentTextColor = "#dc322f"
          }

-- my old tab config theme.
-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = def {   --defaultTheme
    fontName = "xft:" ++ myFont ++ ":pixelsize=14",
    activeBorderColor = "#007C7C",
    activeTextColor = "#CEFFAC",
    activeColor = myFocusedBorderColor,
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

-- Width of the window border in pixels.
myBorderWidth = 1


-- The command to lock the screen or show the screensaver.
myScreensaver = "/usr/bin/gnome-screensaver-command --lock"

-- The command to take a selective screenshot, where you select
-- what you'd like to capture on the screen.
mySelectScreenshot = "select-screenshot"

-- The command to take a fullscreen screenshot.
myScreenshot = "screenshot"

------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
-- Topics replaces this...
-- myWorkspaces = ["1:Code","2:Comm","3:Lang","4:Music","5:media"] ++ map show [6..9]

-- Workspaces using TopicSpace.

data TopicItem = TI { topicName :: Topic
                    , topicDir  :: String
                    , topicAct  :: X ()
                    }

myTopics :: [TopicItem]
myTopics = [ TI "main" "" (return ())
           -- ,  TI "mail" "" (spawnInTopicDir "emacsn -e")
           , TI "yeti" "Projects/Yeti/yeti-stack" (spawnInTopicDir "emacsn -m Yeti")
           , TI "code" "Projects" (spawnInTopicDir "emacsn -m Code")
           , TI "elisp" "Projects/emacs-setup" (spawnInTopicDir "emacsn -m Elisp")
           , TI "comm" "" (spawnInTopicDir "vivaldi" >>
                           spawnInTopicDir "slack" >>
                           spawnInTopicDir "emacsn -e")
           , TI "BD" "BD" (spawnInTopicDir "urxvt -T BD" >>
                           spawnInTopicDir "dolphin --select ~/BD ~/Downloads")
           , TI "Downloads" "Downloads" (spawnInTopicDir "urxvt -T Downloads" >>
                                         spawnInTopicDir "dolphin --select ~/Downloads")
           , TI "French" "Language/Française" (spawnInTopicDir "urxvt -T Française" >>
                                               spawnInTopicDir "dolphin --select ~/Language/Française" >>
                                               spawn "anki")
           , TI "music"  "Music" (spawn "mediacenter22")
           -- , TI "calendar" "" (spawn "vivaldi --app='http://calendar.google.com'")
           , TI "xmonad" ".xmonad" (spawnInTopicDir "emacsn -m Xmonad xmonad.hs ") -- lib/*/*.hs
           --, TI "feeds"  "" (spawn "chromium-browser --app='https://feedbin.me'")
           --, TI "stats"  "" (spawnInTopicDir "urxvtc -e htop")
           ]

myTopicNames :: [Topic]
myTopicNames = map topicName myTopics

myTopicConfig :: TopicConfig
myTopicConfig = TopicConfig
    { topicDirs = M.fromList $ map (topicName &&& topicDir) myTopics
    , defaultTopicAction = const $ return ()
    , defaultTopic = "main"
    , maxTopicHistory = 10
    , topicActions = M.fromList $ map (topicName &&& topicAct) myTopics
    }



-- --- Prompted workspace navigation. ---------------------------------

spawnInTopicDir act = currentTopicDir myTopicConfig >>= spawnIn act

-- spawnShell :: X ()
-- spawnShell =  asks (terminal . config) >>= spawnInTopicDir

spawnShellIn :: Dir -> X ()
spawnShellIn dir = asks (terminal . config) >>= flip spawnIn dir

spawnShell :: X ()
spawnShell = currentTopicDir myTopicConfig >>= spawnShellIn

-- spawnShellIn :: Dir -> X ()
-- spawnShellIn dir = spawn $ "urxvt '(cd ''" ++ dir ++ "'' && " ++ myShell ++ " )'"

spawnIn act dir = spawn $ "cd " ++ dir ++ "; " ++ act

wsgrid = withWindowSet $ \w -> do
    let wss = W.workspaces w
        usednames = map W.tag $  wss
        newnames = filter (\used -> (show used `notElem` (map show myTopicNames))) usednames
    gridselect gsConfig (map (\x -> (x,x)) (myTopicNames ++ newnames))

-- gridselect a workspace and view it
promptedGoto = wsgrid >>= flip whenJust (switchTopic myTopicConfig)
-- gridselect a workspace to shift active window to
promptedShift = wsgrid >>= flip whenJust (windows . W.shift)

-- --- Choose your method:  prompts or Grid select.  - These are prompts.
-- goto :: Topic -> X ()
-- goto = switchTopic myTopicConfig

-- promptedGoto :: X ()
-- promptedGoto = workspacePrompt myXPConfig goto

-- promptedShift :: X ()
-- promptedShift = workspacePrompt myXPConfig $ windows . W.shift

--------------------------------------------------------------------------------


-- pretty communication with the the dbus. ie. xfce-panel.
-- I use a completely transparent panel for this. The background image
-- has a nice multi-colored bar across the top of it. - oceanpark114.jpg
prettyPrinter :: D.Client -> PP

prettyPrinter dbus = def  --defaultPP
  { ppCurrent         = pangoColor "darkgreen" .wrap "[" "]" . pangoSanitize
  --, ppVisible         = wrap "<" ">"
  , ppVisible  = pangoColor "yellow" . wrap "(" ")" . pangoSanitize
  , ppHidden          = id . noScratchPad
  , ppHiddenNoWindows = noScratchPad
  , ppUrgent          = id
  , ppSep             = "   :   "
  , ppWsSep           = "   "
  , ppTitle           = shorten 80
  , ppLayout          = id
  , ppOrder           = id
  , ppOutput          = dbusOutput dbus -- putStrLn
--  , ppSort            = getSortByIndex
  , ppExtras          = []
  }
  where noScratchPad ws = if ws == "NSP" then "" else ws

spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
  spawn program
  windows $ W.greedyView workspace

getWellKnownName :: D.Client -> IO ()
getWellKnownName dbus = do
  D.requestName dbus (D.busName_ "org.xmonad.Log")
                [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  return ()

dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal (D.objectPath_ "/org/xmonad/Log")
                  (D.interfaceName_ "org.xmonad.Log")
                  (D.memberName_ "Update")) {
            D.signalBody = [D.toVariant ("<b>" ++ (UTF8.decodeString str) ++ "</b>")]
        }
    D.emit dbus signal


pangoColor :: String -> String -> String
pangoColor fg = wrap left right
  where
    left  = "<span foreground=\"" ++ fg ++ "\">"
    right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
  where
    sanitize '>'  xs = "&gt;" ++ xs
    sanitize '<'  xs = "&lt;" ++ xs
    sanitize '\"' xs = "&quot;" ++ xs
    sanitize '&'  xs = "&amp;" ++ xs
    sanitize x    xs = x:xs


-- Scratch Pads ------------------------------------------------------------
-- location and dimension.
scratchpadSize = W.RationalRect (1/4) (1/4) (1/3) (3/7)
mySPFloat = customFloating scratchpadSize

-- with a flexible location.
flexScratchpadSize dx dy = W.RationalRect (dx) (dy) (1/3) (3/7)
flexFloatSP dx dy = customFloating (flexScratchpadSize dx dy)

scratchpads =
  [ NS "term"  (myTerminal ++ " -title term") (title =? "term") (flexFloatSP (1/10) (1/10))
  , NS "term2" (myTerminal ++ " -title term2") (title =? "term2") (flexFloatSP (1/3) (1/10))
  , NS "ghci"  (myTerminal ++ " -e ghci") (title =? "ghci") (flexFloatSP (2/3) (1/10))
  --, NS "sync"  (myTerminal ++ " -e sy") (title =? "sy") (flexFloatSP (1/10) (2/3))
  , NS "top"   (myTerminal ++ " -e htop") (title =? "htop") (flexFloatSP (1/4) (1/4))
  , NS "calc"  (myTerminal ++ " -e bc") (title =? "bc") (flexFloatSP (1/4) (1/4))
  , NS "OSX"   "vboxmanage startvm El Capitan" (title =? "El Capitan") (flexFloatSP (2/3) (2/3))
  , NS "MSW"   "vboxmanage startvm Windows" (title =? "Windows") (flexFloatSP (2/3) (2/3))
  ]

-- This is how to make a runSelectedAction grid select menu.
-- A grid select for scratchpads.
myScratchpadMenu =
  [ ("Term1", (scratchToggle "term"))
  , ("Term2", (scratchToggle "term2"))
  , ("ghci",  (scratchToggle "ghci"))
  , ("top",   (scratchToggle "top"))
  , ("sync",  (scratchToggle "sync"))
  , ("calc",  (scratchToggle "calc"))
  , ("OSX",   (scratchToggle "OSX"))
  , ("MSW",   (scratchToggle "MSW"))
  , ("Scratch", scratchpadSpawnActionTerminal  "urxvt -background rgba:0000/0000/0200/c800")
  ]

--- grid select for some apps.
myApps = [("Terminal",     (spawn     myTerminal))

         -- ,("Sublime Text", (raiseApp' "sublime_text"))
         -- ,("Firefox",      (raiseApp  "fox" "firefox"))
         -- ,("Chromium",     (raiseApp  "web" "chromium"))

         -- ,("GVim",         (raiseApp' "gvim"))
         -- ,("Steam",        (raiseApp  "steam" "steam"))
         -- ,("Gimp",         (raiseApp  "gimp" "gimp"))
         -- ,("Win7",         (raiseApp  "Win7" "virtualbox --startvm Win7 --start-paused"))
         -- ,("Inkscape",     (raiseApp  "ink" "inkscape"))

         -- ,("LibreOffice",  (raiseApp  "doc" "libreoffice"))

         ,("Video",        (spawn     "vlc"))
         ,("Themes",       (spawn     "lxappearance"))

         -- ,("Wallpaper",    (raiseApp' "nitrogen"))

         ]

  -- where
  --   raiseApp ws a = (raiseNextMaybe (spawnWS ws a) (appName ~? a)) >> bringMouse
  --   raiseApp' a = (raiseNextMaybe (spawn a) (appName ~? a)) >> bringMouse
  --   --raiseClass ws a c = (raiseNextMaybe (spawnWS ws a) (className ~? c)) >> bringMouse
  --   --raiseClass' a c = (raiseNextMaybe (spawn a) (className ~? c)) >> bringMouse
  --   --gksuApp ws a = (raiseNextMaybe (spawnWS ws ("gksudo " ++ a)) (appName ~? a)) >> bringMouse
  --   --myRaiseTerm a d = (raiseNextMaybe (spawnWS a (termApp a d)) (role ~? a)) >> bringMouse
  --   --termApp a d = myTerm ++ " -r " ++ a ++ " --working-dir=" ++ d ++ " -l " ++ a




------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHelpers = composeAll
    [
    resource  =? "desktop_window" --> doIgnore
    --, className =? "Chromium"       --> doShift "2:Comm"
    --, className =? "Google-chrome"  --> doShift "comm"
    , className =? "Galculator"     --> doFloat
    , className =? "Steam"          --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "gpicview"       --> doFloat
    , className =? "MPlayer"        --> doFloat
    , className =? "vivaldi"        --> doShift "comm"
    , className =? "VirtualBox"     --> doFloat
    --, className =? "VirtualBox"     --> doShift "3:Lang"
    --, className =? "anki"           --> doShift "3:Lang"
    --, title     =? "Anki"           --> doShift "3:Lang"
    --, className =? "Xchat"          --> doShift "5:media"
    , className =? "stalonetray"    --> doIgnore
    , className =? "stalonetray"    --> doIgnore
    , className =? "xfce4-notifyd"  --> doIgnore
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    -- , isDialog -?> doFloat
    -- , isFullscreen --> doFullFloat
  ]


myMoreManageHelpers = composeAll . concat $
   [ [ className =? "Firefox-bin" --> doShift "web" ]
   , [ className =? "Gajim.py"    --> doShift "jabber" ]
   , [(className =? "Firefox" <&&> resource =? "Dialog") --> doFloat]

     -- using list comprehensions and partial matches
   , [ className =?  c --> doFloat | c <- myFloatsC ]
   , [ fmap ( c `isInfixOf`) className --> doFloat | c <- myMatchAnywhereFloatsC ]
   , [ fmap ( c `isInfixOf`) title     --> doFloat | c <- myMatchAnywhereFloatsT ]
   ]
   -- in a composeAll hook, you'd use: fmap ("VLC" `isInfixOf`) title --> doFloat
  where
    myFloatsC = ["Gajim.py", "Xmessage"]
    myMatchAnywhereFloatsC = ["Google","Pidgin"]
    myMatchAnywhereFloatsT = ["VLC","El_Capitan"]

-- -- move and resize on float.  what size and where ?
-- -- Set x, y, gx1, gy1, dx, dy, gx2 and gy2 accordingly.
-- -- or sink it if it's already floating.
-- toggleFloat = withFocused (\windowId -> do
--                               { floats <- gets (W.floating . windowset);
--                                 if windowId `M.member` floats
--                                 then withFocused $ windows . W.sink
--                                 else do
--                                      keysMoveWindowTo (x, y) (gx1, gy1) windowId
--                                      keysResizeWindow (dx, dy) (gx2, gy2) windowId
--                               }
--                           )


manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook (W.RationalRect l t w h)
  where
    h = 0.6
    w = 0.5
    t = 1 - h
    l = 1 - w

myManageHook = myManageHelpers <+>
    myMoreManageHelpers <+>
    manageScratchPad


------------------------------------------------------------------------
-- Layouts
-- Per workspace layouts. without multi-toggle.
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- perworkspace layouts....
 -- layoutH = layoutHints . smartBorders
 --        $ onWorkspace "music"   (tiled
 --                                ||| Mirror tiled
 --                                ||| Full
 --                                )
 --        $ onWorkspace "chat"    (tiled
 --                                ||| Mirror tiled
 --                                ||| Full
 --                                )
 --        $ onWorkspace "web"     (Mirror tiled2
 --                                ||| tiled2
 --                                ||| Full
 --                                )
 --        $ Mirror tiled
 --            ||| tiled
 --            ||| Full
 --            ||| dragPane Horizontal 0.1 0.5
 --  where
 --     tiled  = Tall 1 (3 % 100) (3 % 5)
 --     tiled2 = Tall 1 (3 % 100) (4 % 5)

-- myLayouts = avoidStruts $ smartBorders $
--   onWorkspace "2:im" (named "IM" (reflectHoriz $ withIM (1%8) (Title "Buddy List") (reflectHoriz $ dwmStyle shrinkText myTheme tiled ||| (smartBorders $ tabs)))) $
--   onWorkspace "3:web" (tabs) $
--   (tiled ||| named "Mirror" (Mirror tiled) ||| tabs)
--     where
--       tiled = named "Tall" (ResizableTall 1 (3/100) (1/2) [])
--       tabs = named "Tabs" (tabbed shrinkText myTheme)

-- -- this is one of the layouts provided by grid variants
-- SplitGrid L 2 3 (2/3) (16/10) (5/100)
-- ((modm .|. shiftMask, xK_equal), sendMessage $ IncMasterCols 1),
--  ((modm .|. shiftMask, xK_minus), sendMessage $ IncMasterCols (-1)),
--  ((modm .|. controlMask,  xK_equal), sendMessage $ IncMasterRows 1),
--  ((modm .|. controlMask,  xK_minus), sendMessage $ IncMasterRows (-1))
-- ------------------------------------------------------------------------
-- -- Layouts:

-- this is so we can have layouts with multi-toggle.

data MyTransformers = SIDEBAR
                    | MAG
                    | RFULL
                    | FULL
                    deriving (Read, Show, Eq, Typeable)

instance Transformer MyTransformers Window where
  transform SIDEBAR x k = k (withIM (1/5) (Const True) x) (\(ModifiedLayout _ x') -> x')
  transform MAG x k = k (Mag.magnifiercz 1.2 x) (\(ModifiedLayout _ x') -> x')
  transform RFULL x k = k (avoidStrutsOn [] $ noBorders Full) (const x)
  -- I'm sure I was doing something wrong that caused me to need this.
  transform FULL x k = k (Full) (const x)

-- Change LayoutHintsToCenter to LayoutHints if you like gaps between your windows.
myLayout = configurableNavigation (navigateColor myActiveBorderColor)
           $ mkToggle (single RFULL)
           $ avoidStruts
           $ mkToggle (single MAG)
           $ mkToggle (single FULL)
           $ (onWorkspace "gimp" $ named "gimp" $ withIM (2/11) (Role "gimp-toolbox") $ big')
           $ mkToggle (single SIDEBAR)
           $ layouts
  where
    layouts = tall' ||| cols' ||| twopane' ||| rows' ||| tabs'
        ||| grid' ||| big' ||| circle' ||| bsp' ||| accordion' ||| noborders'
    tall'    = named "tall"   $ layoutHintsToCenter $ XMonad.Tall 1 (3/100) (1/2)
    cols'    = named "cols"   $ layoutHintsToCenter $ deco $ multiCol [1] 2 (3/100) (1/2)
    twopane' = named "two"    $ layoutHintsToCenter $ TwoPane (3/100) (3/7)
    rows'    = named "rows"   $ Mirror $ layoutHintsToCenter $ deco $ multiCol [2] 3 (2/100) (4/7)
    tabs'    = named "tab"    $ layoutHintsToCenter $ tabs
    grid'    = named "grid"   $ layoutHintsToCenter $ deco $ Grid (16/10)
    big'     = named "big"    $ layoutHintsToCenter $ deco $ Mirror $ OneBig (3/4) (19/24)
    circle'  = named "circle" $ layoutHintsToCenter $ Circle
    bsp'     = named "BSP"    $ layoutHintsToCenter $ BSP.emptyBSP
    accordion' = named "accordion" $ layoutHintsToCenter $ mirrorAccordion
    noborders' = named "noborders" $ layoutHintsToCenter $ noBorders (fullscreenFull Full)
    -- basic layouts
    tabs     = tabbed shrinkText myTheme
    deco     = dwmStyle shrinkText myTheme
    mirrorAccordion = Mirror (Accordion)
    -- property query
    role = stringProperty "WM_WINDOW_ROLE"

-- -- My Original layouts...
-- myLayout = avoidStruts (
--     ThreeColMid 1 (3/100) (1/2) |||
--     XMonad.Tall 1 (3/100) (1/2) |||
--     -- Mirror (XMonad.Tall 1 (3/100) (1/2)) |||
--     tabbed shrinkText tabConfig |||
--     -- Full |||
--     -- TwoPane (3/100) (1/2) |||
--     Mag.magnifier emptyBSP |||
--     Circle |||
--     Mag.magnifier tiled ||| hintedTile XMonad.Layout.HintedTile.Tall ||| hintedTile Wide |||
--     -- Accordion |||
--     mirrorAccordion |||
--     -- Grid |||
--     -- spiral (6/7)
--     noBorders (fullscreenFull Full))
--         where
--             mirrorAccordion = Mirror (Accordion)
--             tiled = XMonad.Tall tnmaster tdelta ratio
--             tnmaster = 1
--             ratio = 1/2
--             tdelta = 3/100
--             hintedTile = HintedTile hnmaster hdelta hratio TopLeft
--             hnmaster = 1
--             hratio = 1/2
--             hdelta = 3/100

-- layout prompt (w/ auto-completion and all layouts)
myLayoutPrompt = inputPromptWithCompl mylayoutXPConfig "Layout"
                    (mkComplFunFromList' allLayouts)
                    ?+ (sendMessage . JumpToLayout)
mylayoutXPConfig = def { autoComplete = Just 1000 }
allLayouts = ["tall", "wide", "circle", "full", "tabbed", "accordion"]

-- modified variant of cycleRecentWS from XMonad.Actions.CycleRecentWS (17)
-- which does not include visible but non-focused workspaces in the cycle
cycleRecentWS' = cycleWindowSets options
 where options w = map (W.view `flip` w) (recentTags w)
       recentTags w = map W.tag $ W.hidden w ++ [W.workspace (W.current w)]

-- Warp
bringMouse = warpToWindow (9/10) (9/10)

-- Scratchpad invocation (for brevity)
scratchToggle a = namedScratchpadAction scratchpads a >> bringMouse

mypromptSearch a = promptSearch myXPConfig a

-- Prompts

-- Extra search engines for promptsearch and select search
-- Search Perseus for ancient Greek dictionary entries
greek     = searchEngine "greek"      "http://www.perseus.tufts.edu/hopper/morph?la=greek&l="
images    = searchEngine "images"     "http://www.google.com/search?hl=fr&tbm=isch&q="
reverso   = searchEngine "reverso"    "http://context.reverso.net/traduction/francais-anglais/"
arch      = searchEngine "arch"       "http://wiki.archlinux.org/index.php/Special:Search?search="
archpkgs  = searchEngine "archpkgs"   "https://www.archlinux.org/packages/?sort=&q="
archaur   = searchEngine "archaur"    "https://aur.archlinux.org/packages/?O=0&K="
thesaurus = searchEngine "thesaurus"  "http://thesaurus.reference.com/browse/"
etymology = searchEngine "etymology"  "http://www.etymonline.com/index.php?term="
synonyms  = searchEngine "synonyms"   "http://www.synonymes.com/synonyme.php?mot="
-- synonym  = searchEngine "synonymes" "http://www.les-synonymes.com/mot/"
wiktionnaire = searchEngine "wiktionnaire" "https://fr.wiktionary.org/w/index.php?search="
clojuredocs = searchEngine "clojuredocs" "https://clojuredocs.org/clojure.core/"

promptSearchMenu =
     [ ("man",          (manPrompt myXPConfig))
     , ("google",       (mypromptSearch google))
     , ("hoogle",       (mypromptSearch hoogle))
     , ("clojuredocs",  (mypromptSearch clojuredocs))
     , ("duckduckgo",   (mypromptSearch duckduckgo))
     , ("wikipedia",    (mypromptSearch wikipedia))
     , ("hackage",      (mypromptSearch hackage))
     , ("scholar",      (mypromptSearch scholar))
     , ("math World",   (mypromptSearch mathworld))
     , ("Maps",         (mypromptSearch maps))
     , ("Dictionary",   (mypromptSearch dictionary))
     , ("Alpha",        (mypromptSearch alpha))
     , ("Lucky",        (mypromptSearch lucky))
     , ("Images",       (mypromptSearch images))
     , ("greek",        (mypromptSearch greek))
     , ("Reverso",      (mypromptSearch reverso))
     , ("Arch",         (mypromptSearch arch))
     , ("Arch Pkg",     (mypromptSearch archpkgs))
     , ("Arch AUR",     (mypromptSearch archaur))
     , ("Wiktionnaire", (mypromptSearch wiktionnaire))
     , ("Synonymes.fr", (mypromptSearch synonyms))
     ]

selectSearchMenu =
     [ ("google",       (selectSearch google))
     , ("hoogle",       (selectSearch hoogle))
     , ("clojuredocs",  (selectSearch clojuredocs))
     , ("duckduckgo",   (selectSearch duckduckgo))
     , ("wikipedia",    (selectSearch wikipedia))
     , ("hackage",      (selectSearch hackage))
     , ("scholar",      (selectSearch scholar))
     , ("math World",   (selectSearch mathworld))
     , ("Maps",         (selectSearch maps))
     , ("Dictionary",   (selectSearch dictionary))
     , ("Alpha",        (selectSearch alpha))
     , ("Lucky",        (selectSearch lucky))
     , ("Images",       (selectSearch images))
     , ("greek",        (selectSearch greek))
     , ("Reverso",      (selectSearch reverso))
     , ("Arch",         (selectSearch arch))
     , ("Arch Pkg",     (selectSearch archpkgs))
     , ("Arch AUR",     (selectSearch archaur))
     , ("Wiktionnaire", (selectSearch wiktionnaire))
     , ("Synonymes.fr", (selectSearch synonyms))
     ]

-- some nice colors for the prompt windows to match the dzen status bar.
myXPConfig = def --  defaultXPConfig                            -- (23)
    { fgColor = "#a8a3f7"
    , bgColor = "#3f3c6d"
    , font = "xft:Source Code Pro:size=16"
    , height = 30
    }

crizer :: String -> Bool -> X(String, String)
crizer _ False = return ("#002b36", "#839496")
crizer _ True = return ("#839596", "#002b36")

{-
crizer :: String -> Bool -> X(String, String)
crizer _ False = return ("#fdf6e3", "#657b83")
crizer _ True = return ("#657b83", "#fdf6e3")
-}

gsConfig = def {   -- defaultGSConfig
           gs_colorizer = crizer
        ,  gs_font = "xft:Source Code Pro:pixelsize=20"
}

-- I don't know why, but gotoSelected like
gsConfig2 = def { gs_cellheight = 50
                , gs_cellwidth = 150
                , gs_font = "xft:Source Code Pro:pixelsize=20"
                }

myBack    = "#1a1a1a" -- Bar background
myFore    = "#999999" -- Bar foreground
myAcc     = "#25629f" -- Accent color
myHigh    = "#629f25" -- Highlight color
myLow     = "#000000" -- Lowlight color
myVis     = "#9f2562" -- Visible Workspace
myEmpt    = "#555555" -- Empty workspace

-- GridSelect config
myGSConfig colorizer = (buildDefaultGSConfig colorizer)
  {gs_cellheight  = 50
  ,gs_cellpadding = 5
  ,gs_cellwidth   = 150
  , gs_font = "xft:Source Code Pro:pixelsize=20"
  }

-- Colorizer colors for GridSelect
--aqua   = myColor "#259f62"
blue   = myColor "#25629f"
green  = myColor "#629f25"

-- orange = myColor "#9f6225"
-- pink   = myColor "#9f2562"
-- purple = myColor "#62259f"

-- Colorizer generator
myColor color _ isFg = do
  return $ if isFg
           then (color, myLow)
           else (myLow ,color)

warpToCentre = gets (W.screen . W.current . windowset) >>= \x -> warpToScreen x  0.5 0.5
selectApps   = runSelectedAction (myGSConfig green) myApps

getScratchpad = runSelectedAction (myGSConfig blue) myScratchpadMenu
searchStuff = runSelectedAction (myGSConfig green) promptSearchMenu
selectSearchStuff = runSelectedAction (myGSConfig green) promptSearchMenu

 -- Key Map doc ------------------------------------------------

windowScreenSize :: Window -> X (Rectangle)
windowScreenSize w = withDisplay $ \d -> do
    ws <- gets windowset
    wa <- io $ getWindowAttributes d w
    bw <- fi <$> asks (borderWidth . config)
    sc <- fromMaybe (W.current ws) <$> pointScreen (fi $ wa_x wa) (fi $ wa_y wa)

    return $ screenRect . W.screenDetail $ sc
  where fi x = fromIntegral x

focusedScreenSize :: X (Rectangle)
focusedScreenSize = withWindowSet $ windowScreenSize . fromJust . W.peek

  -- withWindowSet $ \ws -> do
  -- ss <- windowScreenSize $ fromJust $ W.peek ws
  -- return ss

keyColor = "yellow"
cmdColor = "cyan"
-- double quoted so it can make it all the way to dzen.
dzenFont = "\"-*-ubuntu mono-*-*-*-*-*-*-*-*-*-*-*-*\""

keyMapDoc :: String -> X Handle
keyMapDoc name = do
  ss <- focusedScreenSize
  handle <- spawnPipe $ unwords ["~/.xmonad/showHintForKeymap.sh",
                                 name,
                                 show (rect_x ss),
                                 show (rect_y ss),
                                 show (rect_width ss),
                                 show (rect_height ss),
                                 keyColor,
                                 cmdColor,
                                 dzenFont]
  return handle

toSubmap :: XConfig l -> String -> [(String, X ())] -> X ()
toSubmap c name m = do
  pipe <- keyMapDoc name
  submap $ mkKeymap c m
  io $ hClose pipe

------------------------------------------------------------------------
-- Key bindings
--
--
-- Note: Formatting is important for script
focusKeymap = [ ("v",       focus "vivaldi")
              , ("e",       focus "emacs")
              , ("m",       windows W.focusMaster) -- Focus Master
              , ("s",       windows W.swapMaster) -- Swap Master
              , ("/",       spawn menu) -- Menu
              , ("t",       withFocused $ windows . W.sink) -- Sink
              , ("<Up>",    windows W.swapUp) -- Swap Up
              , ("<Down>",  windows W.swapDown) -- Swap Down
              , ("z",       rotOpposite) -- Rotate Opposite
              , ("i",       rotUnfocusedUp) -- Rotate UnFocused UP
              , ("d",       rotUnfocusedDown) -- Rotate Focused Down
              , ("r",       refresh)
              , ("<Right>", sendMessage MirrorExpand) -- Mirror Expand
              , ("<Left>",  sendMessage MirrorShrink) -- Mirror Shrink
              , ("n",       shiftToNext) -- -> Next
              , ("p",       shiftToPrev) -- -> Prev
              , ("S-n",     shiftToNext >> nextWS) -- -> Next & follow
              , ("S-p",     shiftToPrev >> prevWS) -- -> Prev & follow
              ]
  where focus :: String -> X ()
        focus w = spawn ("wmctrl -a " ++ w)
        menu = "wmctrl -l | cut -d' ' -f 5- | sort | uniq -u | dmenu -i | xargs -IWIN wmctrl -F -a WIN"

musicKeymap = [ ("n", mpc "next") -- Next
              , ("N", mpc "prev") -- Prev
              , ("p", mpc "toggle") -- Toggle
              , ("r", mpc "random") -- Random
              , ("l", mpc "repeat") -- Repeat
              ]
  where mpc c = spawn ("mpc " ++ c)

masterKeymap = [ ("f",      windows W.focusMaster) -- Focus
               , ("s",      windows W.swapMaster) -- Swap
               , ("h",      sendMessage Shrink) -- Shrink
               , ("l",      sendMessage Expand) -- Expand
               , ("k",      incMaster) -- Master++
               , ("j",      decMaster) -- Master--
               , ("<Up>",   incMaster) -- Master++
               , ("<Down>", decMaster) -- Master--
               ]
  where incMaster       = sendMessage (IncMasterN 1)
        decMaster       = sendMessage (IncMasterN (-1))


shotKeymap = [ ("c", setContext) -- Set Context
             , ("s", takeShot select) -- Take Select
             , ("w", takeShot currentWindow) -- Take Current Window
             , ("o", openDirectory) -- Open Directory
             ]
  where setContext = spawn ("~/.xmonad/sshot-context.sh")
        takeShot a = spawn ("scrot " ++ a ++ " ~/screenshots/current-context/'%Y-%m-%dT%H%M%S_$wx$h.png'")
        openDirectory = spawn ("xdg-open ~/screenshots/current-context/")
        select        = "-s"
        currentWindow = "-u"

-- Make sure you have $BROWSER set in your environment.
promptSearchKeymap =
     [ ("m", manPrompt myXPConfig) -- Man Pages
     , ("g", promptSearch myXPConfig google) -- Google
     , ("d", promptSearch myXPConfig duckduckgo) -- duck duck go
     , ("w", promptSearch myXPConfig wikipedia) -- wikipedia
     , ("h", promptSearch myXPConfig hackage) -- hackage
     , ("s", promptSearch myXPConfig scholar) -- Scholar
     , ("S-m", promptSearch myXPConfig mathworld) -- Math World
     , ("c", promptSearch myXPConfig maps) -- Maps / Cartes
     , ("S-d", promptSearch myXPConfig dictionary) -- Dictionary
     , ("a", promptSearch myXPConfig alpha) -- Alpha
     , ("l", promptSearch myXPConfig lucky) -- Lucky
     , ("i", promptSearch myXPConfig images) -- Images
     , ("k", promptSearch myXPConfig greek) -- Greek
     , ("r", promptSearch myXPConfig reverso) -- Reverso
     ]

selectSearchKeymap =
    [ ("g", selectSearch google) -- Google
    , ("d", selectSearch duckduckgo) -- Duckduckgo
    , ("w", selectSearch wikipedia) -- Wikipedia
    , ("h", selectSearch hackage) -- hackage
    , ("s", selectSearch scholar) -- Scholar
    , ("m", selectSearch mathworld) -- Mathworld
    , ("c", selectSearch maps) -- Maps / Cartes
    , ("S-d", selectSearch dictionary) -- Dictionary
    , ("a", selectSearch alpha) -- Alpha
    , ("l", selectSearch lucky) -- Lucky
    , ("i", selectSearch images) -- Images
    , ("k", selectSearch greek) -- Greek
    , ("r", selectSearch reverso) -- Reverso
    ]


 -- some prompts.
 -- ability to change the working dir for a workspace.
promptsKeymap =
        [ ("d",   changeDir myXPConfig) -- Change Dir
        , ("m",   manPrompt myXPConfig) -- Man Pages
        , ("r",   spawn "exe=`dmenu_run -fn myfontwsize -b -nb black -nf yellow -sf yellow` && eval \"exec $exe\"") -- dmenu
        , ("n",   appendFilePrompt myXPConfig "$HOME/NOTES") -- append notes
        , ("S-s", sshPrompt myXPConfig) -- SSH
        , ("z",   shellPrompt myXPConfig) -- Shell
        , ("s",   promptSearch myXPConfig $ intelligent multi) -- Multi Search
        ]

        -- , ("e", spawn "exe=`echo | yeganesh -x` && eval \"exec $exe\"")

namedScratchpadsKeymap =
    [ ("o", scratchToggle "term") -- Term
    , ("e", scratchToggle "term2") -- Term2
    , ("g", scratchToggle "ghci") -- ghci
    , ("c", scratchToggle "calc") -- calc
    , ("t", scratchToggle "top") -- top
    , ("S-o", scratchToggle "OSX") -- OS X
    , ("w", scratchToggle "MSW") -- MS Windows
    , ("n", scratchpadSpawnActionTerminal  "urxvt -background rgba:0000/0000/0200/c800") -- scratchpad
    ]

xfceKeymap =
    [ ("M4-n", spawnShell) -- Terminal
    , ("q",    spawn "fce4-session-logout")
    , ("S-p",  spawn "xfce4-appfinder")
    , ("q",    spawn "fce4-session-logout")
    ]

magnifierKeymap =
    [ ("+",   sendMessage Mag.MagnifyMore)  -- More
    , ("-",   sendMessage Mag.MagnifyLess)  -- Less
    , ("o",   sendMessage Mag.ToggleOff  )  -- Off
    , ("S-o", sendMessage Mag.ToggleOn   )  -- On
    , ("m",   sendMessage Mag.Toggle     )  -- Toggle
    ]

--- workspacesKeymap
workspacesKeymap =
    [ ("z",      toggleWS)
    , ("n",      nextWS)
    , ("p",      prevWS)
    , ("<Up>",   nextScreen)
    , ("<Down>", prevScreen)
    , ("S-n",    shiftToNext)
    , ("S-p",    shiftToPrev)
    , ("C-n",    shiftToNext >> nextWS)
    , ("C-p",    shiftToPrev >> prevWS)
    , ("<Tab>",  cycleRecentWS' [xK_Super_L, xK_Shift_L] xK_Tab xK_grave) -- Cycle Recent
    , ("S-z",    killAll >> DO.moveTo Prev HiddenNonEmptyWS) -- Kill All
    , ("g",      promptedGoto) -- prompted Goto
    , ("s",      promptedShift) -- prompted Shift
    , ("M-+",    addWorkspacePrompt myXPConfig) -- Add
    , ("M--",    removeWorkspace) -- Remove
    , ("S-g",    selectWorkspace myXPConfig) -- Select
    , ("C-<R>",  DO.swapWith Next NonEmptyWS) -- Swap Next
    , ("C-<L>",  DO.swapWith Prev NonEmptyWS) -- Swap Prev
    , ("S-<R>",  DO.shiftTo Next HiddenNonEmptyWS) -- Shift to Next
    , ("S-<L>",  DO.shiftTo Prev HiddenNonEmptyWS) -- Shift to Prev
    , ("<R>",    DO.moveTo Next HiddenNonEmptyWS) -- Move to Next
    , ("<L>",    DO.moveTo Prev HiddenNonEmptyWS) -- Move to Prev
    ]

layoutKeymap = [("f",   sendMessage (Toggle FULL)) --toggle Full
    , ("s",   sendMessage (Toggle SIDEBAR)) -- toggle sidebar
    , ("M-d", sendMessage (Toggle MAG)) -- toggle mag
    , ("S-f", sendMessage (Toggle RFULL)) -- Full without panel, border
    , ("t",   withFocused $ windows . W.sink) -- sink focused window
    , ("S-t", sinkAll) -- sink all windows
    , ("r",   rescreen) -- Rescreen
    , ("2",   layoutSplitScreen 2 $ TwoPane (3/100) (1/2)) -- Split Screen two pane
    , ("3",   layoutSplitScreen 3 $ ThreeColMid 1 (3/100) (1/2)) -- Split Screen 3 Col
    , ("4",   layoutSplitScreen 4 $ G.Grid) -- Split Screen Grid
    ]

floatKeymap =
    [ ("d",       withFocused (keysResizeWindow (-20,-20) (1%2,1%2))) -- Resize Smaller
    , ("s",       withFocused (keysResizeWindow (20,20) (1%2,1%2))) -- Resize Bigger
    , ("<Right>", withFocused (keysMoveWindow (40,0) )) -- Move Right
    , ("<Down>",  withFocused (keysMoveWindow (0,40) )) -- Move Down
    , ("<Left>",  withFocused (keysMoveWindow (-40,0))) -- Move Left
    , ("<Up>",    withFocused (keysMoveWindow (0,-40))) -- Move Up
    , ("S-s",     withFocused $ windows . W.sink) -- Sink

    , ("g",  moveFocusedWindowToRel (0,0)) -- Top Left
    , ("c",  moveFocusedWindowToRel (1%2, 0)) -- Top Center
    , ("r",  moveFocusedWindowToRel (1,0)) -- Top Right
    , ("h",  moveFocusedWindowToRel (0, 1%2)) -- Left Center
    , ("t",  moveFocusedWindowToRel (1%2, 1%2)) -- Center
    , ("n",  moveFocusedWindowToRel (1, 1%2)) -- Right Center
    , ("m",  moveFocusedWindowToRel (0,1)) -- Bottom Left
    , ("w",  moveFocusedWindowToRel (1%2, 1)) -- Bottom Center
    , ("v",  moveFocusedWindowToRel (1,1)) -- Bottom Right
    ] where
         moveFocusedWindowToRel (wMult, hMult) =
             do screenSize <- focusedScreenSize
                let screenX = round (wMult * fromIntegral (rect_width screenSize))
                    screenY = round (hMult * fromIntegral (rect_height screenSize))
                    sY = (if screenY == 0 then 40 else screenY)
                    sX = (if screenX == 0 then 40 else screenX)
                withFocused (keysMoveWindowTo (sX, sY) (wMult, hMult))

-- BSP layout controls.
bspKeymap =
    [ ("<Right>",   sendMessage $ BSP.ExpandTowards R) -- Expand Right
    , ("<Left>",    sendMessage $ BSP.ExpandTowards L) -- Expand Left
    , ("<Up>",      sendMessage $ BSP.ExpandTowards D) -- Expand Down
    , ("<Down>",    sendMessage $ BSP.ExpandTowards U) -- Expand Up
    , ("S-<Right>", sendMessage $ BSP.ShrinkFrom R) -- Shrink Right
    , ("S-<Left>",  sendMessage $ BSP.ShrinkFrom L) -- Shrink Left
    , ("S-<Down>",  sendMessage $ BSP.ShrinkFrom D) -- Shrink Down
    , ("S-<Up>",    sendMessage $ BSP.ShrinkFrom U) -- Shrink Up
    , ("r",         sendMessage BSP.Rotate) -- Rotate
    , ("s",         sendMessage BSP.Swap) -- Swap
    , ("p",         sendMessage BSP.FocusParent) -- Focus Parent
    , ("n",         sendMessage BSP.SelectNode) -- Select Node
    , ("m",         sendMessage BSP.MoveNode) -- Move Node
    , ("b",         sendMessage BSP.Balance) -- Balance
    , ("e",         sendMessage BSP.Equalize) -- Equalize
    ]

raiseKeymap =
    [ ("v", runOrRaiseNext "Vivaldi" (className =? "Vivaldi")) -- Vivaldi
    , ("e", raiseNext (className =? "Emacs")) -- Emacs cycle
    , ("s", runOrRaise "Slack" (className =? "Slack")) -- Slack
    ]

    --    , ("M4-S-<Space>",  setLayout $ XMonad.layoutHook conf)
    -- , ("m", raiseMaybe     (runInTerm "-title mutt" "mutt") (title =? "mutt"))
    --    , ("M4-S-<Space>",  setLayout $ XMonad.layoutHook conf)

mainKeymap c = mkKeymap c $
  [ ("M4-S-<Return>",   spawn myTerminal) -- Terminal
    , ("M4-n",          spawnShell) -- Terminal
    , ("M4-S-c",        kill) -- Kill window
    , ("M4-Insert",     pasteSelection) -- Paste selection
    , ("M4-<Space>",    sendMessage NextLayout) -- Next Layout
    , ("M4-S-<Space>",  myLayoutPrompt) -- Layout prompt
    , ("M4-k",          nextWindow)
    , ("M4-j",          prevWindow)
    , ("M4-S-k",        windows W.swapUp) -- Swap Up
    , ("M4-S-j",        windows W.swapDown) -- Swap Down
    , ("M4-<Tab>",      nextWindow) -- Next Window
    , ("M4-S-<Tab>",    prevWindow) -- Prev Window
    , ("M4-d", spawn "exe=`dmenu_run -fn myfontwsize -b -nb black -nf yellow -sf yellow` && eval \"exec $exe\"") -- dmenu
    , ("M4-t",          promptedGoto) -- Grid Select Workspace
    , ("M4-h",          goToSelected gsConfig2) -- Grid Select Window
    , ("M4-S-h",        bringSelected gsConfig2) -- Bring Grid Selected Window
    , ("M4-S-t",        promptedShift) -- Grid Select Shift
    , ("M4-C-g",        spawnSelected gsConfig ["krita","dolphin","Repetier-Host"]) -- Apps
    , ("M4-s",          sendMessage Shrink) -- Shrink
    , ("M4-e",          sendMessage Expand) -- Expand
    , ("M4-S-b",        sendMessage ToggleStruts) -- Toggle Struts
    , ("M4-q",          spawn "xmonad --recompile; xmonad --restart") -- Restart
    , ("M4-S-q",        io $ exitWith ExitSuccess) -- Quit
    , ("M4-C-x",        spawn "xscreensaver-command -lock") -- screen lock
    , ("M4-x",          spawn "xscreensaver-command -activate")  -- screensaver
    , ("M4-a",          toSubmap c "masterKeymap" masterKeymap) -- master pane
    , ("M4-b",          toSubmap c "bspKeymap" bspKeymap) -- BSP
    , ("M4-f",          toSubmap c "focusKeymap" focusKeymap) -- Focus
    , ("M4-u",          toSubmap c "floatKeymap" floatKeymap) -- Float
    , ("M4-l",          toSubmap c "layoutKeymap" layoutKeymap) -- Layout
    , ("M4-m",          toSubmap c "musicKeymap" musicKeymap) -- Music
    , ("M4-S-m",        toSubmap c "mainKeymap" []) -- Main
    , ("M4-p",          toSubmap c "promptsKeymap" promptsKeymap) -- Prompts
    , ("M4-r",          toSubmap c "raiseKeymap" raiseKeymap) -- Raise
    , ("M4-o",          toSubmap c "namedScratchpadsKeymap" namedScratchpadsKeymap) -- Scratchpad
    , ("M4-S-s",        toSubmap c "shotKeymap" shotKeymap) -- ScreenShot
    , ("M4-w",          toSubmap c "workspacesKeymap" workspacesKeymap) -- Workspaces
    , ("M4-/",          toSubmap c "promptSearchKeymap" promptSearchKeymap) -- Prompt Search
    , ("M4-S-/",        toSubmap c "selectSearchKeymap" selectSearchKeymap) -- Select Search
    , ("M4-z",          getScratchpad)
    , ("M4-i",          searchStuff)
    , ("M4-S-i",        selectSearchStuff)
    ]
  where nextWindow      = windows W.focusDown
        prevWindow      = windows W.focusUp


------------------------------------------------------------------------

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()


------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--

fadeinactive = fadeInactiveLogHook fadeAmount
   where fadeAmount = 0.7

myConfig = do
    dbus <- D.connectSession
    getWellKnownName dbus
    return $  defaults {
          logHook = do
            ewmhDesktopsLogHook
            dynamicLogWithPP $ (prettyPrinter dbus)
            fadeinactive

        , manageHook = manageDocks <+> myManageHook <+>
          namedScratchpadManageHook scratchpads
        , layoutHook = layoutHook defaults
        , handleEventHook = ewmhDesktopsEventHook
        , startupHook = do
             ewmhDesktopsStartup
             myStartupHook        -- >> setWMName "LG3D"
        }

------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will

-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--

  -- defaultConfig
defaults = def {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myTopicNames,  -- MyWorkspaces
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = mainKeymap,
    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = myLayout, -- smartBorders $ myLayout,
    manageHook         = myManageHook,
    startupHook        = myStartupHook
    } -- `additionalKeysP` myadditionalKeys

main :: IO ()
main = xmonad =<< myConfig
