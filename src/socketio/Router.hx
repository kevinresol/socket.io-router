package socketio;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
using tink.MacroApi;
#end

using Lambda;

class Router {
	
	public static macro function route<T:{}>(server:ExprOf<js.npm.socketio.Server>, routes:ExprOf<T>) {
		
		var exprs = [];
		var events = [];
		
		switch Context.typeof(routes) {
			case TInst(_.get() => cl, _):
				for(field in cl.fields.get()) switch [field.type.reduce(), field.meta.extract(':event')] {
					case [_, []]: // no @:event meta, skip
					case [TFun(args, ret), metas]:
						for(meta in metas) switch meta.params {
							case [v]:
								var name = field.name;
								var eventName = v.getString().sure();
								switch events.indexOf(eventName) {
									case -1:
										events.push(meta.name);
										var argsWithoutSocket = args.filter(function(arg) return arg.name != 'socket');
										var handler = EFunction(null, {
											args: [for(arg in argsWithoutSocket) {name: arg.name, type: null}],
											ret: macro:Void,
											expr: macro {
												try
													$b{argsWithoutSocket.map(function(arg) {
														var ct = arg.t.toComplex();
														return macro tink.Validation.validate(($i{arg.name}:$ct));
													})}
												catch(e:Dynamic) {
													socket.emit('error', e);
													return;
												}
												routes.$name($a{args.map(function(arg) return macro $i{arg.name})});
											}
										}).at();
										exprs.push((macro socket.on($v{eventName}, $handler)));
									default:
										Context.error('Duplicated event "$eventName"', meta.pos);
								}
								
							default: Context.error('@:event must have exactly one parameter', meta.pos);
						}
					default: // field is not a function
				}
			default: Context.error('Only support class instances', routes.pos);
		}
		
		return macro {
			var server = $server;
			var routes = $routes;
			server.on('connection', function(socket:js.npm.socketio.Socket) $b{exprs});
		}
	}
}