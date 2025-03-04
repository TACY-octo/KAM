#include "script_component.hpp"
/*
* Author: DiGii
*
* Arguments:
* 0: player <Object>
*
* Return Value:
* NONE
*
* Example:
* [] call kat_chemical_fnc_init;
*
* Public: No
*/
params ["_unit", ["_isRespawn", true]];

if (!local _unit) exitWith {};

    _unit setVariable [QGVAR(timeleft), missionNamespace getVariable [QGVAR(infectionTime), 60], true];
    _unit setVariable [QGVAR(enteredPoison), false, true];
    _unit setVariable [QGVAR(gasmask_durability), 10, true];
    _unit setVariable [QGVAR(gasmask_durability_reset), false, true];
    _unit setVariable [QGVAR(chemDetectorState), true , true];
    _unit setVariable [QGVAR(airPoisoning), false, true];
    _unit setVariable [QGVAR(CS), false, true];

    [_unit] call FUNC(coughing);
    [_unit] call FUNC(handleGasMaskDur);
    [_unit] call FUNC(breathing);

    [{
        params ["_args", "_pfhID"];
        _args params ["_unit"];
        private _playertime = _unit getVariable [QGVAR(timeleft), 60];
        private _maxtime = missionnamespace getVariable [QGVAR(infectionTime), 60];
        if (!(_unit getVariable [QGVAR(enteredPoison), false])) then {
            if (_playertime < missionnamespace getVariable [QGVAR(infectionTime), 60]) then {
                _playertime = _playertime + 1;
                if (_playertime >= _maxtime) then {
                    _playertime = _maxtime;
                };
                _unit setVariable[QGVAR(timeleft), _playertime, true];
            };
        };
    }, 2, _unit]call CBA_fnc_addPerFrameHandler;
