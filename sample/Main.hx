// For more details, visit https://wren.io/embedding

package;

import hxwren.Wren;
import hxwren.Types;
import sys.io.File;

class Main
{
	private static function writeFn(vm:cpp.RawPointer<WrenVM>, text:cpp.ConstCharStar):Void
	{
		if (cast(text, String) != "\n") // Wtf Wren?
			Sys.println(cast(text, String));
	}

	private static function errorFn(vm:cpp.RawPointer<WrenVM>, errorType:WrenErrorType, module:cpp.ConstCharStar, line:Int, msg:cpp.ConstCharStar):Void
	{
		switch (errorType)
		{
			case WREN_ERROR_COMPILE:
				Sys.println('[' + cast(module, String) + ' line ' + line + '] [Error] ' + cast(msg, String));
			case WREN_ERROR_STACK_TRACE:
				Sys.println('[' + cast(module, String) + ' line ' + line + '] in ' + cast(msg, String));
			case WREN_ERROR_RUNTIME:
				Sys.println('[Runtime Error] ' + cast(msg, String));
		}
	}

	public static function main():Void
	{
		Sys.println('Wren ${Wren.GetVersionNumber()}');

		var config:WrenConfiguration = WrenConfiguration.create();

		Wren.InitConfiguration(cpp.RawPointer.addressOf(config));

		config.writeFn = cpp.Function.fromStaticFunction(writeFn);
		config.errorFn = cpp.Function.fromStaticFunction(errorFn);

		var vm:cpp.RawPointer<WrenVM> = Wren.NewVM(cpp.RawPointer.addressOf(config));

		trace(cast(Wren.Interpret(vm, "main", File.getContent('script.wren')), Int));

		/*switch (Wren.Interpret(vm, "main", File.getContent('script.wren')))
		{
			case WREN_RESULT_COMPILE_ERROR:
				Sys.println('Compile Error!');
			case WREN_RESULT_RUNTIME_ERROR:
				Sys.println('Runtime Error!');
			case WREN_RESULT_SUCCESS:
				Sys.println('Success!');
		}*/

		Wren.FreeVM(vm);
		vm = null;
	}
}
