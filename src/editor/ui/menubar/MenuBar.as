﻿package editor.ui.menubar {
    import editor.commons.Level;
    import editor.layers.object.ObjectLayer;
    import editor.undo.Undoes;

    import flash.desktop.NativeApplication;
    import flash.display.NativeMenu;
    import flash.display.NativeMenuItem;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.ui.Keyboard;
    import flash.utils.setTimeout;

    public class MenuBar {
        private var stage:Stage;

        private var menuFile:NativeMenuItem;
        private var menuEdit:NativeMenuItem;
        private var menuView:NativeMenuItem;
        private var menuAbout:NativeMenuItem;

        private var _hasDelayedCall:Boolean = false;

        public function MenuBar(stage:Stage) {
            this.stage = stage;

            var menuItem:NativeMenuItem;
            var menu:NativeMenu = new NativeMenu;
            var menuWindow:NativeMenuItem;

            if (NativeApplication.supportsMenu) {
                menu = NativeApplication.nativeApplication.menu;
                menu.removeItemAt(1);
                menu.removeItemAt(1);
                menuWindow = menu.getItemAt(1);
                menu.removeItemAt(1);
            }
            else {
                stage.nativeWindow.menu = menu;
            }

            /* ========== FILE ========= */
            menuFile = new NativeMenuItem("File");
            menu.addItem(menuFile);
            menuFile.submenu = new NativeMenu;
            //OPEN
            menuItem = new NativeMenuItem("Open Project");
            menuItem.name = "open project";
            menuItem.addEventListener(Event.SELECT, onOpenProject);
            menuFile.submenu.addItem(menuItem);
            //CLOSE
            menuItem = new NativeMenuItem("Close Project");
            menuItem.name = "close project";
            menuItem.addEventListener(Event.SELECT, onCloseProject);
            menuFile.submenu.addItem(menuItem);
            //RELOAD
            menuItem = new NativeMenuItem("Reload Project");
            menuItem.name = "reload project";
            menuItem.addEventListener(Event.SELECT, onReloadProject);
            menuFile.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuFile.submenu.addItem(menuItem);
            //NEW
            menuItem = new NativeMenuItem("New Level");
            menuItem.name = "new level";
            menuItem.keyEquivalent = "n";
            menuItem.addEventListener(Event.SELECT, onNewLevel);
            menuFile.submenu.addItem(menuItem);
            //OPEN
            menuItem = new NativeMenuItem("Open Level");
            menuItem.name = "open level";
            menuItem.keyEquivalent = "o";
            menuItem.addEventListener(Event.SELECT, onOpenLevel);
            menuFile.submenu.addItem(menuItem);
            //SAVE
            menuItem = new NativeMenuItem("Save Level");
            menuItem.name = "save level";
            menuItem.keyEquivalent = "s";
            menuItem.addEventListener(Event.SELECT, onSaveLevel);
            menuFile.submenu.addItem(menuItem);
            //SAVE
            menuItem = new NativeMenuItem("Save Level as");
            menuItem.name = "save level as";
            menuItem.keyEquivalent = "s";
            menuItem.keyEquivalentModifiers = [Keyboard.SHIFT, Keyboard.COMMAND];
            menuItem.addEventListener(Event.SELECT, onSaveLevelAs);
            menuFile.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuFile.submenu.addItem(menuItem);
            //PNG
            menuItem = new NativeMenuItem("Save Level as PNG");
            menuItem.name = "save png";
            menuItem.addEventListener(Event.SELECT, onSaveLevelAsPNG);
            menuFile.submenu.addItem(menuItem);
            //PNG
            menuItem = new NativeMenuItem("Open Project Directory");
            menuItem.name = "open dir";
            menuItem.addEventListener(Event.SELECT, onOpenDirectory);
            menuFile.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuFile.submenu.addItem(menuItem);
            //EXIT
            menuItem = new NativeMenuItem("Exit");
            menuItem.addEventListener(Event.SELECT, onExit);
            menuFile.submenu.addItem(menuItem);

            /* ========== EDIT ========= */
            menuEdit = new NativeMenuItem("Edit");
            menu.addItem(menuEdit);

            menuEdit.submenu = new NativeMenu;
            //CLEAR LAYER
            menuItem = new NativeMenuItem("Clear Layer");
            menuItem.name = "clear layer";
            menuItem.addEventListener(Event.SELECT, onClearLayer);
            menuEdit.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuEdit.submenu.addItem(menuItem);
            //UNDO
            menuItem = new NativeMenuItem("Undo");
            menuItem.name = "undo";
            menuItem.keyEquivalent = "z";
            menuItem.addEventListener(Event.SELECT, onUndo);
            menuEdit.submenu.addItem(menuItem);
            //REDO
            menuItem = new NativeMenuItem("Redo");
            menuItem.name = "redo";
            menuItem.keyEquivalent = "y";
            menuItem.addEventListener(Event.SELECT, onRedo);
            menuEdit.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuEdit.submenu.addItem(menuItem);
            //SELECT ALL
            menuItem = new NativeMenuItem("Select All");
            menuItem.name = "select all";
            menuItem.keyEquivalent = "a";
            menuItem.addEventListener(Event.SELECT, onSelectAll);
            menuEdit.submenu.addItem(menuItem);
            //DUPLICATE OBJECTS
            menuItem = new NativeMenuItem("Duplicate Object");
            menuItem.name = "duplicate objects";
            menuItem.keyEquivalent = "d";
            menuItem.addEventListener(Event.SELECT, onDuplicateObjects);
            menuEdit.submenu.addItem(menuItem);

            /* ========== VIEW ========= */
            menuView = new NativeMenuItem("View");
            menu.addItem(menuView);

            menuView.submenu = new NativeMenu;
            //ZOOM IN
            menuItem = new NativeMenuItem("Zoom In");
            menuItem.name = "zoom in";
            menuItem.keyEquivalent = "=";
            menuItem.addEventListener(Event.SELECT, onZoomIn);
            menuView.submenu.addItem(menuItem);
            //ZOOM OUT
            menuItem = new NativeMenuItem("Zoom Out");
            menuItem.name = "zoom out";
            menuItem.keyEquivalent = "-";
            menuItem.addEventListener(Event.SELECT, onZoomOut);
            menuView.submenu.addItem(menuItem);
            //CENTER VIEW
            menuItem = new NativeMenuItem("Center View");
            menuItem.name = "center view";
            menuItem.addEventListener(Event.SELECT, onCenterView);
            menuView.submenu.addItem(menuItem);
            //----
            menuItem = new NativeMenuItem("", true);
            menuView.submenu.addItem(menuItem);
            //GRID
            menuItem = new NativeMenuItem("Show Grid");
            menuItem.name = "grid";
            menuItem.keyEquivalent = "g";
            menuItem.addEventListener(Event.SELECT, onGrid);
            menuView.submenu.addItem(menuItem);
            //DEBUG WINDOW
            menuItem = new NativeMenuItem("Show Debug Window");
            menuItem.name = "debug";
            menuItem.addEventListener(Event.SELECT, onDebugWindow);
            menuView.submenu.addItem(menuItem);

            if (menuWindow) {
                menu.addItem(menuWindow);
            }

            /* ========== ABOUT ========= */
            menuAbout = new NativeMenuItem("About");
            menu.addItem(menuAbout);

            menuAbout.submenu = new NativeMenu;
            //WEBSITE
            menuItem = new NativeMenuItem("Open Website");
            menuItem.addEventListener(Event.SELECT, onWebsite);
            menuAbout.submenu.addItem(menuItem);

            refreshState();
        }

        public function refreshWithDelay():void {
            if (!_hasDelayedCall) {
                _hasDelayedCall = true;
                setTimeout(refreshState, 100);
            }
        }

        public function refreshState():void {
            _hasDelayedCall = false;

            var projectLoaded:Boolean = (Ogmo.level != null);

            //FILE
            if (menuFile.submenu.getItemByName("open project").enabled !== !projectLoaded) {
                menuFile.submenu.getItemByName("open project").enabled = !projectLoaded;
            }
            if (menuFile.submenu.getItemByName("close project").enabled !== projectLoaded) {
                menuFile.submenu.getItemByName("close project").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("reload project").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("reload project").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("new level").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("new level").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("open level").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("open level").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("save level").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("save level").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("save png").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("save png").enabled = projectLoaded;
            }
            if (menuFile.submenu.getItemByName("open dir").enabled !== projectLoaded){
                menuFile.submenu.getItemByName("open dir").enabled = projectLoaded;
            }

            //EDIT
            if (projectLoaded) {
                if (Ogmo.level.selectedLayer is Undoes) {
                    var lay:Undoes = Ogmo.level.selectedLayer as Undoes;
                    if (menuEdit.submenu.getItemByName("undo").enabled !== lay.canUndo()){
                        menuEdit.submenu.getItemByName("undo").enabled = lay.canUndo();
                    }
                    if (menuEdit.submenu.getItemByName("redo").enabled !== lay.canRedo()){
                        menuEdit.submenu.getItemByName("redo").enabled = lay.canRedo();
                    }
                }
                else {
                    if (menuEdit.submenu.getItemByName("undo").enabled !== false){
                        menuEdit.submenu.getItemByName("undo").enabled = false;
                    }
                    if (menuEdit.submenu.getItemByName("redo").enabled !== false){
                        menuEdit.submenu.getItemByName("redo").enabled = false;
                    }
                }
                if (Ogmo.level.selectedLayer is ObjectLayer) {
                    if (menuEdit.submenu.getItemByName("select all").enabled !== true){
                        menuEdit.submenu.getItemByName("select all").enabled = true;
                    }
                    if ((Ogmo.level.selectedLayer as ObjectLayer).selection.length > 0) {
                        if (menuEdit.submenu.getItemByName("duplicate objects").enabled !== true){
                            menuEdit.submenu.getItemByName("duplicate objects").enabled = true;
                        }
                        if ((Ogmo.level.selectedLayer as ObjectLayer).selection.length > 1) {
                            if (menuEdit.submenu.getItemByName("duplicate objects").label !== "Duplicate Objects"){
                                menuEdit.submenu.getItemByName("duplicate objects").label = "Duplicate Objects";
                            }
                        } else {
                            if (menuEdit.submenu.getItemByName("duplicate objects").label !== "Duplicate Object"){
                                menuEdit.submenu.getItemByName("duplicate objects").label = "Duplicate Object";
                            }
                        }
                    }
                }
            }
            else {
                if (menuEdit.submenu.getItemByName("undo").enabled !== false){
                    menuEdit.submenu.getItemByName("undo").enabled = false;
                }
                if (menuEdit.submenu.getItemByName("redo").enabled !== false){
                    menuEdit.submenu.getItemByName("redo").enabled = false;
                }
                if (menuEdit.submenu.getItemByName("select all").enabled !== false){
                    menuEdit.submenu.getItemByName("select all").enabled = false;
                }
                if (menuEdit.submenu.getItemByName("duplicate objects").enabled !== false){
                    menuEdit.submenu.getItemByName("duplicate objects").enabled = false;
                }
            }

            if (menuEdit.submenu.getItemByName("clear layer").enabled !== projectLoaded){
                menuEdit.submenu.getItemByName("clear layer").enabled = projectLoaded;
            }

            //VIEW
            if (projectLoaded) {
                if (menuView.submenu.getItemByName("zoom in").enabled !== (Ogmo.level.zoom < Level.ZOOMS.length - 1)){
                    menuView.submenu.getItemByName("zoom in").enabled = (Ogmo.level.zoom < Level.ZOOMS.length - 1);
                }
                if (menuView.submenu.getItemByName("zoom out").enabled !== (Ogmo.level.zoom > 0)){
                    menuView.submenu.getItemByName("zoom out").enabled = (Ogmo.level.zoom > 0);
                }
            }
            else {
                if (menuView.submenu.getItemByName("zoom in").enabled !== false) {
                    menuView.submenu.getItemByName("zoom in").enabled = false;
                }
                if (menuView.submenu.getItemByName("zoom out").enabled !== false){
                    menuView.submenu.getItemByName("zoom out").enabled = false;
                }
            }
            if (menuView.submenu.getItemByName("grid").checked !== Ogmo.gridOn){
                menuView.submenu.getItemByName("grid").checked = Ogmo.gridOn;
            }
            if (menuView.submenu.getItemByName("debug").checked !== (Ogmo.getDebugWindow() != null)){
                menuView.submenu.getItemByName("debug").checked = (Ogmo.getDebugWindow() != null);
            }
            if (menuView.submenu.getItemByName("grid").enabled !== projectLoaded){
                menuView.submenu.getItemByName("grid").enabled = projectLoaded;
            }
            if (menuView.submenu.getItemByName("center view").enabled !== projectLoaded){
                menuView.submenu.getItemByName("center view").enabled = projectLoaded;
            }

        }

        /* ========== FILE ========= */

        private function onOpenProject(e:Event):void {
            Ogmo.ogmo.lookForProject();
        }

        private function onCloseProject(e:Event):void {
            Ogmo.ogmo.closeProject();
        }

        private function onReloadProject(e:Event):void {
            Ogmo.ogmo.reloadProject();
        }

        private function onNewLevel(e:Event):void {
            Ogmo.ogmo.newLevel();
        }

        private function onOpenLevel(e:Event):void {
            Ogmo.ogmo.lookForLevel();
        }

        private function onSaveLevel(e:Event):void {
            Ogmo.ogmo.saveLevel();
        }

        private function onSaveLevelAs(e:Event):void {
            Ogmo.ogmo.saveLevelAs();
        }

        private function onSaveLevelAsPNG(e:Event):void {
            Ogmo.level.saveScreenshot();
        }

        private function onOpenDirectory(e:Event):void {
            Ogmo.openProjectDirectory();
        }

        private function onExit(e:Event):void {
            Ogmo.quit();
        }

        /* ========== EDIT ========= */

        private function onClearLayer(e:Event):void {
            Ogmo.showMessage("Layer Cleared");
            Ogmo.level.selectedLayer.clear();
        }

        private function onUndo(e:Event):void {
            (Ogmo.level.selectedLayer as Undoes).undo();
        }

        private function onRedo(e:Event):void {
            (Ogmo.level.selectedLayer as Undoes).redo();
        }

        private function onSelectAll(e:Event):void {
            (Ogmo.level.selectedLayer as ObjectLayer).selectAll();
        }

        private function onDuplicateObjects(e:Event):void {
            (Ogmo.level.selectedLayer as ObjectLayer).duplicateObjects();
        }

        /* ========== VIEW ========= */

        private function onZoomIn(e:Event):void {
            Ogmo.level.zoom++;
        }

        private function onZoomOut(e:Event):void {
            Ogmo.level.zoom--;
        }

        private function onCenterView(e:Event):void {
            Ogmo.level.centerView();
        }

        private function onGrid(e:Event):void {
            Ogmo.level.toggleGrid();
        }

        private function onDebugWindow(e:Event):void {
            Ogmo.toggleDebugWindow();
        }

        /* ========== ABOUT ========= */

        private function onWebsite(e:Event):void {
            Ogmo.openWebsite();
        }

    }

}