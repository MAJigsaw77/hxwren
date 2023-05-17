package hxwren;

#if (!cpp && macro)
#error 'Wren supports only C++ target platforms.'
#end
import hxwren.Types;

@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include("wren.hpp")
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

	// Get the current wren version number.
	//
	// Can be used to range checks over versions.
	@:native("wrenGetVersionNumber")
	static function GetVersionNumber():Int;

	// Initializes [configuration] with all of its default values.
	//
	// Call this before setting the particular fields you care about.
	@:native("wrenInitConfiguration")
	static function InitConfiguration(configuration:cpp.RawPointer<WrenConfiguration>):Void;

	// Creates a new Wren virtual machine using the given [configuration]. Wren
	// will copy the configuration data, so the argument passed to this can be
	// freed after calling this. If [configuration] is `NULL`, uses a default
	// configuration.
	@:native("wrenNewVM")
	static function NewVM(configuration:cpp.RawPointer<WrenConfiguration>):cpp.RawPointer<WrenVM>;

	// Disposes of all resources is use by [vm], which was previously created by a
	// call to [wrenNewVM].
	@:native("wrenFreeVM")
	static function FreeVM(vm:cpp.RawPointer<WrenVM>):Void;

	// Immediately run the garbage collector to free unused memory.
	@:native("wrenCollectGarbage")
	static function CollectGarbage(vm:cpp.RawPointer<WrenVM>):Void;

	// Runs [source], a string of Wren source code in a new fiber in [vm] in the
	// context of resolved [module].
	@:native("wrenInterpret")
	static function Interpret(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, source:cpp.ConstCharStar):WrenInterpretResult;

	// Creates a handle that can be used to invoke a method with [signature] on
	// using a receiver and arguments that are set up on the stack.
	//
	// This handle can be used repeatedly to directly invoke that method from C
	// code using [wrenCall].
	//
	// When you are done with this handle, it must be released using
	// [wrenReleaseHandle].
	@:native("wrenMakeCallHandle")
	static function MakeCallHandle(vm:cpp.RawPointer<WrenVM>, signature:cpp.ConstCharStar):cpp.RawPointer<WrenHandle>;

	// Calls [method], using the receiver and arguments previously set up on the
	// stack.
	//
	// [method] must have been created by a call to [wrenMakeCallHandle]. The
	// arguments to the method must be already on the stack. The receiver should be
	// in slot 0 with the remaining arguments following it, in order. It is an
	// error if the number of arguments provided does not match the method's
	// signature.
	//
	// After this returns, you can access the return value from slot 0 on the stack.
	@:native("wrenCall")
	static function Call(vm:cpp.RawPointer<WrenVM>, method:cpp.RawPointer<WrenHandle>):WrenInterpretResult;

	// Releases the reference stored in [handle]. After calling this, [handle] can
	// no longer be used.
	@:native("wrenReleaseHandle")
	static function ReleaseHandle(vm:cpp.RawPointer<WrenVM>, handle:cpp.RawPointer<WrenHandle>):Void;

	// The following functions are intended to be called from foreign methods or
	// finalizers. The interface Wren provides to a foreign method is like a
	// register machine: you are given a numbered array of slots that values can be
	// read from and written to. Values always live in a slot (unless explicitly
	// captured using wrenGetSlotHandle(), which ensures the garbage collector can
	// find them.
	//
	// When your foreign function is called, you are given one slot for the receiver
	// and each argument to the method. The receiver is in slot 0 and the arguments
	// are in increasingly numbered slots after that. You are free to read and
	// write to those slots as you want. If you want more slots to use as scratch
	// space, you can call wrenEnsureSlots() to add more.
	//
	// When your function returns, every slot except slot zero is discarded and the
	// value in slot zero is used as the return value of the method. If you don't
	// store a return value in that slot yourself, it will retain its previous
	// value, the receiver.
	//
	// While Wren is dynamically typed, C is not. This means the C interface has to
	// support the various types of primitive values a Wren variable can hold: bool,
	// double, string, etc. If we supported this for every operation in the C API,
	// there would be a combinatorial explosion of functions, like "get a
	// double-valued element from a list", "insert a string key and double value
	// into a map", etc.
	//
	// To avoid that, the only way to convert to and from a raw C value is by going
	// into and out of a slot. All other functions work with values already in a
	// slot. So, to add an element to a list, you put the list in one slot, and the
	// element in another. Then there is a single API function wrenInsertInList()
	// that takes the element out of that slot and puts it into the list.
	//
	// The goal of this API is to be easy to use while not compromising performance.
	// The latter means it does not do type or bounds checking at runtime except
	// using assertions which are generally removed from release builds. C is an
	// unsafe language, so it's up to you to be careful to use it correctly. In
	// return, you get a very fast FFI.

	// Returns the number of slots available to the current foreign method.
	@:native("wrenGetSlotCount")
	static function GetSlotCount(vm:cpp.RawPointer<WrenVM>):Int;

	// Ensures that the foreign method stack has at least [numSlots] available for
	// use, growing the stack if needed.
	//
	// Does not shrink the stack if it has more than enough slots.
	//
	// It is an error to call this from a finalizer.
	@:native("wrenEnsureSlots")
	static function EnsureSlots(vm:cpp.RawPointer<WrenVM>, numSlots:Int):Void;

	// Gets the type of the object in [slot].
	@:native("wrenGetSlotType")
	static function GetSlotType(vm:cpp.RawPointer<WrenVM>, slot:Int):WrenType;

	// Reads a boolean value from [slot].
	//
	// It is an error to call this if the slot does not contain a boolean value.
	@:native("wrenGetSlotBool")
	static function GetSlotBool(vm:cpp.RawPointer<WrenVM>, slot:Int):Bool;

	// Reads a byte array from [slot].
	//
	// The memory for the returned string is owned by Wren. You can inspect it
	// while in your foreign method, but cannot keep a pointer to it after the
	// function returns, since the garbage collector may reclaim it.
	//
	// Returns a pointer to the first byte of the array and fill [length] with the
	// number of bytes in the array.
	//
	// It is an error to call this if the slot does not contain a string.
	@:native("wrenGetSlotBytes")
	static function GetSlotBytes(vm:cpp.RawPointer<WrenVM>, slot:Int, length:cpp.Star<Int>):cpp.ConstCharStar;

	// Reads a number from [slot].
	//
	// It is an error to call this if the slot does not contain a number.
	@:native("wrenGetSlotDouble")
	static function GetSlotDouble(vm:cpp.RawPointer<WrenVM>, slot:Int):Float;

	// Reads a foreign object from [slot] and returns a pointer to the foreign data
	// stored with it.
	//
	// It is an error to call this if the slot does not contain an instance of a
	// foreign class.
	@:native("wrenGetSlotForeign")
	static function GetSlotForeign(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.RawPointer<cpp.Void>;

	// Reads a string from [slot].
	//
	// The memory for the returned string is owned by Wren. You can inspect it
	// while in your foreign method, but cannot keep a pointer to it after the
	// function returns, since the garbage collector may reclaim it.
	//
	// It is an error to call this if the slot does not contain a string.
	@:native("wrenGetSlotString")
	static function GetSlotString(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.ConstCharStar;

	// Creates a handle for the value stored in [slot].
	//
	// This will prevent the object that is referred to from being garbage collected
	// until the handle is released by calling [wrenReleaseHandle()].
	@:native("wrenGetSlotHandle")
	static function GetSlotHandle(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.RawPointer<WrenHandle>;

	// Stores the boolean [value] in [slot].
	@:native("wrenSetSlotBool")
	static function SetSlotBool(vm:cpp.RawPointer<WrenVM>, slot:Int, value:Bool):Void;

	// Stores the array [length] of [bytes] in [slot].
	//
	// The bytes are copied to a new string within Wren's heap, so you can free
	// memory used by them after this is called.
	@:native("wrenSetSlotBytes")
	static function SetSlotBytes(vm:cpp.RawPointer<WrenVM>, slot:Int, bytes:cpp.ConstCharStar, length:cpp.SizeT):Void;

	// Stores the numeric [value] in [slot].
	@:native("wrenSetSlotDouble")
	static function SetSlotDouble(vm:cpp.RawPointer<WrenVM>, slot:Int, value:Float):Void;

	// Creates a new instance of the foreign class stored in [classSlot] with [size]
	// bytes of raw storage and places the resulting object in [slot].
	//
	// This does not invoke the foreign class's constructor on the new instance. If
	// you need that to happen, call the constructor from Wren, which will then
	// call the allocator foreign method. In there, call this to create the object
	// and then the constructor will be invoked when the allocator returns.
	//
	// Returns a pointer to the foreign object's data.
	@:native("wrenSetSlotNewForeign")
	static function SetSlotNewForeign(vm:cpp.RawPointer<WrenVM>, slot:Int, classSlot:Int, size:cpp.SizeT):cpp.RawPointer<cpp.Void>;

	// Stores a new empty list in [slot].
	@:native("wrenSetSlotNewList")
	static function SetSlotNewList(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	// Stores a new empty map in [slot].
	@:native("wrenSetSlotNewMap")
	static function SetSlotNewMap(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	// Stores null in [slot].
	@:native("wrenSetSlotNull")
	static function SetSlotNull(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	// Stores the string [text] in [slot].
	//
	// The [text] is copied to a new string within Wren's heap, so you can free
	// memory used by it after this is called. The length is calculated using
	// [strlen()]. If the string may contain any null bytes in the middle, then you
	// should use [wrenSetSlotBytes()] instead.
	@:native("wrenSetSlotString")
	static function SetSlotString(vm:cpp.RawPointer<WrenVM>, slot:Int, text:cpp.ConstCharStar):Void;

	// Stores the value captured in [handle] in [slot].
	//
	// This does not release the handle for the value.
	@:native("wrenSetSlotHandle")
	static function SetSlotHandle(vm:cpp.RawPointer<WrenVM>, slot:Int, handle:cpp.RawPointer<WrenHandle>):Void;

	// Returns the number of elements in the list stored in [slot].
	@:native("wrenGetListCount")
	static function GetListCount(vm:cpp.RawPointer<WrenVM>, slot:Int):Int;

	// Reads element [index] from the list in [listSlot] and stores it in
	// [elementSlot].
	@:native("wrenGetListElement")
	static function GetListElement(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	// Sets the value stored at [index] in the list at [listSlot], 
	// to the value from [elementSlot]. 
	@:native("wrenSetListElement")
	static function SetListElement(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	// Takes the value stored at [elementSlot] and inserts it into the list stored
	// at [listSlot] at [index].
	//
	// As in Wren, negative indexes can be used to insert from the end. To append
	// an element, use `-1` for the index.
	@:native("wrenInsertInList")
	static function InsertInList(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	// Returns the number of entries in the map stored in [slot].
	@:native("wrenGetMapCount")
	static function GetMapCount(vm:cpp.RawPointer<WrenVM>, slot:Int):Int;

	// Returns true if the key in [keySlot] is found in the map placed in [mapSlot].
	@:native("wrenGetMapContainsKey")
	static function GetMapContainsKey(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int):Bool;

	// Retrieves a value with the key in [keySlot] from the map in [mapSlot] and
	// stores it in [valueSlot].
	@:native("wrenGetMapValue")
	static function GetMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, valueSlot:Int):Void;

	// Takes the value stored at [valueSlot] and inserts it into the map stored
	// at [mapSlot] with key [keySlot].
	@:native("wrenSetMapValue")
	static function SetMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, valueSlot:Int):Void;

	// Removes a value from the map in [mapSlot], with the key from [keySlot],
	// and place it in [removedValueSlot]. If not found, [removedValueSlot] is
	// set to null, the same behaviour as the Wren Map API.
	@:native("wrenRemoveMapValue")
	static function RemoveMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, removedValueSlot:Int):Void;

	// Looks up the top level variable with [name] in resolved [module] and stores
	// it in [slot].
	@:native("wrenGetVariable")
	static function GetVariable(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, name:cpp.ConstCharStar, slot:Int):Void;

	// Looks up the top level variable with [name] in resolved [module], 
	// returns false if not found. The module must be imported at the time, 
	// use wrenHasModule to ensure that before calling.
	@:native("wrenHasVariable")
	static function HasVariable(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, name:cpp.ConstCharStar):Bool;

	// Returns true if [module] has been imported/resolved before, false if not.
	@:native("wrenHasModule")
	static function HasModule(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar):Bool;

	// Sets the current fiber to be aborted, and uses the value in [slot] as the
	// runtime error object.
	@:native("wrenAbortFiber")
	static function AbortFiber(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	// Returns the user data associated with the WrenVM.
	@:native("wrenGetUserData")
	static function GetUserData(vm:cpp.RawPointer<WrenVM>):cpp.RawPointer<cpp.Void>;

	// Sets user data associated with the WrenVM.
	@:native("wrenSetUserData")
	static function SetUserData(vm:cpp.RawPointer<WrenVM>, userData:cpp.RawPointer<cpp.Void>):Void;
}
