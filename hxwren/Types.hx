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
