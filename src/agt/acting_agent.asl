/* acting_agent.asl */

/* Initial beliefs */
robot_td("https://raw.githubusercontent.com/Interactions-HSG/example-tds/main/tds/leubot1.ttl").
org_name("lab_monitoring_org").
group_name("monitoring_team").
sch_name("monitoring_scheme").

!start.  // kick off

/* Plan: greet on start */
@start_plan
+!start : true <-
    .print("Hello world").

/* Plan: react to availableRole, join org, focus, adopt role, commit mission */
@available_role_plan
+availableRole(Role, OrgName) : org_name(OrgName) & group_name(GroupName) <-
    .print("Role available: ", Role, " in organization ", OrgName);

    // join and focus on organization workspace
    joinWorkspace(OrgName, WS);
    .print("acting_agent: joined workspace ", OrgName, " (id: ", WS, ")");

    // focus on OrgBoard and GroupBoard
    lookupArtifact("orgBoard", OrgBoard)[wid(WS)];
    focus(OrgBoard);
    lookupArtifact(GroupName, GB)[wid(WS)];
    focus(GB);

    // adopt the role
    .print("Trying to adopt role ", Role, " in group ", GroupName);
    adoptRole(Role)[artifact_id(GB)];
    .print("acting_agent: adopted role ", Role, " in group ", GroupName);

    // obligations and trigger mission
    .print("I am obliged to commit to temperature_manifesting_mission on ", SchemeName);
    .print("I am obliged to achieve goal manifest_temperature on ", SchemeName);
    !manifest_temperature.

/* Plan: perform the manifest_temperature mission */
@manifest_temperature_plan
+!manifest_temperature : temperature(Celsius) & robot_td(Location) <-
    .print("I will manifest the temperature: ", Celsius);

    // convert Celsius to actuator degrees
    makeArtifact("converter", "tools.Converter", [], Conv)[wid(WS)];
    convert(Celsius, -20.00, 20.00, 200.00, 830.00, Degrees)[artifact_id(Conv)];
    .print("Temperature Manifesting (moving robotic arm to): ", Degrees);

    // invoke the robotic arm
    makeArtifact("leubot1", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Location, true], Leubot)[artifact_id(Conv)];
    invokeAction("https://ci.mines-stetienne.fr/kg/ontology#SetWristAngle", ["https://www.w3.org/2019/wot/json-schema#IntegerSchema"], [Degrees])[artifact_id(Leubot)].

/* Include boilerplate behavior */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-rules.asl") }
{ include("inc/skills.asl") }
