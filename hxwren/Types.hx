package hxwren;

#if (!cpp && macro)
#error 'Wren supports only C++ target.'
#end

class Types {} // blank

// A single virtual machine for executing Wren code.
//
// Wren has no global state, so all state stored by a running interpreter lives
// here.

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:native("WrenVM")
extern class WrenVM {}

// A handle to a Wren object.
//
// This lets code outside of the VM hold a persistent reference to an object.
// After a handle is acquired, and until it is released, this ensures the
// garbage collector will not reclaim the object it references.

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:native("WrenHandle")
extern class WrenHandle {}

// A generic allocation function that handles all explicit memory management
// used by Wren. It's used like so:
//
// - To allocate new memory, [memory] is NULL and [newSize] is the desired
//   size. It should return the allocated memory or NULL on failure.
//
// - To attempt to grow an existing allocation, [memory] is the memory, and
//   [newSize] is the desired size. It should return [memory] if it was able to
//   grow it in place, or a new pointer if it had to move it.
//
// - To shrink memory, [memory] and [newSize] are the same as above but it will
//   always return [memory].
//
// - To free memory, [memory] will be the memory to free and [newSize] will be
//   zero. It should return NULL.
typedef WrenReallocateFn = cpp.Callable<(memory:cpp.Pointer<cpp.Void>, newSize:cpp.SizeT, userData:cpp.Pointer<cpp.Void>) -> cpp.Pointer<cpp.Void>>;

// A function callable from Wren code, but implemented in C.
typedef WrenForeignMethodFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>) -> Void>;

// A finalizer function for freeing resources owned by an instance of a foreign
// class. Unlike most foreign methods, finalizers do not have access to the VM
// and should not interact with it since it's in the middle of a garbage
// collection.
typedef WrenFinalizerFn = cpp.Callable<(data:cpp.Pointer<cpp.Void>) -> Void>;

// Gives the host a chance to canonicalize the imported module name,
// potentially taking into account the (previously resolved) name of the module
// that contains the import. Typically, this is used to implement relative
// imports.
typedef WrenResolveModuleFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, importer:cpp.ConstCharStar, name:cpp.ConstCharStar) -> cpp.ConstCharStar>;

// Called after loadModuleFn is called for module [name]. The original returned result
// is handed back to you in this callback, so that you can free memory if appropriate.
typedef WrenLoadModuleCompleteFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, name:cpp.ConstCharStar, result:WrenLoadModuleResult) -> Void>;

// The result of a loadModuleFn call.
// [source] is the source code for the module, or NULL if the module is not found.
// [onComplete] an optional callback that will be called once Wren is done with the result.

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:structAccess
@:native("WrenLoadModuleResult")
extern class WrenLoadModuleResult
{
	@:native('WrenLoadModuleResult')
	static function create():WrenLoadModuleResult;

	var source:cpp.ConstCharStar;
	var onComplete:WrenLoadModuleCompleteFn;
	var userData:cpp.Pointer<cpp.Void>;
}

// Loads and returns the source code for the module [name].
typedef WrenLoadModuleFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, name:cpp.ConstCharStar) -> WrenLoadModuleResult>;

// Returns a pointer to a foreign method on [className] in [module] with
// [signature].
typedef WrenBindForeignMethodFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, className:cpp.ConstCharStar, isStatic:Bool,
		signature:cpp.ConstCharStar) -> WrenForeignMethodFn>;

// Displays a string of text to the user.
typedef WrenWriteFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, text:cpp.ConstCharStar) -> Void>;

enum abstract WrenErrorType(Int) from Int to Int
{
	// A syntax or resolution error detected at compile time.
	var WREN_ERROR_COMPILE = 0;
	// The error message for a runtime error.
	var WREN_ERROR_RUNTIME = 1;
	// One entry of a runtime error's stack trace.
	var WREN_ERROR_STACK_TRACE = 2;
}

// Reports an error to the user.
//
// An error detected during compile time is reported by calling this once with
// [type] `WREN_ERROR_COMPILE`, the resolved name of the [module] and [line]
// where the error occurs, and the compiler's error [message].
//
// A runtime error is reported by calling this once with [type]
// `WREN_ERROR_RUNTIME`, no [module] or [line], and the runtime error's
// [message]. After that, a series of [type] `WREN_ERROR_STACK_TRACE` calls are
// made for each line in the stack trace. Each of those has the resolved
// [module] and [line] where the method or function is defined and [message] is
// the name of the method or function.
typedef WrenErrorFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, type:WrenErrorType, module:cpp.ConstCharStar, line:Int, message:cpp.ConstCharStar) -> Void>;

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:structAccess
@:native("WrenForeignClassMethods")
extern class WrenForeignClassMethods
{
	@:native('WrenForeignClassMethods')
	static function create():WrenForeignClassMethods;

	// The callback invoked when the foreign object is created.
	//
	// This must be provided. Inside the body of this, it must call
	// [wrenSetSlotNewForeign()] exactly once.
	var allocate:WrenForeignMethodFn;

	// The callback invoked when the garbage collector is about to collect a
	// foreign object's memory.
	//
	// This may be `NULL` if the foreign class does not need to finalize.
	var finalize:WrenFinalizerFn;
}

