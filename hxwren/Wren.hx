package hxwren;

#if (!cpp && macro)
#error 'Wren supports only C++ target platforms.'
#end
import hxwren.Types;

/**
 * This class provides static methods to interact with the Wren scripting language VM (Virtual Machine).
 * It facilitates integration with Wren's VM functionality,
 * enabling applications to execute Wren scripts, manage memory, and interact with foreign methods.
 * Methods are available for initializing the VM, creating and disposing of VM instances,
 * running scripts, managing handles, manipulating slots, handling maps and lists,
 * and setting user data associated with the VM.
 */
@:buildXml('<include name="${haxelib:hxwren}/project/Build.xml" />')
@:include('wren.hpp')
@:unreflective
extern class Wren
{
	/**
	 * The major version number of the Wren VM.
	 */
	@:native('WREN_VERSION_MAJOR')
	static var VERSION_MAJOR:Int;

	/**
	 * The minor version number of the Wren VM.
	 */
	@:native('WREN_VERSION_MINOR')
	static var VERSION_MINOR:Int;

	/**
	 * The patch version number of the Wren VM.
	 */
	@:native('WREN_VERSION_PATCH')
	static var VERSION_PATCH:Int;

	/**
	 * The human-readable string representation of the Wren VM version.
	 */
	@:native('::String(WREN_VERSION_STRING)')
	static var VERSION_STRING:String;

	/**
	 * A monotonically increasing numeric representation of the version number.
	 * Use this for range checks over versions.
	 */
	@:native('WREN_VERSION_NUMBER')
	static var VERSION_NUMBER:Int;

	/**
	 * Retrieves the current Wren version number.
	 *
	 * @return The version number.
	 */
	@:native('wrenGetVersionNumber')
	static function GetVersionNumber():Int;

	/**
	 * Initializes [configuration] with all of its default values.
	 *
	 * Call this before setting the particular fields you care about.
	 *
	 * @param configuration A pointer to the configuration object to initialize.
	 */
	@:native('wrenInitConfiguration')
	static function InitConfiguration(configuration:cpp.RawPointer<WrenConfiguration>):Void;

	/**
	 * Creates a new Wren virtual machine using the given [configuration]. Wren
	 * will copy the configuration data, so the argument passed to this can be
	 * freed after calling this. If [configuration] is `NULL`, uses a default
	 * configuration.
	 *
	 * @param configuration Optional configuration object for the VM. Pass `null` for default configuration.
	 * @return A pointer to the newly created WrenVM instance.
	 */
	@:native('wrenNewVM')
	static function NewVM(configuration:cpp.RawPointer<WrenConfiguration>):cpp.RawPointer<WrenVM>;

	/**
	 * Disposes of all resources in use by [vm], which was previously created by a
	 * call to [wrenNewVM].
	 *
	 * @param vm A pointer to the WrenVM instance to free.
	 */
	@:native('wrenFreeVM')
	static function FreeVM(vm:cpp.RawPointer<WrenVM>):Void;

	/**
	 * Immediately runs the garbage collector to free unused memory.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 */
	@:native('wrenCollectGarbage')
	static function CollectGarbage(vm:cpp.RawPointer<WrenVM>):Void;

	/**
	 * Runs [source], a string of Wren source code in a new fiber in [vm] in the
	 * context of resolved [module].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param module The name of the module containing the source code.
	 * @param source The Wren source code to execute.
	 * @return The result of interpreting the source code.
	 */
	@:native('wrenInterpret')
	static function Interpret(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, source:cpp.ConstCharStar):WrenInterpretResult;

	/**
	 * Creates a handle that can be used to invoke a method with [signature] on
	 * using a receiver and arguments that are set up on the stack.
	 *
	 * This handle can be used repeatedly to directly invoke that method from C
	 * code using [wrenCall].
	 *
	 * When you are done with this handle, it must be released using
	 * [wrenReleaseHandle].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param signature The method signature in Wren.
	 * @return A handle to the method.
	 */
	@:native('wrenMakeCallHandle')
	static function MakeCallHandle(vm:cpp.RawPointer<WrenVM>, signature:cpp.ConstCharStar):cpp.RawPointer<WrenHandle>;

	/**
	 * Calls [method], using the receiver and arguments previously set up on the
	 * stack.
	 *
	 * [method] must have been created by a call to [wrenMakeCallHandle]. The
	 * arguments to the method must be already on the stack. The receiver should be
	 * in slot 0 with the remaining arguments following it, in order. It is an
	 * error if the number of arguments provided does not match the method's
	 * signature.
	 *
	 * After this returns, you can access the return value from slot 0 on the stack.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param method A handle to the method to call.
	 * @return The result of the method call.
	 */
	@:native('wrenCall')
	static function Call(vm:cpp.RawPointer<WrenVM>, method:cpp.RawPointer<WrenHandle>):WrenInterpretResult;

	/**
	 * Releases the reference stored in [handle]. After calling this, [handle] can
	 * no longer be used.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param handle The handle to release.
	 */
	@:native('wrenReleaseHandle')
	static function ReleaseHandle(vm:cpp.RawPointer<WrenVM>, handle:cpp.RawPointer<WrenHandle>):Void;

	/**
	 * Returns the number of slots available to the current foreign method.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @return The number of slots available.
	 */
	@:native('wrenGetSlotCount')
	static function GetSlotCount(vm:cpp.RawPointer<WrenVM>):Int;

	/**
	 * Ensures that the foreign method stack has at least [numSlots] available for
	 * use, growing the stack if needed.
	 *
	 * Does not shrink the stack if it has more than enough slots.
	 *
	 * It is an error to call this from a finalizer.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param numSlots The minimum number of slots to ensure.
	 */
	@:native('wrenEnsureSlots')
	static function EnsureSlots(vm:cpp.RawPointer<WrenVM>, numSlots:Int):Void;

	/**
	 * Gets the type of the object in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return The type of the object in the slot.
	 */
	@:native('wrenGetSlotType')
	static function GetSlotType(vm:cpp.RawPointer<WrenVM>, slot:Int):WrenType;

	/**
	 * Reads a boolean value from [slot].
	 *
	 * It is an error to call this if the slot does not contain a boolean value.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return The boolean value stored in the slot.
	 */
	@:native('wrenGetSlotBool')
	static function GetSlotBool(vm:cpp.RawPointer<WrenVM>, slot:Int):Bool;

	/**
	 * Reads a byte array from [slot].
	 *
	 * The memory for the returned string is owned by Wren. You can inspect it
	 * while in your foreign method, but cannot keep a pointer to it after the
	 * function returns, since the garbage collector may reclaim it.
	 *
	 * Returns a pointer to the first byte of the array and fill [length] with the
	 * number of bytes in the array.
	 *
	 * It is an error to call this if the slot does not contain a string.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param length A pointer to store the length of the byte array.
	 * @return A pointer to the byte array.
	 */
	@:native('wrenGetSlotBytes')
	static function GetSlotBytes(vm:cpp.RawPointer<WrenVM>, slot:Int, length:cpp.Star<Int>):cpp.ConstCharStar;

	/**
	 * Reads a double value from [slot].
	 *
	 * It is an error to call this if the slot does not contain a number.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return The double value stored in the slot.
	 */
	@:native('wrenGetSlotDouble')
	static function GetSlotDouble(vm:cpp.RawPointer<WrenVM>, slot:Int):Float;

	/**
	 * Reads a foreign object from [slot] and returns a pointer to the foreign data
	 * stored with it.
	 *
	 * It is * an error to call this if the slot does not contain an instance of a
	 * foreign class.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return A pointer to the foreign object's data.
	 */
	@:native('wrenGetSlotForeign')
	static function GetSlotForeign(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.RawPointer<cpp.Void>;

	/**
	 * Reads a string from [slot].
	 *
	 * The memory for the returned string is owned by Wren. You can inspect it
	 * while in your foreign method, but cannot keep a pointer to it after the
	 * function returns, since the garbage collector may reclaim it.
	 *
	 * It is an error to call this if the slot does not contain a string.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return The string stored in the slot.
	 */
	@:native('wrenGetSlotString')
	static function GetSlotString(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.ConstCharStar;

	/**
	 * Creates a handle for the value stored in [slot].
	 *
	 * This will prevent the object that is referred to from being garbage collected
	 * until the handle is released by calling [wrenReleaseHandle()].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return A handle to the object in the slot.
	 */
	@:native('wrenGetSlotHandle')
	static function GetSlotHandle(vm:cpp.RawPointer<WrenVM>, slot:Int):cpp.RawPointer<WrenHandle>;

	/**
	 * Stores the boolean [value] in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param value The boolean value to store.
	 */
	@:native('wrenSetSlotBool')
	static function SetSlotBool(vm:cpp.RawPointer<WrenVM>, slot:Int, value:Bool):Void;

	/**
	 * Stores the array [length] of [bytes] in [slot].
	 *
	 * The bytes are copied to a new string within Wren's heap, so you can free
	 * memory used by them after this is called.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param bytes A pointer to the byte array to store.
	 * @param length The length of the byte array.
	 */
	@:native('wrenSetSlotBytes')
	static function SetSlotBytes(vm:cpp.RawPointer<WrenVM>, slot:Int, bytes:cpp.ConstCharStar, length:cpp.SizeT):Void;

	/**
	 * Stores the numeric [value] in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param value The numeric value to store.
	 */
	@:native('wrenSetSlotDouble')
	static function SetSlotDouble(vm:cpp.RawPointer<WrenVM>, slot:Int, value:Float):Void;

	/**
	 * Creates a new instance of the foreign class stored in [classSlot] with [size]
	 * bytes of raw storage and places the resulting object in [slot].
	 *
	 * This does not invoke the foreign class's constructor on the new instance. If
	 * you need that to happen, call the constructor from Wren, which will then
	 * call the allocator foreign method. In there, call this to create the object
	 * and then the constructor will be invoked when the allocator returns.
	 *
	 * Returns a pointer to the foreign object's data.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param classSlot The slot index of the foreign class.
	 * @param size The size of the raw storage to allocate.
	 * @return A pointer to the foreign object's data.
	 */
	@:native('wrenSetSlotNewForeign')
	static function SetSlotNewForeign(vm:cpp.RawPointer<WrenVM>, slot:Int, classSlot:Int, size:cpp.SizeT):cpp.RawPointer<cpp.Void>;

	/**
	 * Stores a new empty list in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 */
	@:native('wrenSetSlotNewList')
	static function SetSlotNewList(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	/**
	 * Stores a new empty map in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 */
	@:native('wrenSetSlotNewMap')
	static function SetSlotNewMap(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	/**
	 * Stores null in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 */
	@:native('wrenSetSlotNull')
	static function SetSlotNull(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	/**
	 * Stores the string [text] in [slot].
	 *
	 * The [text] is copied to a new string within Wren's heap, so you can free
	 * memory used by it after this is called. The length is calculated using
	 * [strlen()]. If the string may contain any null bytes in the middle, then you
	 * should use [wrenSetSlotBytes()] instead.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param text The string to store.
	 */
	@:native('wrenSetSlotString')
	static function SetSlotString(vm:cpp.RawPointer<WrenVM>, slot:Int, text:cpp.ConstCharStar):Void;

	/**
	 * Stores the value captured in [handle] in [slot].
	 *
	 * This does not release the handle for the value.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @param handle The handle to the value to store.
	 */
	@:native('wrenSetSlotHandle')
	static function SetSlotHandle(vm:cpp.RawPointer<WrenVM>, slot:Int, handle:cpp.RawPointer<WrenHandle>):Void;

	/**
	 * Returns the number of elements in the list stored in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index.
	 * @return The number of elements in the list.
	 */
	@:native('wrenGetListCount')
	static function GetListCount(vm:cpp.RawPointer<WrenVM>, slot:Int):Int;

	/**
	 * Reads element [index] from the list in [listSlot] and stores it in
	 * [elementSlot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param listSlot The slot index of the list.
	 * @param index The index of the element to read.
	 * @param elementSlot The slot index to store the element in.
	 */
	@:native('wrenGetListElement')
	static function GetListElement(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	/**
	 * Sets the value stored at [index] in the list at [listSlot],
	 * to the value from [elementSlot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param listSlot The slot index of the list.
	 * @param index The index at which to set the element.
	 * @param elementSlot The slot index containing the value to set.
	 */
	@:native('wrenSetListElement')
	static function SetListElement(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	/**
	 * Takes the value stored at [elementSlot] and inserts it into the list stored
	 * at [listSlot] at [index].
	 *
	 * As in Wren, negative indexes can be used to insert from the end. To append
	 * an element, use `-1` for the index.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param listSlot The slot index of the list.
	 * @param index The index at which to insert the element.
	 * @param elementSlot The slot index containing the value to insert.
	 */
	@:native('wrenInsertInList')
	static function InsertInList(vm:cpp.RawPointer<WrenVM>, listSlot:Int, index:Int, elementSlot:Int):Void;

	/**
	 * Returns the number of entries in the map stored in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index of the map.
	 * @return The number of entries in the map.
	 */
	@:native('wrenGetMapCount')
	static function GetMapCount(vm:cpp.RawPointer<WrenVM>, slot:Int):Int;

	/**
	 * Returns true if the key in [keySlot] is found in the map placed in [mapSlot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param mapSlot The slot index of the map.
	 * @param keySlot The slot index of the key.
	 * @return `true` if the key is found, otherwise `false`.
	 */
	@:native('wrenGetMapContainsKey')
	static function GetMapContainsKey(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int):Bool;

	/**
	 * Retrieves a value with the key in [keySlot] from the map in [mapSlot] and
	 * stores it in [valueSlot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param mapSlot The slot index of the map.
	 * @param keySlot The slot index of the key.
	 * @param valueSlot The slot index to store the retrieved value in.
	 */
	@:native('wrenGetMapValue')
	static function GetMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, valueSlot:Int):Void;

	/**
	 * Takes the value stored at [valueSlot] and inserts it into the map stored
	 * at [mapSlot] with key [keySlot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param mapSlot The slot index of the map.
	 * @param keySlot The slot index of the key.
	 * @param valueSlot The slot index containing the value to insert.
	 */
	@:native('wrenSetMapValue')
	static function SetMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, valueSlot:Int):Void;

	/**
	 * Removes a value from the map in [mapSlot], with the key from [keySlot],
	 * and place it in [removedValueSlot]. If not found, [removedValueSlot] is
	 * set to null, the same behaviour as the Wren Map API.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param mapSlot The slot index of the map.
	 * @param keySlot The slot index of the key.
	 * @param removedValueSlot The slot index to store the removed value in.
	 */
	@:native('wrenRemoveMapValue')
	static function RemoveMapValue(vm:cpp.RawPointer<WrenVM>, mapSlot:Int, keySlot:Int, removedValueSlot:Int):Void;

	/**
	 * Looks up the top level variable with [name] in resolved [module] and stores
	 * it in [slot].
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param module The name of the module.
	 * @param name The name of the variable.
	 * @param slot The slot index to store the variable in.
	 */
	@:native('wrenGetVariable')
	static function GetVariable(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, name:cpp.ConstCharStar, slot:Int):Void;

	/**
	 * Looks up the top level variable with [name] in resolved [module],
	 * returns false if not found. The module must be imported at the time,
	 * use wrenHasModule to ensure that before calling.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param module The name of the module.
	 * @param name The name of the variable.
	 * @return `true` if the variable is found, otherwise `false`.
	 */
	@:native('wrenHasVariable')
	static function HasVariable(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar, name:cpp.ConstCharStar):Bool;

	/**
	 * Returns true if [module] has been imported/resolved before, false if not.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param module The name of the module.
	 * @return `true` if the module is imported, otherwise `false`.
	 */
	@:native('wrenHasModule')
	static function HasModule(vm:cpp.RawPointer<WrenVM>, module:cpp.ConstCharStar):Bool;

	/**
	 * Sets the current fiber to be aborted, and uses the value in [slot] as the
	 * runtime error object.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param slot The slot index containing the error object.
	 */
	@:native('wrenAbortFiber')
	static function AbortFiber(vm:cpp.RawPointer<WrenVM>, slot:Int):Void;

	/**
	 * Returns the user data associated with the WrenVM.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @return A pointer to the user data associated with the WrenVM.
	 */
	@:native('wrenGetUserData')
	static function GetUserData(vm:cpp.RawPointer<WrenVM>):cpp.RawPointer<cpp.Void>;

	/**
	 * Sets user data associated with the WrenVM.
	 *
	 * @param vm A pointer to the WrenVM instance.
	 * @param userData A pointer to the user data to set.
	 */
	@:native('wrenSetUserData')
	static function SetUserData(vm:cpp.RawPointer<WrenVM>, userData:cpp.RawPointer<cpp.Void>):Void;
}
