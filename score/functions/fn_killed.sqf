/**
*  fn_killed
*
*  Event handler for unit death.
*
*  Domain: Event
**/

if (isServer) then {
    _instigator = _this select 2;
    if (isPlayer _instigator) then {
        [_instigator, SCORE_KILL] call killPoints_fnc_add;

		totalEnemyUnits = (totalEnemyUnits - 1);
		publicVariable "totalEnemyUnits";
		[] remoteExec ["killPoints_fnc_updateHud", -2];
    };
};
