#include "script_component.hpp"
/*
 * Author: Glowbal, mharis001
 * Uses one of the treatment items. Respects the priority defined by the allowSharedEquipment setting.
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Items <ARRAY>
 *
 * Return Value:
 * User and Item <ARRAY>
 *
 * Example:
 * [player, cursorObject, ["bandage"]] call ace_medical_treatment_fnc_useItem
 *
 * Public: No
 */

params ["_medic", "_patient", "_items"];

scopeName "Main";

private _sharedUseOrder = [[_patient, _medic], [_medic, _patient], [_medic]] select ACEGVAR(medical_treatment,allowSharedEquipment);
private _useOrder = [];

private _vehicle = vehicle _medic;
private _vehicleCondition = _vehicle != _medic && _vehicle isEqualTo (vehicle _patient);
private _vehicleIndex = -1;

if (GVAR(allowSharedVehicleEquipment) > 0 && _vehicleCondition) then {
    switch (GVAR(allowSharedVehicleEquipment)) do {
        case 1: { // Medic's equipment first
            _useOrder = [_medic,_vehicle] + _sharedUseOrder;
            _vehicleIndex = 1;
        };
        case 2: { // Vehicle's equipment first (no self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 3: { // Vehicle's equipment first (except self-treatment)
            if(_medic isEqualTo _patient) then {
                _useOrder = _sharedUseOrder + [_vehicle];
                _vehicleIndex = (count _useOrder) - 1;
            } else {
                _useOrder = ([_vehicle] + _sharedUseOrder);
                _vehicleIndex = 0;
            };
        };
        case 4: { // Vehicle's equipment first (always)
            _useOrder = ([_vehicle] + _sharedUseOrder);
            _vehicleIndex = 0;
        };
        default {
            _useOrder = _sharedUseOrder;
        };
    };
} else {
    _useOrder = _sharedUseOrder;
};

{
    private _origin = _x;
    if(_forEachIndex != _vehicleIndex) then { // Remove unit item
        private _originItems = [_origin, false, false] call FUNC(getUniqueItems); // Item
        {
            if (_x in _originItems) then {
                _origin removeItem _x;
                [_origin, _x] breakOut "Main";
            };
        } forEach _items;

        _originItems = [_origin, false, true] call FUNC(getUniqueItems); // Magazine
        {
            if (_x in _originItems) then {
                [_origin,_x] call EFUNC(pharma,removeItemFromMag);
                [_origin, _x] breakOut "Main";
            };
        } forEach _items;
    } else { // Remove vehicle item
        private _originItems = [_origin, true, false] call FUNC(getUniqueItems); // Item
        {
            if (_x in _originItems) then {
                [_origin, _x] call FUNC(removeItemFromVehicle);
                [_origin, _x] breakOut "Main";
            };
        } forEach _items;
        
        _originItems = [_origin, true, true] call FUNC(getUniqueItems); // Magazine
        {
            if (_x in _originItems) then {
                [_origin, _x, true] call FUNC(removeItemFromVehicle);
                [_origin, _x] breakOut "Main";
            };
        } forEach _items;
    };
} forEach _useOrder;

[objNull, ""]
