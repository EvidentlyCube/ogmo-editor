package editor.ui.windows
{
    import editor.ui.*;
    import editor.ui.elements.Label;
    import editor.ui.elements.TextButton;

    import flash.events.Event;
    import flash.filesystem.File;

    public class MainMenuWindow extends Window
    {

        public function MainMenuWindow()
        {
            super( 200, 46, "Main Menu" );

            addEventListener( Event.ADDED_TO_STAGE, addedToStage );
        }

        private function addedToStage( e:Event ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, addedToStage );
            addEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.addEventListener( Event.RESIZE, onResize );

            x = 20;
            y = 20;

            var t:TextButton;

            //Open a project
            t = new TextButton( 194, "Open a Project", onOpenProject );
            t.x = 3;
            t.y = 3;
            ui.addChild( t );

            //Exit
            t = new TextButton( 194, "Exit", onExit );
            t.x = 3;
            t.y = 3 + (TextButton.HEIGHT + 2);
            ui.addChild( t );

            //Project history
            if (Ogmo.projectHistory.length > 0)
            {
                bodyHeight = 46 + (Ogmo.projectHistory.length + 1) * (TextButton.HEIGHT + 2);

                ui.addChild( new Label( "Project History:", 100, 1 + (TextButton.HEIGHT + 2) * 2, "Center", "Top" ) );

                var c:uint = 3;
                for each ( var ob:Object in Ogmo.projectHistory )
                {
                    t = new TextButton( 194, ob.name, onHistory );
                    t.file = ob.file;
                    t.x = 3;
                    t.y = 3 + (TextButton.HEIGHT + 2) * c;
                    ui.addChild( t );
                    c++;
                }
            }
        }

        private function destroy( e:Event ):void
        {
            removeEventListener( Event.REMOVED_FROM_STAGE, destroy );
            stage.removeEventListener( Event.RESIZE, onResize );
        }

        private function onOpenProject( t:TextButton ):void
        {
            Ogmo.ogmo.lookForProject();
        }

        private function onExit( t:TextButton ):void
        {
            Ogmo.quit();
        }

        private function onHistory( t:TextButton ):void
        {
            Ogmo.ogmo.loadProject( new File( t.file ) );
        }

        private function onResize( e:Event ):void
        {
            enforceBounds();
        }

    }

}