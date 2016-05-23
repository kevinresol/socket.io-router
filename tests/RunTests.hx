package;

import socketio.Router;
import js.npm.socketio.Server;

class RunTests {
	static function main() {
		Router.route(new Server(), new Routes());
	}
}