package editor.undo
{

    public interface Undoes
    {
        function canUndo():Boolean;
        function canRedo():Boolean;
        function undo():void;
        function redo():void;
    }

}