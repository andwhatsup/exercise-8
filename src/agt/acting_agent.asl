/* acting_agent.asl */

/* Initial beliefs */
robot_td("https://raw.githubusercontent.com/Interactions-HSG/example-tds/main/tds/leubot1.ttl").
org_name("lab_monitoring_org").
group_name("monitoring_team").
sch_name("monitoring_scheme").

/* Initial goal */
!start.

/* Plan: greet on start */
@start_plan
+!start : true <-
    .print("acting_agent: ready").

/* Plan: handle available role announcements, join org, focus artifacts, and adopt the role */
@available_role_plan
+availableRole(Role, OrgName) : org_name(OrgName) <-
    .print("acting_agent: detected available role ", Role, " in org ", OrgName);
    // Join the organization workspace
    joinWorkspace(OrgName, WS);
    .print("acting_agent: joined workspace ", OrgName, " (id: ", WS, ")");

    // Focus on OrgBoard
    lookupArtifact("orgBoard", OrgBoard)[wid(WS)];
    focus(OrgBoard);
    .print("acting_agent: focused on OrgBoard ", OrgBoard);

    // Focus on monitoring_team GroupBoard
    lookupArtifact(GroupName, GB)[artifact_id(OrgBoard)];
    focus(GB);
    .print("acting_agent: focused on GroupBoard ", GB);

    // Adopt the available role in the group
    adoptRole(Role)[artifact_id(GB)];
    .print("acting_agent: adopted role ", Role, " in group ", GroupName).

/* Plan: manifest_temperature mission handler */
@manifest_temperature_plan
+!manifest_temperature : temperature(Celsius) & robot_td(Location) <-
    .print("acting_agent: manifesting temperature = ", Celsius);
    // Create converter artifact and convert the Celsius value
    makeArtifact("converter", "tools.Converter", [], Conv)[artifact_id(Conv)];
    convert(Celsius, -20.00, 20.00, 200.00, 830.00, Degrees)[artifact_id(Conv)];
    .print("acting_agent: converted to Degrees = ", Degrees);

    // Create and use the robotic arm ThingArtifact
    makeArtifact("leubot1", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Location, true], Leubot)[artifact_id(Conv)];
    invokeAction("https://ci.mines-stetienne.fr/kg/ontology#SetWristAngle", ["https://www.w3.org/2019/wot/json-schema#IntegerSchema"], [Degrees])[artifact_id(Leubot)].

/* Include templates and org reasoning rules */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-rules.asl") }
{ include("inc/skills.asl") }