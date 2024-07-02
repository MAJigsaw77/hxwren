package hxwren;

/**
 * Dummy class for importing Wren types.
 */
#if (!cpp && macro)
#error 'Wren supports only C++ target platforms.'
#end
class Types {}

/**
 * A single virtual machine for executing Wren code.
 *
 * Wren has no global state, so all state stored by a running interpreter lives
 * here.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:native('WrenVM')
extern class WrenVM {}

/**
 * A handle to a Wren object.
 *
 * This lets code outside of the VM hold a persistent reference to an object.
 * After a handle is acquired, and until it is released, this ensures the
 * garbage collector will not reclaim the object it references.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:native('WrenHandle')
extern class WrenHandle {}

/**
 * A generic allocation function that handles all explicit memory management used by Wren.
 */
typedef WrenReallocateFn = cpp.Callable<(memory:cpp.RawPointer<cpp.Void>, newSize:cpp.SizeT, userData:cpp.RawPointer<cpp.Void>) -> cpp.RawPointer<cpp.Void>>;

/**
 * A function callable from Wren code, but implemented in C.
 */
typedef WrenForeignMethodFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>) -> Void>;

/**
 * A finalizer function for freeing resources owned by an instance of a foreign class.
 */
typedef WrenFinalizerFn = cpp.Callable<(data:cpp.RawPointer<cpp.Void>) -> Void>;

/**
 * Gives the host a chance to canonicalize the imported module name,
 * potentially taking into account the (previously resolved) name of the module
 * that contains the import. Typically, this is used to implement relative
 * imports.
 */
typedef WrenResolveModuleFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, importer:cpp.ConstCharStar, name:cpp.ConstCharStar) -> cpp.ConstCharStar>;

/**
 * Called after loadModuleFn is called for module 'name'. The original returned result
 * is handed back to you in this callback, so that you can free memory if appropriate.
 */
typedef WrenLoadModuleCompleteFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, name:cpp.ConstCharStar, result:WrenLoadModuleResult) -> Void>;

/**
 * The result of a loadModuleFn call.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:unreflective
@:structAccess
@:native('WrenLoadModuleResult')
extern class WrenLoadModuleResult
{
	/**
	 * Allocates a new 'WrenLoadModuleResult' instance.
	 */
	@:native('WrenLoadModuleResult')
	static function alloc():WrenLoadModuleResult;

	/**
	 * The source code for the module, or NULL if not found.
	 */
	var source:cpp.ConstCharStar;

	/**
	 * Callback called when Wren is done with the result.
	 */
	var onComplete:WrenLoadModuleCompleteFn;

	/**
	 * User data associated with the result.
	 */
	var userData:cpp.RawPointer<cpp.Void>;
}

/**
 * Loads and returns the source code for the module 'name'.
 */
typedef WrenLoadModuleFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, name:cpp.ConstCharStar) -> WrenLoadModuleResult>;

/**
 * Returns a pointer to a foreign method on 'className' in 'module' with 'signature'.
 */
typedef WrenBindForeignMethodFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, className:cpp.ConstCharStar, isStatic:Bool,
		signature:cpp.ConstCharStar) -> WrenForeignMethodFn>;

/**
 * Displays a string of text to the user.
 */
typedef WrenWriteFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, text:cpp.ConstCharStar) -> Void>;

/**
 * Enumeration representing different types of errors in Wren.
 */
extern enum abstract WrenErrorType(WrenErrorTypeImpl)
{
	/**
	 * A syntax or resolution error detected at compile time.
	 */
	@:native('WREN_ERROR_COMPILE')
	var WREN_ERROR_COMPILE;

	/**
	 * The error message for a runtime error.
	 */
	@:native('WREN_ERROR_RUNTIME')
	var WREN_ERROR_RUNTIME;

	/**
	 * One entry of a runtime error's stack trace.
	 */
	@:native('WREN_ERROR_STACK_TRACE')
	var WREN_ERROR_STACK_TRACE;

	@:from
	static public inline function fromInt(i:Int):WrenErrorType
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:native('WrenErrorType')
private extern class WrenErrorTypeImpl {}

/**
 * Reports an error to the user.
 */
typedef WrenErrorFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, type:WrenErrorType, module:cpp.ConstCharStar, line:Int, message:cpp.ConstCharStar) -> Void>;

