local adjust = {
	["steering"] = {Vector(7, 9, 0), Angle(0, -80, 0), Vector(-7, 9, 0), Angle(0, -100, 180)},
	["steeringwheel"] = {Vector(7.5, -3.5, 0), Angle(180, -90, 0), Vector(-7.5, -3.5, 0), Angle(0, 90, 0)},
	["steering_wheel"] = {Vector(9, 13, -1), Angle(0, -90, 0), Vector(-9, 13, -1), Angle(-180, 90, 0)},
	["Rig_Buggy.Steer_Wheel"] = {Vector(8, -2.5, 0), Angle(0, -90, 0), Vector(-8, -2.5, 0), Angle(180, 90, 0)},
	["car.steeringwheel"] = {Vector(15, -10, 0), Angle(0, 180, 0), Vector(15, 10, 0), Angle(180, 0, 0)},
	["Airboat.Steer"] = {Vector(-11, -1.5, 10), Angle(70, 50, 50), Vector(11, -1.5, 10), Angle(70, 50, 50)},
	["handlebars"] = {
		Vector(10, -6, -19),
		Angle(-15, 60, -90),
		Vector(-10, -6, -19),
		Angle(-15, 120, -90)
	},
	["steerw_bone"] = {Vector(9, 10, 0), Angle(0, -80, 0), Vector(-9, 10, 0), Angle(0, -100, 180)},
}

local modelAdjust = {
	["models/left4dead/vehicles/apc_body_glide.mdl"] = {Vector(10.5, 14, -1), Angle(0, -90, 0), Vector(-10.5, 14, -1), Angle(-180, 90, 0)},
	["models/left4dead/vehicles/nuke_car_glide.mdl"] = {Vector(7, 12, -1), Angle(0, -90, 0), Vector(-7, 12, -1), Angle(180, 90, 0)},
	["models/gta5/vehicles/sanchez/chassis.mdl"] = {
		Vector(15, 17, -4.5),
		Angle(-95, 90, -90),
		Vector(-15, 17, -4.5),
		Angle(-95, 90, -90)},
	["models/gta5/vehicles/wolfsbane/chassis.mdl"] = {
		Vector(14.5, 15.5, -7.5),
		Angle(-95, 90, -90),
		Vector(-14.5, 15.5, -7.5),
		Angle(-95, 90, -90)
	},
	["models/gta5/vehicles/blazer/chassis.mdl"] = {
		Vector(13, 11, -5),
		Angle(-95, 90, -90),
		Vector(-13, 11, -5),
		Angle(-95, 90, -90)
	},
	["models/gta5/vehicles/speedo/chassis.mdl"] = {
		Vector(8, 4, 0),
		Angle(0, -90, 0),
		Vector(-8, 4, 0),
		Angle(0, -90, 180)
	},
	["models/gta5/vehicles/dukes/chassis.mdl"] = {
		Vector(7, 6, 0),
		Angle(0, -80, 0),
		Vector(-7, 6, 0),
		Angle(0, -100, 180)
	},
	["models/gta5/vehicles/police/chassis.mdl"] = {
		Vector(7.5, 5, 0),
		Angle(0, -80, 0),
		Vector(-7.5, 5, 0),
		Angle(0, -100, 180)
	},
	["models/gta5/vehicles/hauler/chassis.mdl"] = {
		Vector(10, 4, 0),
		Angle(0, -90, 0),
		Vector(-10, 4, 0),
		Angle(0, -90, 180)
	},
	["models/blackterios_glide_vehicles/chevroletcorsaclassic/chevroletcorsaclassic.mdl"] = {
		Vector(-9.5, 3, 0),
		Angle(180, 90, 0),
		Vector(9.5, 3, 0),
		Angle(0, -90, 0)
	},
	["models/blackterios_glide_vehicles/datsun510/datsun510.mdl"] = {
		Vector(8.5, 7.5, -1),
		Angle(0, -90, 0),
		Vector(-8.5, 7.5, -1),
		Angle(0, -90, 180)
	},
	["models/blackterios_glide_vehicles/fiatduna/fiatduna.mdl"] = {
		Vector(8.5, 3.5, -1),
		Angle(0, -90, 0),
		Vector(-8.5, 3.5, -1),
		Angle(0, -90, 180)
	},
	["models/blackterios_glide_vehicles/renaulttrafict1000d/renaulttrafict1000d.mdl"] = {
		Vector(-11.5, 7, 0),
		Angle(180, 90, 0),
		Vector(11.5, 7, 0),
		Angle(0, -90, 0)
	},
	["models/blackterios_glide_vehicles/zanellarx150/zanellarx150.mdl"] = {
		Vector(12, 9.5, -9),
		Angle(-70, 0, 0),
		Vector(-12, 9.5, -9),
		Angle(-110, 0, 0)
	},
	["models/gta5/vehicles/seashark/chassis.mdl"] = {
		Vector(11, -2, -16),
		Angle(-35, 80, -90),
		Vector(-11, -2, -16),
		Angle(-35, 100, -90)
	},
	["models/hl2vehicles/muscle.mdl"] = {
		Vector(9, 3.9, 0),
		Angle(0, -90, 5),
		Vector(-9, 3.9, 0),
		Angle(180, 90, -5)
	}
}

function hg.GetCarSteering(Car)
	if not Car.steer then
		for k, v in pairs(adjust) do
			local steer = Car:LookupBone(k)

			if steer then
				Car.steer = steer
				Car.adjust = modelAdjust[Car:GetModel()] or adjust[k]
				break
			end
		end
	end

	return Car.steer, Car.adjust
end
