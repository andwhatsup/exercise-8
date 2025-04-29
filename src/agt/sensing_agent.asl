/* sensing_agent.asl */

/* Initial beliefs */
org_name("lab_monitoring_org").
group_name("monitoring_team").
sch_name("monitoring_scheme").

!start.

/* Plan: greet */
@start_plan
+!start : true <-  
    .print("Hello world").

    
/* Plan: react to workspaceAvailable */
@workspace_available_plan
+workspaceAvailable(OrgName, _) : org_name(OrgName) <-
    .print("New organization workspace available: ", OrgName);
    
    // join & focus
    joinWorkspace(OrgName, WS);
    lookupArtifact("orgBoard", OrgBoard)[wid(WS)]; focus(OrgBoard);
    lookupArtifact("monitoring_team", GB)[wid(WS)]; focus(GB);

    // adopt
    .print("I can play the role: temperature_reader");
    .print("Trying to adopt role temperature_reader in group monitoring_team");
    adoptRole(temperature_reader)[artifact_id(GB)];
    
    // obligations
    .print("I am obliged to commit to temperature_reading_mission on monitoring_scheme");
    .print("I am obliged to achieve goal read_temperature on monitoring_scheme");
    !read_temperature.


/* Plan: read the temperature */
@read_temperature_plan
+!read_temperature : true <-  
    .print("I will read the temperature");
    makeArtifact("weatherStation", "tools.WeatherStation", [], WSId);
    focus(WSId);
    readCurrentTemperature(47.42, 9.37, Celsius);
    .print("Temperature Reading (Celsius): ", Celsius);
    .broadcast(tell, temperature(Celsius)).

/* Boilerplate */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-rules.asl") }
{ include("inc/skills.asl") }
