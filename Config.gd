@tool
extends Node


enum {Beacons, Scaffoldings, ParkedCars, Dumpsters, Billboards, TrafficCones, StreeLights, Hydrants, Cafes}

var Props = {
	Beacons : {
		"number_of": 20,
		"scene": preload("res://Beacon/Beacon.tscn"),
		"tiles_list": []
	},
	Scaffoldings : {
		"number_of": 25,
		"scene": preload("res://Props/Scaffolding/Scaffolding.tscn"),
		"tiles_list": []
	},
	ParkedCars : {
		"number_of": 100,
		"scene": preload("res://Props/ParkedCars/ParkedCars.tscn"),
		"tiles_list": []
	},
	Dumpsters : {
		"number_of": 25,
		"scene": preload("res://Props/Dumpsters/Dumpster.tscn"),
		"tiles_list": []
	},
	Billboards : {
		"number_of": 75,
		"scene": preload("res://Props/Billboards/Billboard.tscn"),
		"tiles_list": []
	},
	TrafficCones : {
		"number_of": 40,
		"scene": preload("res://Props/TrafficCones/traffic_cone.tscn"),
		"tiles_list": []
	},
	StreeLights : {
		"number_of": 50,
		"scene": preload("res://Props/StreeLights/StreetLight.tscn"),
		"tiles_list": []
	},
	Hydrants : {
		"number_of": 50,
		"scene": preload("res://Props/Hydrants/Hydrant.tscn"),
		"tiles_list": []
	},
	Cafes : {
		"number_of": 20,
		"scene": preload("res://Props/Cafe/Cafe.tscn"),
		"tiles_list": []
	}
}