// Returns a pair of pointers to the foreign methods used to allocate and
// finalize the data for instances of [className] in resolved [module].
typedef WrenBindForeignClassFn = cpp.Callable<(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, className:cpp.ConstCharStar) -> WrenForeignClassMethods>;

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:structAccess
@:native("WrenConfiguration")
extern class WrenConfiguration
{
	@:native('WrenConfiguration')
	static function create():WrenConfiguration;

	// The callback Wren will use to allocate, reallocate, and deallocate memory.
	//
	// If `NULL`, defaults to a built-in function that uses `realloc` and `free`.
	var reallocateFn:WrenReallocateFn;

	// The callback Wren uses to resolve a module name.
	//
	// Some host applications may wish to support "relative" imports, where the
	// meaning of an import string depends on the module that contains it. To
	// support that without baking any policy into Wren itself, the VM gives the
	// host a chance to resolve an import string.
	//
	// Before an import is loaded, it calls this, passing in the name of the
	// module that contains the import and the import string. The host app can
	// look at both of those and produce a new "canonical" string that uniquely
	// identifies the module. This string is then used as the name of the module
	// going forward. It is what is passed to [loadModuleFn], how duplicate
	// imports of the same module are detected, and how the module is reported in
	// stack traces.
	//
	// If you leave this function NULL, then the original import string is
	// treated as the resolved string.
	//
	// If an import cannot be resolved by the embedder, it should return NULL and
	// Wren will report that as a runtime error.
	//
	// Wren will take ownership of the string you return and free it for you, so
	// it should be allocated using the same allocation function you provide
	// above.
	var resolveModuleFn:WrenResolveModuleFn;

	// The callback Wren uses to load a module.
	//
	// Since Wren does not talk directly to the file system, it relies on the
	// embedder to physically locate and read the source code for a module. The
	// first time an import appears, Wren will call this and pass in the name of
	// the module being imported. The method will return a result, which contains
	// the source code for that module. Memory for the source is owned by the
	// host application, and can be freed using the onComplete callback.
	//
	// This will only be called once for any given module name. Wren caches the
	// result internally so subsequent imports of the same module will use the
	// previous source and not call this.
	//
	// If a module with the given name could not be found by the embedder, it
	// should return NULL and Wren will report that as a runtime error.
	var loadModuleFn:WrenLoadModuleFn;

	// The callback Wren uses to find a foreign method and bind it to a class.
	//
	// When a foreign method is declared in a class, this will be called with the
	// foreign method's module, class, and signature when the class body is
	// executed. It should return a pointer to the foreign function that will be
	// bound to that method.
	//
	// If the foreign function could not be found, this should return NULL and
	// Wren will report it as runtime error.
	var bindForeignMethodFn:WrenBindForeignMethodFn;

	// The callback Wren uses to find a foreign class and get its foreign methods.
	//
	// When a foreign class is declared, this will be called with the class's
	// module and name when the class body is executed. It should return the
	// foreign functions uses to allocate and (optionally) finalize the bytes
	// stored in the foreign object when an instance is created.
	var bindForeignClassFn:WrenBindForeignClassFn;

	// The callback Wren uses to display text when `System.print()` or the other
	// related functions are called.
	//
	// If this is `NULL`, Wren discards any printed text.
	var writeFn:WrenWriteFn;

	// The callback Wren uses to report errors.
	//
	// When an error occurs, this will be called with the module name, line
	// number, and an error message. If this is `NULL`, Wren doesn't report any
	// errors.
	var errorFn:WrenErrorFn;

	// The number of bytes Wren will allocate before triggering the first garbage
	// collection.
	//
	// If zero, defaults to 10MB.
	var initialHeapSize:cpp.SizeT;

	// After a collection occurs, the threshold for the next collection is
	// determined based on the number of bytes remaining in use. This allows Wren
	// to shrink its memory usage automatically after reclaiming a large amount
	// of memory.
	//
	// This can be used to ensure that the heap does not get too small, which can
	// in turn lead to a large number of collections afterwards as the heap grows
	// back to a usable size.
	//
	// If zero, defaults to 1MB.
	var minHeapSize:cpp.SizeT;

	// Wren will resize the heap automatically as the number of bytes
	// remaining in use after a collection changes. This number determines the
	// amount of additional memory Wren will use after a collection, as a
	// percentage of the current heap size.
	//
	// For example, say that this is 50. After a garbage collection, when there
	// are 400 bytes of memory still in use, the next collection will be triggered
	// after a total of 600 bytes are allocated (including the 400 already in
	// use.)
	//
	// Setting this to a smaller number wastes less memory, but triggers more
	// frequent garbage collections.
	//
	// If zero, defaults to 50.
	var heapGrowthPercent:Int;

	// User-defined data associated with the VM.
	var userData:cpp.Pointer<cpp.Void>;
}

enum abstract WrenInterpretResult(Int) from Int to Int
{
	var WREN_RESULT_SUCCESS = 0;
	var WREN_RESULT_COMPILE_ERROR = 1;
	var WREN_RESULT_RUNTIME_ERROR = 2;
}

// The type of an object stored in a slot.
//
// This is not necessarily the object's *class*, but instead its low level
// representation type.
enum abstract WrenType(Int) from Int to Int
{
	var WREN_TYPE_BOOL = 0;
	var WREN_TYPE_NUM = 1;
	var WREN_TYPE_FOREIGN = 2;
	var WREN_TYPE_LIST = 3;
	var WREN_TYPE_MAP = 4;
	var WREN_TYPE_NULL = 5;
	var WREN_TYPE_STRING = 6;
	// The object is of a type that isn't accessible by the C API.
	var WREN_TYPE_UNKNOWN = 7;
}
