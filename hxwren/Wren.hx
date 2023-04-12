package hxwren;

#if (!cpp && macro)
#error 'Wren supports only C++ target.'
#end

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
@:keep
@:unreflective
extern class Wren
{
	// The Wren semantic version number components.
	@:native('WREN_VERSION_MAJOR')
	static var VERSION_MAJOR:Int;

	@:native('WREN_VERSION_MINOR')
	static var VERSION_MINOR:Int;

	@:native('WREN_VERSION_PATCH')
	static var VERSION_PATCH:Int;

	// A human-friendly string representation of the version.
	@:native('::String(WREN_VERSION_STRING)')
	static var VERSION_STRING:String;

	// A monotonically increasing numeric representation of the version number. Use
	// this if you want to do range checks over versions.
	@:native('WREN_VERSION_NUMBER')
	static var VERSION_NUMBER:Int;
}
