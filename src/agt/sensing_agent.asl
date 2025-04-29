/* sensing_agent.asl */

/* Initial beliefs */
org_name("lab_monitoring_org").
group_name("monitoring_team").
sch_name("monitoring_scheme").

/* Initial goal */
!start.

/* Plan: greet and wait for org workspace availability */
@start_plan
+!start : true <-
    .print("sensing_agent: ready to detect new organizations").

/* Plan: react to new organization workspace, join, observe, reason and adopt relevant roles */
@workspace_available_plan
+workspaceAvailable(OrgName, _) : org_name(OrgName) <-
    .print("sensing_agent: detected workspace available ", OrgName);

    // Join the organization workspace
    joinWorkspace(OrgName, WS);
    .print("sensing_agent: joined workspace ", OrgName, " (id: ", WS, ")");

    // Lookup and focus on OrgBoard artifact
    lookupArtifact("orgBoard", OrgBoard);
    focus(OrgBoard);
    .print("sensing_agent: focused on OrgBoard ", OrgBoard);

    // Lookup and focus on GroupBoard for the monitoring_team
    lookupArtifact("monitoring_team", GB);
    focus(GB);
    .print("sensing_agent: focused on GroupBoard ", GB);

    // Reason on the organization specification to find relevant roles
    .print("sensing_agent: reasoning about relevant roles...");

    ?relevantRole(Role, "monitoring_team");
    .print("sensing_agent: inferred relevant role: ", Role);

    // Adopt each inferred relevant role in the group
    adoptRole(Role)[artifact_id(GB)];
    .print("sensing_agent: adopted role ", Role, " in group monitoring_team").

/* Plan: read_temperature goal handler */
@read_temperature_plan
+!read_temperature : true <-
    .print("sensing_agent: executing read_temperature");
    // Create and use a weather station artifact
    makeArtifact("weatherStation", "tools.WeatherStation", [], WSId);
    focus(WSId);
    readCurrentTemperature(47.42, 9.37, Celsius);
    .print("sensing_agent: temperature reading = ", Celsius);
    .broadcast(tell, temperature(Celsius)).

/* Include templates and rules */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-rules.asl") }
/* Rules for determining relevant roles */
relevantRole("sensor", "monitoring_team").

{ include("inc/skills.asl") }