/**
 * Structure representing methods for managing foreign classes in Wren.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:unreflective
@:structAccess
@:native('WrenForeignClassMethods')
extern class WrenForeignClassMethods
{
	/**
	 * Allocates a new 'WrenForeignClassMethods' instance.
	 */
	@:native('WrenForeignClassMethods')
	static function alloc():WrenForeignClassMethods;

	/**
	 * The callback invoked when the foreign object is created.
	 *
	 * This must be provided. Inside the body of this, it must call
	 * 'wrenSetSlotNewForeign()' exactly once.
	 */
	var allocate:WrenForeignMethodFn;

	/**
	 * The callback invoked when the garbage collector is about to collect a
	 * foreign object's memory.
	 *
	 * This may be 'NULL' if the foreign class does not need to finalize.
	 */
	var finalize:WrenFinalizerFn;
}

/**
 * Returns a pair of pointers to the foreign methods used to allocate and
 * finalize the data for instances of 'className' in resolved 'module'.
 */
typedef WrenBindForeignClassFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, className:cpp.ConstCharStar) -> WrenForeignClassMethods>;

/**
 * Configuration options for initializing and customizing the behavior of the Wren VM.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:unreflective
@:structAccess
@:native('WrenConfiguration')
extern class WrenConfiguration
{
	/**
	 * Allocates a new 'WrenConfiguration' instance.
	 */
	@:native('WrenConfiguration')
	static function alloc():WrenConfiguration;

	/**
	 * The callback Wren will use to allocate, reallocate, and deallocate memory.
	 *
	 * If 'NULL', defaults to a built-in function that uses 'realloc' and 'free'.
	 */
	var reallocateFn:WrenReallocateFn;

	/**
	 * The callback Wren uses to resolve a module name.
	 *
	 * Some host applications may wish to support "relative" imports, where the
	 * meaning of an import string depends on the module that contains it. To
	 * support that without baking any policy into Wren itself, the VM gives the
	 * host a chance to resolve an import string.
	 *
	 * If you leave this function NULL, then the original import string is
	 * treated as the resolved string.
	 *
	 * If an import cannot be resolved by the embedder, it should return NULL and
	 * Wren will report that as a runtime error.
	 *
	 * Wren will take ownership of the string you return and free it for you, so
	 * it should be allocated using the same allocation function you provide
	 * above.
	 */
	var resolveModuleFn:WrenResolveModuleFn;

	/**
	 * The callback Wren uses to load a module.
	 *
	 * Since Wren does not talk directly to the file system, it relies on the
	 * embedder to physically locate and read the source code for a module. The
	 * first time an import appears, Wren will call this and pass in the name of
	 * the module being imported. The method will return a result, which contains
	 * the source code for that module. Memory for the source is owned by the
	 * host application, and can be freed using the onComplete callback.
	 *
	 * This will only be called once for any given module name. Wren caches the
	 * result internally so subsequent imports of the same module will use the
	 * previous source and not call this.
	 *
	 * If a module with the given name could not be found by the embedder, it
	 * should return NULL and Wren will report that as a runtime error.
	 */
	var loadModuleFn:WrenLoadModuleFn;

	/**
	 * Returns a pointer to a foreign method on 'className' in 'module' with
	 * 'signature'.
	 */
	var bindForeignMethodFn:WrenBindForeignMethodFn;

	/**
	 * Returns a pair of pointers to the foreign methods used to allocate and
	 * finalize the data for instances of 'className' in resolved 'module'.
	 */
	var bindForeignClassFn:WrenBindForeignClassFn;

	/**
	 * The callback Wren uses to display text when 'System.print()' or the other
	 * related functions are called.
	 *
	 * If this is 'NULL', Wren discards any printed text.
	 */
	var writeFn:WrenWriteFn;

	/**
	 * The callback Wren uses to report errors.
	 *
	 * When an error occurs, this will be called with the module name, line
	 * number, and an error message. If this is 'NULL', Wren doesn't report any
	 * errors.
	 */
	var errorFn:WrenErrorFn;

	/**
	 * The number of bytes Wren will allocate before triggering the first garbage collection.
	 *
	 * If zero, defaults to 10MB.
	 */
	var initialHeapSize:cpp.SizeT;

	/**
	 * After a collection occurs, the threshold for the next collection is
	 * determined based on the number of bytes remaining in use. This allows Wren
	 * to shrink its memory usage automatically after reclaiming a large amount
	 * of memory.
	 *
	 * This can be used to ensure that the heap does not get too small, which can
	 * in turn lead to a large number of collections afterwards as the heap grows
	 * back to a usable size.
	 *
	 * If zero, defaults to 1MB.
	 */
	var minHeapSize:cpp.SizeT;

	/**
	 * Wren will resize the heap automatically as the number of bytes
	 * remaining in use after a collection changes. This number determines the
	 * amount of additional memory Wren will use after a collection, as a
	 * percentage of the current heap size.
	 *
	 * For example, say that this is 50. After a garbage collection, when there
	 * are 400 bytes of memory still in use, the next collection will be triggered
	 * after a total of 600 bytes are allocated (including the 400 already in
	 * use.)
	 *
	 * Setting this to a smaller number wastes less memory, but triggers more frequent garbage collections.
	 *
	 * If zero, defaults to 50.
	 */
	var heapGrowthPercent:Int;

	/**
	 * User-defined data associated with the VM.
	 */
	var userData:cpp.RawPointer<cpp.Void>;
}

