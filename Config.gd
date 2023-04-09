@tool
extends Node


enum {Beacons, Goal, Scaffoldings, ParkedCars, Dumpsters, Billboards, TrafficCones, StreeLights, Hydrants, Cafes}

var Props = {
	Beacons : {
		"name": "Beacons",
		"number_of": 20,
		"scene": preload("res://Beacon/Beacon.tscn"),
		"tiles_list": []
	},
	Goal : {
		"name": "Goal",
		"number_of": 1,
		"scene": preload("res://Beacon/Goal.tscn"),
		"tiles_list": []
	},
	Scaffoldings : {
		"name": "Scaffoldings",
		"number_of": 25,
		"scene": preload("res://Props/Scaffolding/Scaffolding.tscn"),
		"tiles_list": []
	},
	ParkedCars : {
		"name": "ParkedCars",
		"number_of": 100,
		"scene": preload("res://Props/ParkedCars/ParkedCars.tscn"),
		"tiles_list": []
	},
	Dumpsters : {
		"name": "Dumpsters",
		"number_of": 25,
		"scene": preload("res://Props/Dumpsters/Dumpster.tscn"),
		"tiles_list": []
	},
	Billboards : {
		"name": "Billboards",
		"number_of": 75,
		"scene": preload("res://Props/Billboards/Billboard.tscn"),
		"tiles_list": []
	},
	TrafficCones : {
		"name": "TrafficCones",
		"number_of": 40,
		"scene": preload("res://Props/TrafficCones/traffic_cone.tscn"),
		"tiles_list": []
	},
	StreeLights : {
		"name": "StreeLights",
		"number_of": 50,
		"scene": preload("res://Props/StreeLights/StreetLight.tscn"),
		"tiles_list": []
	},
	Hydrants : {
		"name": "Hydrants",
		"number_of": 50,
		"scene": preload("res://Props/Hydrants/Hydrant.tscn"),
		"tiles_list": []
	},
	Cafes : {
		"name": "Cafes",
		"number_of": 20,
		"scene": preload("res://Props/Cafe/Cafe.tscn"),
		"tiles_list": []
	}
}
