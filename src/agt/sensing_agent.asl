// sensing agent


/* Initial beliefs and rules */
org_name(lab_monitoring_org).
group_name(monitoring_team).
sch_name(monitoring_scheme).
/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").


/*
 * Plan: react to new org workspace availability, join and observe artifacts, then adopt relevant role
 */
@workspace_available_plan
+workspaceAvailable(OrgName, W) : org_name(OrgName) <-
    .print("sensing_agent: detected workspace available ", OrgName);
    joinWorkspace(OrgName, W);
    .print("sensing_agent: joined workspace ", OrgName, " (id: ", W, ")");

    /* lookup and focus on OrgBoard*/
    lookupArtifact("orgBoard", OrgBoard)[wid(W)];
    focus(OrgBoard);
    .print("sensing_agent: focused on OrgBoard ", OrgBoard);

    /* lookup and focus on GroupBoard for monitoring_team*/
    lookupArtifact("monitoring_team", GB)[artifact_id(OrgBoard)];
    focus(GB);
    .print("sensing_agent: focused on GroupBoard ", GB);

    /* adopt the temperature_reader role in the group*/
    adoptRole(temperature_reader)[artifact_id(GB)];
    .print("sensing_agent: adopted role temperature_reader in group monitoring_team").
/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }