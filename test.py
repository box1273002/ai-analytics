from typing import Callable, Any


def get_valmap(
        data: list[dict],
        key: str,
        val: str,
        skip_missing: bool = True,
        key_transform: Callable[[Any], Any] = lambda x: x,
        val_transform: Callable[[Any], Any] = lambda x: x
) -> dict:
    valmap = {}
    for item in data:
        if skip_missing and key not in item or val not in item:
            continue
        valmap[key_transform(item[key])] = val_transform(item[val])
    return valmap


stations = [{}]
station_zones = get_valmap(stations, "station_id", "zone")
