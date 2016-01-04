/**
 * Created with IntelliJ IDEA.
 * User: Ryc
 * Date: 15.05.13
 * Time: 19:25
 * To change this template use File | Settings | File Templates.
 */
package editor.commons {
    public class SelectOption {
        public var value:*;
        public var display:String;

        public function SelectOption(value:*, display:String) {
            this.value = value;
            this.display = display;
        }
    }
}
