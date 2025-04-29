// organization agent

/* Initial beliefs and rules */
org_name("lab_monitoring_org"). // the agent beliefs that it can manage organizations with the id "lab_monitoring_org"
group_name("monitoring_team"). // the agent beliefs that it can manage groups with the id "monitoring_team"
sch_name("monitoring_scheme"). // the agent beliefs that it can manage schemes with the id "monitoring_scheme"

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : org_name(OrgName) & group_name(GroupName) & sch_name(SchemeName) <-
  .print("Initializing organization: ", OrgName);
  createWorkspace(OrgName);                     // create a new Moise workspace
  joinWorkspace(OrgName, WS);                   // join it and obtain workspace id WS
  .print("Workspace '", OrgName, "' created, id: ", WS);

  // Create and focus on the OrgBoard artifact managing the spec
  makeArtifact("orgBoard", "ora4mas.nopl.OrgBoard", ["src/org/org-spec.xml"], OrgBoard)[wid(WS)];
  focus(OrgBoard);
  .print("OrgBoard artifact created and focused: ", OrgBoard);

  // Create and focus on the GroupBoard for the monitoring team
  createGroup(GroupName, GroupName, GroupBoard)[artifact_id(OrgBoard)];
  focus(GroupBoard);
  .print("GroupBoard artifact created and focused: ", GroupBoard);

  // Create and focus on the SchemeBoard for the monitoring scheme
  createScheme(SchemeName, SchemeName, SchemeBoard)[artifact_id(OrgBoard)];
  focus(SchemeBoard);
  .print("SchemeBoard artifact created and focused: ", SchemeBoard);

  // Notify all agents that the organization workspace is available
  .broadcast(tell, workspaceAvailable(OrgName, WS));
  .print("Broadcasted new workspace availability: ", OrgName).
  /* 
 * Plan for reacting to the addition of the test-goal ?formationStatus(ok)
 * Triggering event: addition of goal ?formationStatus(ok)
 * Context: the agent beliefs that there exists a group G whose formation status is being tested
 * Body: if the belief formationStatus(ok)[artifact_id(G)] is not already in the agents belief base
 * the agent waits until the belief is added in the belief base
*/
@formation_ok_plan
+formationStatus(ok)[artifact_id(GroupBoard)] : org_name(OrgName) & group_name(GroupName) <-
  .print("Group '", GroupName, "' is now well-formed.");
  addScheme(SchemeName)[artifact_id(GroupBoard)];   // assign the scheme to the group
  .print("Assigned scheme '", SchemeName, "' to group '", GroupName, "'.").
/* 
 * Plan for reacting to the addition of the belief play(Ag, Role, GroupId)
 * Triggering event: addition of belief play(Ag, Role, GroupId)
 * Context: true (the plan is always applicable)
 * Body: the agent announces that it observed that agent Ag adopted role Role in the group GroupId.
 * The belief is added when a Group Board artifact (https://moise.sourceforge.net/doc/api/ora4mas/nopl/GroupBoard.html)
 * emmits an observable event play(Ag, Role, GroupId)
*/
@play_plan
+play(Ag, Role, GroupId) : true <-
  .print("Agent ", Ag, " adopted the role ", Role, " in group ", GroupId).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }