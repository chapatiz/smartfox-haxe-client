package com.smartfoxserver.v2.entities.managers;

import com.smartfoxserver.v2.SmartFox;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.variables.BuddyVariable;
import com.smartfoxserver.v2.entities.variables.ReservedBuddyVariables;
import com.smartfoxserver.v2.entities.variables.SFSBuddyVariable;
import com.smartfoxserver.v2.util.ArrayUtil;

/**
 * The<em>SFSBuddyManager</em>class is the entity in charge of managing the current user's<b>Buddy List</b>system.
 * It keeps track of all the user's buddies, their state and their Buddy Variables.
 * It also provides utility methods to set the user's properties when he is part of the buddies list of other users.
 * 
 * @see		com.smartfoxserver.v2.SmartFox#buddyManager SmartFox.buddyManager
 */
class SFSBuddyManager implements IBuddyManager
{
	/** @private */
	private var _buddiesByName:Dynamic;
	
	/** @private */
	private var _myVariables:Dynamic;
	
	/** @private */
	private var _myOnlineState:Bool;
	
	/** @private 
	private var _myNickName:String
	private var _myState:String
	*/
	
	/** @private */
	private var _inited:Bool;
	
	private var _buddyStates:Array;
	private var _sfs:SmartFox;
	
	/**
	 * Creates a new<em>SFSBuddyManager</em>instance.
	 * 
	 *<p><b>NOTE</b>:developers never instantiate a<em>SFSBuddyManager</em>manually:this is done by the SmartFoxServer 2X API Internally.
	 * A reference to the existing instance can be retrieved using the<em>SmartFox.buddyManager</em>property.</p>
	 *  
	 * @param 	sfs		An instance of the SmartFoxServer 2X client API main<em>SmartFox</em>class.
	 * 
	 * @see		com.smartfoxserver.v2.SmartFox#buddyManager SmartFox.buddyManager
	 */
	public function new(sfs:SmartFox)
	{
		_sfs = sfs;
		_buddiesByName = { };
		_myVariables = { };
		_inited = false	;
	}
	
	/** @inheritDoc */ 
	public var isInited(get_isInited, null):Bool;
 	private function get_isInited():Bool
	{
		return _inited;
	}
	
	/** @private */
	public function setInited(flag:Bool):Void
	{
		_inited=flag;
	}
	
	/** @private */
	public function addBuddy(buddy:Buddy):Void
	{
		_buddiesByName[buddy.name] = buddy	;
	}
	
	/** @private */
	public function clearAll():Void
	{
		_buddiesByName = { };
	}
	
	/** @private */
	public function removeBuddyById(id:Int):Buddy
	{
		var buddy:Buddy = getBuddyById(id);
		
		if(buddy !=null)
			delete _buddiesByName[buddy.name];
		
		return buddy;
	}
	
	/** @private */
	public function removeBuddyByName(name:String):Buddy
	{
		var buddy:Buddy = getBuddyByName(name);
		
		if(buddy !=null)
			_buddiesByName[name]=null;
			
		return buddy;
	}
	
	/** @inheritDoc */
	public function getBuddyById(id:Int):Buddy
	{
		if(id>-1)
		{			
			for(buddy in _buddiesByName)
			{
				if(buddy.id==id)
					return buddy;
			}
		}
		
		return null;
	}
	
	/** @inheritDoc */
	public function containsBuddy(name:String):Bool
	{
		return getBuddyByName(name) != null;
	}
	
	/** @inheritDoc */
	public function getBuddyByName(name:String):Buddy
	{
		return _buddiesByName[name];
	}
	
	/** @inheritDoc */
	public function getBuddyByNickName(nickName:String):Buddy
	{
		for(var buddy:Buddy in _buddiesByName)
		{
			if(buddy.nickName==nickName)
				return buddy;
		}
		
		return null;
	}
	
	/** @inheritDoc */
	public var offlineBuddies(get_offlineBuddies, null):Array;
 	private function get_offlineBuddies():Array
	{
		var buddies:Array<Dynamic> = [];
		
		for(var buddy:Buddy in _buddiesByName)
		{
			if(!buddy.isOnline)
				buddies.push(buddy);
		}
		
		return buddies;
	}
	
	/** @inheritDoc */
	public var onlineBuddies(get_onlineBuddies, null):Array;
 	private function get_onlineBuddies():Array
	{
		var buddies:Array<Dynamic> = [];
		
		for(var buddy:Buddy in _buddiesByName)
		{
			if(buddy.isOnline)
				buddies.push(buddy);
		}
		
		return buddies;
	}
	
	/** @inheritDoc */
	public var buddyList(get_buddyList, null):Array;
 	private function get_buddyList():Array
	{
		return ArrayUtil.objToArray(_buddiesByName);
	}
	
	/** @inheritDoc */
	public function getMyVariable(varName:String):BuddyVariable
	{
		return cast _myVariables[varName];
	}
	
	/** @inheritDoc */
	public var myVariables(get_myVariables, null):Array;
 	private function get_myVariables():Array
	{
		return ArrayUtil.objToArray(_myVariables);	
	}
	
	/** @inheritDoc */
	public var myOnlineState(get_myOnlineState, null):Bool;
 	private function get_myOnlineState():Bool
	{
		// Manager not inited, we're offline
		if(!_inited)
			return false;
	
		// If the online var is not defined we take it as online=true(default)
		var onlineState:Bool = true;
		var onlineVar:BuddyVariable = getMyVariable(ReservedBuddyVariables.BV_ONLINE);
		
		if(onlineVar !=null)
			onlineState = onlineVar.getBoolValue();
		
		return onlineState;
	}
	
	/** @inheritDoc */
	public var myNickName(get_myNickName, null):String;
 	private function get_myNickName():String
	{
		var nickNameVar:BuddyVariable = getMyVariable(ReservedBuddyVariables.BV_NICKNAME);
		return(nickNameVar != null)? nickNameVar.getStringValue():null ;
	}
	
	/** @inheritDoc */
	public var myState(get_myState, null):String;
 	private function get_myState():String
	{
		var stateVar:BuddyVariable = getMyVariable(ReservedBuddyVariables.BV_STATE);
		return(stateVar != null)? stateVar.getStringValue():null ;
	}
	
	/** @inheritDoc */
	public var buddyStates(get_buddyStates, null):Array;
 	private function get_buddyStates():Array
	{
		return _buddyStates;
	}
	
	/** @private */
	public function setMyVariable(bVar:BuddyVariable):Void
	{
		_myVariables[bVar.name] = bVar;
	}
	
	// Replaces all
	/** @private */
	public function setMyVariables(variables:Array):Void
	{
		for(var bVar:BuddyVariable in variables)
		{
			setMyVariable(bVar);
		}
	}
	
	/** @private */
	public function setMyOnlineState(isOnline:Bool):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_ONLINE, isOnline));
	}
	
	/** @private */
	public function setMyNickName(nickName:String):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_NICKNAME, nickName));	
	}
	
	/** @private */
	public function setMyState(state:String):Void
	{
		setMyVariable(new SFSBuddyVariable(ReservedBuddyVariables.BV_STATE, state));
	}
	
	/** @private */
	public function setBuddyStates(states:Array):Void
	{
		_buddyStates = states;
	}
}