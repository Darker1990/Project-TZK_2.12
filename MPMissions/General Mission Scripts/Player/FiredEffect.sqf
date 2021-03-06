// args: [Fired-EH-Array, LimitWeaponRangeFactor]
// _vehicle addEventHandler ["Fired", {[_this, LimitWeaponRangeFactor] call <this function>}]
// maybe using an instant animation to control visual effect show on/off
// return: none

// private list
private ["_Fired_EH_Array", "_vehicle", "_weapon", "_muzzle", "_mode", "_ammo", "_limitWeaponRangeFactor", "_shell", 
"_position", "_x", "_y", "_z", "_velocity", "_dir", "_effectShell", "_booleShell", "_sizeOfShell"
];

_Fired_EH_Array = _this select 0;
_vehicle = _Fired_EH_Array select 0;
_weapon  = _Fired_EH_Array select 1;
_muzzle  = _Fired_EH_Array select 2;
_mode    = _Fired_EH_Array select 3;
_ammo    = _Fired_EH_Array select 4;

_limitWeaponRangeFactor = _this select 1;

_shell = nearestObject [_vehicle, _ammo]; _effectShell = objNull;

_booleShell = false; _sizeOfShell = 0;
if (_weapon in ["Gun73"]) then {_booleShell = true; _sizeOfShell = 73};
if (_weapon in ["Gun105"]) then {_booleShell = true; _sizeOfShell = 105};
if (_weapon in ["M1Gun_xj200","M12Gun_xj200","LeoGun_xj200","Gun120"]) then {_booleShell = true; _sizeOfShell = 120};
if (_weapon in ["T80Gun_xj200","T90Gun_xj200","PLAGun_xj200","Gun125", "Sprut_2A75_xj200"]) then {_booleShell = true; _sizeOfShell = 125};
if (_weapon in ["Gun130_xj200"]) then {_booleShell = true; _sizeOfShell = 130};
if (_weapon in ["Gun155_xj200","PLA155Gun_xj200"]) then {_booleShell = true; _sizeOfShell = 155};

if (local _shell) then {

// Range
	if (typeOf _shell != ammoMine) then { [_vehicle, _shell, _limitWeaponRangeFactor] exec "Player\LimitWeaponRangeNew.sqs" };
	_effectShell = _shell;
	if ((_limitWeaponRangeFactor <= 0 && _sizeOfShell > 0) || _sizeOfShell > 125) then {
// Marker
		_Fired_EH_Array exec "Player\ImpactPointMarker.sqs";
		if (_limitWeaponRangeFactor <= 0 && _sizeOfShell > 0) then {
// Track
			if (player == gunner _vehicle && (bTrackBullet || !bTrackBullet)) then {[_shell] exec "Player\TrackBullet.sqs"};
		};
	};
} else {
	if (boole_Global_Bullet_Tracer || boole_Global_Cannon_Tracer || boole_Global_Shell_Tracer) then
	{
		_position = getPos _shell; _velocity = velocity _shell; _dir = vectorDir _shell;

		// Because Sabot, Heat, Missile, etc, will detonate bullet, thus it's necessary to create effect away from actual ammo when they're shell or missile.
		if (_booleShell) then {_x = _position select 0; _y = _position select 1; _z = _position select 2; _position = [_x, _y, _z + 1000]};

		_effectShell = "Bizon_Bullet_xj200" camCreate _position;
		_effectShell setVectorDirAndUp [_dir, [0,0,1]];
		_effectShell setVelocity _velocity;
	};
};

	if ((_limitWeaponRangeFactor <= 0 && _sizeOfShell > 0) || _sizeOfShell > 125) then { _Fired_EH_Array call loadFile {Player\Effect\stvol.sqf} };

if (!isNull _effectShell) then {
	// SLX MG Hit Effect
	_type = typeOf _shell;
	if ( _type in ["CoaxW_xj200","CoaxE_xj200","50calW_xj200","50calE_xj200","Bullet7_6","Bullet12_7"] ) then {
		if ((boole_Local_Bullet_Tracer && local _shell) || (boole_Global_Bullet_Tracer && !local _shell)) then {[_effectShell] exec {Player\FiredEffect_SLX_MG.sqs}};
	};

	// FFUR Cannon Tracer Effect
	if ( _weapon in ["MachineGun30","MachineGun30W","M197_xj200","VulcanCannon_xj200","Cannon_20HE_xj200","Cannon_20AP_xj200","RMKHETiger_DVD_xj200","RMKAPTiger_DVD_xj200",  "MachineGun30E","ZsuCannon","Cannon30_Kamov_xj200","CannonE_20HE_xj200","CannonE_20AP_xj200",  "MachineGun30A10","MachineGun30A10Burst","RKTHunter_Guns","Cannon_Heli_xj200","Cannon_30APHE_xj200"] ) then {
		if ((boole_Local_Cannon_Tracer && local _shell) || (boole_Global_Cannon_Tracer && !local _shell)) then {[_effectShell, _weapon] exec {Player\FiredEffect_FFUR_Cannon.sqs}};
	};
	
	// COC Shell Tracer
	if (_booleShell) then {
	// Always tracer size > 125 shell.
		if ((boole_Local_Shell_Tracer || _sizeOfShell > 125) && local _shell) then {[true, _shell, _sizeOfShell] exec {Player\FiredEffect_COC_Tracer.sqs}};
		if ((boole_Global_Shell_Tracer || _sizeOfShell > 125) && !local _shell) then {[false, _effectShell, _sizeOfShell, _position, _velocity, _dir, _vehicle] exec {Player\FiredEffect_COC_Tracer.sqs}};
	};
};

