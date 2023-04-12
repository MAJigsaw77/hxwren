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
