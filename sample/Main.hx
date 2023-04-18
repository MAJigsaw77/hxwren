// For more details, visit https://wren.io/embedding

package;

import hxwren.Wren;
import hxwren.Types;
import sys.io.File;

class Main
{
	private static function writeFn(vm:cpp.RawPointer<WrenVM>, text:cpp.ConstCharStar):Void
	{
		Sys.println('${cast(text, String)}');
	}

	public static function main():Void
	{
		Sys.println('Wren ${Wren.GetVersionNumber()}');

		var config:WrenConfiguration = WrenConfiguration.create();
		Wren.InitConfiguration(cpp.RawPointer.addressOf(config));
		config.writeFn = cpp.Function.fromStaticFunction(writeFn);

		var vm:cpp.RawPointer<WrenVM> = Wren.NewVM(cpp.RawPointer.addressOf(config));

		switch (Wren.Interpret(vm, "main", File.getContent('script.wren')))
		{
			case WREN_RESULT_COMPILE_ERROR:
				Sys.println('Compile Error!');
			case WREN_RESULT_RUNTIME_ERROR:
				Sys.println('Runtime Error!');
			case WREN_RESULT_SUCCESS:
				Sys.println('Success!');
		}

		Wren.FreeVM(vm);
		vm = null;
	}
}