/**
 * Represents the result of interpreting Wren code.
 */
extern enum abstract WrenInterpretResult(WrenInterpretResultImpl)
{
	/**
	 * Interpretation was successful.
	*/
	@:native('WREN_RESULT_SUCCESS')
	var WREN_RESULT_SUCCESS;

	/**
	 * Compilation error occurred during interpretation.
	 */
	@:native('WREN_RESULT_COMPILE_ERROR')
	var WREN_RESULT_COMPILE_ERROR;

	/**
	 * Runtime error occurred during interpretation.
	 */
	@:native('WREN_RESULT_RUNTIME_ERROR')
	var WREN_RESULT_RUNTIME_ERROR;

	@:from
	static public inline function fromInt(i:Int):WrenInterpretResult
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:native('WrenInterpretResult')
private extern class WrenInterpretResultImpl {}

/**
 * The type of an object stored in a Wren slot.
 *
 * This represents the low-level representation type of the object, not necessarily its class.
 */
extern enum abstract WrenType(WrenTypeImpl)
{
	/**
	 * Boolean type.
	 */
	@:native('WREN_TYPE_BOOL')
	var WREN_TYPE_BOOL;

	/**
	 * Numeric type.
	 */
	@:native('WREN_TYPE_NUM')
	var WREN_TYPE_NUM;

	/**
	 * Foreign object type.
	 */
	@:native('WREN_TYPE_FOREIGN')
	var WREN_TYPE_FOREIGN;

	/**
	 * List type.
	 */
	@:native('WREN_TYPE_LIST')
	var WREN_TYPE_LIST;

	/**
	 * Map type.
	 */
	@:native('WREN_TYPE_MAP')
	var WREN_TYPE_MAP;

	/**
	 * Null type.
	 */
	@:native('WREN_TYPE_NULL')
	var WREN_TYPE_NULL;

	/**
	 * String type.
	 */
	@:native('WREN_TYPE_STRING')
	var WREN_TYPE_STRING;

	/**
	 * Unknown type that isn't accessible via the C API.
	 */
	@:native('WREN_TYPE_UNKNOWN')
	var WREN_TYPE_UNKNOWN;

	@:from
	static public inline function fromInt(i:Int):WrenType
		return cast i;

	@:to extern public inline function toInt():Int
		return untyped this;
}

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:native('WrenType')
private extern class WrenTypeImpl {}
