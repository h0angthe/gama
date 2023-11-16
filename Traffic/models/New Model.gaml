/**
* Name: NewModel
* Based on the internal empty template. 
* Author: Hoang The
* Tags: gis
*/
model NewModel

/* Insert your model definition here */
global {
// Global variables related to the Management units 
	file shapeFile1 <- file("../includes/bbbike/buildings.shp");
	file shapeFile2 <- file("../includes/bbbike/roads.shp");
	//    file shapeFile3 <- file("../includes/bbbike/waterways.shp");
	map<string, rgb> building_color_map <- ["RS"::#red, "RM"::rgb(125, 125, 125), "RL"::rgb(75, 75, 75), "OS"::rgb(250, 226, 59), "OM"::rgb(255, 147, 0), "OL"::rgb(215, 95, 0)];
	map<string, rgb> color_per_mode <- ["car"::rgb(52, 152, 219), "bike"::rgb(192, 57, 43), "walk"::rgb(161, 196, 90), "pev"::#magenta];
	//definition of the environment size from the shapefile. 
	//Note that is possible to define it from several files by using: geometry shape <- envelope(envelope(file1) + envelope(file2) + ...);
	geometry shape <- envelope(envelope(shapeFile1) + envelope(shapeFile2));
	float step <- 10 #mn;
	bool heatmap <- true;
	bool showAgent <- true;
	bool heatmap_clean <- false;
	bool road_display <- true;
	bool building_display <- true;
	bool add_bridges_flag <- false;
	bool ns_wind <- false;
	bool dynamic_background <- false;
	int min_work_start <- 6;
	int max_work_start <- 8;
	int min_work_end <- 16;
	int max_work_end <- 20;
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	float destroy <- 0.02;
	int repair_time <- 2;
	graph the_graph;

	init {
		create Buildings from: shapeFile1;
		create Roads from: shapeFile2 with: [lanes::int(read("lanes")), oneway::string(read("oneway"))] {
			switch oneway {
				match "no" {
					create road {
						lanes <- myself.lanes;
						shape <- polyline(reverse(myself.shape.points));
						maxspeed <- myself.maxspeed;
						linked_road <- myself;
						myself.linked_road <- self;
					}

				}

				match "-1" {
					shape <- polyline(reverse(shape.points));
				}

			}

		}

		road_network <- (as_driving_graph(road)) with_weights general_speed_map;
		create driver number: 10000 {
			location <- one_of(node).location;
			vehicle_length <- 3.0;
			max_acceleration <- 0.5 + rnd(500) / 1000;
			speed_coeff <- 1.2 - (rnd(400) / 1000);
			right_side_driving <- true;
			proba_lane_change_up <- rnd(500) / 500;
			proba_lane_change_down <- 0.5 + (rnd(250) / 500);
			security_distance_coeff <- 3 - (rnd(2000) / 1000);
			proba_respect_priorities <- 1.0 - rnd(200 / 1000);
			proba_respect_stops <- [1.0 - rnd(2) / 1000];
			proba_block_node <- rnd(3) / 1000;
			proba_use_linked_road <- rnd(10) / 1000;
		}

	}

}

species Buildings {
	string type;
	rgb color <- #gray;

	aspect base {
		draw shape color: color;
	}

}

species Roads {
	rgb color <- #black;

	aspect base {
		draw shape color: color;
	}

}

species driver skills: [advanced_driving] {

	reflex move when: final_target != nil {
		do drive;
	}

}
//species Landuse  {
//	rgb color <- #red ;
//	aspect base {
//		draw shape color: color ;
//	}
//}
experiment main type: gui {

//	parameter "Shapefile for the buildings:" var: shapeFile1 category: "GIS" ;
//	parameter "Shapefile for the road1:" var: shapeFile2  category: "GIS" ;
//	parameter "Shapefile for the road2:" var: shapeFile3  category: "GIS" ;
	output {
		display StreetMap type: 3d {
			species Buildings;
			species Roads;
			specise driver;
		}

	}

}

    
