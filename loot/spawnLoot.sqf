/**
*  spawnLoot
*
*  Spawns loot randomly around the play area
*
*  Domain: Server
**/

activeLoot = [];
lootDebugMarkers = [];


/* Item to reveal hostiles on Map (1 spawns every wave) */
_droneRoom = while {true} do {
	_lootBulding = selectRandom lootHouses;
	_lootRooms = _lootBulding buildingPos -1;
	_lootRoom = selectRandom _lootRooms;
	if(!isNil "_lootRoom") exitWith {_lootRoom};
};
_droneSupport = createVehicle ["Box_C_UAV_06_Swifd_F", _droneRoom, [], 0, "CAN_COLLIDE"];
_droneSupport addAction ["Reveal enemies", "supports\reconDrone.sqf"];

activeLoot pushback _droneSupport;

/* Master loot spawner */
if(LOOT_DEBUG) then { systemChat "Started loot spawn"; };
_houseCount = floor random 3; // Mix up the loot houses a bit
_houseLoot = 0;
_roomCount = 0;
{
	_houseCount = _houseCount + 1;
	if (_houseCount mod LOOT_HOUSE_DISTRIBUTION == 0) then {
		_houseLoot = _houseLoot + 1;

		_lootBulding = _x;
		_lootRooms = _lootBulding buildingPos -1;

		if(LOOT_DEBUG) then {
			_houseMkr = createMarker [netId _lootBulding, getPos _lootBulding];
			_houseMkr setMarkerShape "ICON";
			_houseMkr setMarkerType "hd_dot";
			_houseMkr setMarkerColor "ColorBlue";
			lootDebugMarkers pushback _houseMkr;
		};

		_roomCount = -1;
		{
			_roomCount = _roomCount + 1;
			if (_roomCount mod LOOT_ROOM_DISTRIBUTION == 0) then {

				_lootRoomPos = _x;
				_lootHolder = "WeaponHolderSimulated_Scripted" createVehicle _lootRoomPos;

				switch (floor random 6) do {
					case 0: {
						_weapon = selectRandom LOOT_WEAPON_POOL;
						_ammoArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
						_lootHolder addMagazineCargoGlobal [selectRandom _ammoArray, 1];
						_lootHolder addWeaponCargoGlobal [_weapon, 1];
					};
					case 1: {
						_weapon = selectRandom LOOT_WEAPON_POOL;
						_ammoArray = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
						_lootHolder addMagazineCargoGlobal [selectRandom _ammoArray, 1 + (floor random 3)];
					};
					case 2: {
						_clothes = selectRandom LOOT_APPAREL_POOL;
						_lootHolder addItemCargoGlobal [_clothes, 1];
					};
					case 3: {
						_optics = selectRandom LOOT_ITEM_POOL;
						_lootHolder addItemCargoGlobal [_optics, 1];
					};
					case 4: {
						_backpack = selectRandom LOOT_STORAGE_POOL;
						_lootHolder addBackpackCargoGlobal [_backpack, 1];
					};
					case 5: {
						_explosive = selectRandom LOOT_EXPLOSIVE_POOL;
						_lootHolder addMagazineCargoGlobal [_explosive, 1 + (floor random 3)];
					};
				};
				_lootHolder setPos [_lootRoomPos select 0, _lootRoomPos select 1, (_lootRoomPos select 2) + 0.1];

				if(LOOT_DEBUG) then {
					_houseMkr = createMarker [netId _lootHolder, getPos _lootHolder];
					_houseMkr setMarkerShape "ICON";
					_houseMkr setMarkerType "hd_dot";
					_houseMkr setMarkerColor "ColorRed";
					lootDebugMarkers pushback _houseMkr;
				};

				activeLoot pushback _lootHolder; // Add object to array for later cleanup
			};
		} forEach _lootRooms;
	};

} forEach lootHouses;

if(LOOT_DEBUG) then { systemChat format ["Loot spawn complete (%1/%2)", _houseCount, _houseLoot]; };

/* Supply Drop */
_dropPos = bulwarkCity;
[_dropPos, ["FILL AMMO", "supports\ammoDrop.sqf"], "B_T_VTOL_01_vehicle_F"] remoteExec ["supports_fnc_supplyDrop", 2];
