package;

import js.npm.socketio.Server;
import js.npm.socketio.Socket;

class Routes {
	
	var io:Server;
	
	public function new() {}
	
	@:event('message')
	public function message(msg:String) {
		trace(msg);
	}
	
	@:event('message2')
	@:event('message3')
	public function message2(msg:String) {
		trace(msg);
	}
	
	@:event('message4')
	public function message4(msg1:String, msg2:{a:Int, b:String}, socket:Socket) {
		socket.emit('hello world');
	}
}