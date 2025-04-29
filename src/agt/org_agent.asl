/* org_agent.asl */

/* Initial beliefs */
org_name("lab_monitoring_org").      // organization id and workspace name
group_name("monitoring_team").      // group id
sch_name("monitoring_scheme").      // scheme id

!start.  // kick off initialization

/* Plan: initialize organization and start periodic invitations */
@start_plan
+!start : org_name(OrgName) & group_name(GroupName) & sch_name(SchemeName) <-
    .print("Hello World");

    // create and join workspace
    createWorkspace(OrgName);
    joinWorkspace(OrgName, WS);
    .print("Workspace '", OrgName, "' created, id: ", WS);

    // create and focus OrgBoard
    makeArtifact("orgBoard", "ora4mas.nopl.OrgBoard", ["src/org/org-spec.xml"], OrgBoard)[wid(WS)];
    focus(OrgBoard);
    .print("OrgBoard created and focused: ", OrgBoard);

    // create and focus GroupBoard
    createGroup(GroupName, GroupName, GroupBoard)[artifact_id(OrgBoard)];
    focus(GroupBoard);
    .print("GroupBoard created and focused: ", GroupBoard);

    // create and focus SchemeBoard
    createScheme(SchemeName, SchemeName, SchemeBoard)[artifact_id(OrgBoard)];
    focus(SchemeBoard);
    .print("SchemeBoard created and focused: ", SchemeBoard);

    // broadcast availability and announce waiting
    .broadcast(tell, workspaceAvailable(OrgName, WS));
    .print("New organization workspace available: ", OrgName);
    .print("Waiting for group ", GroupName, " to become well-formed");
    !startInvitations.

/* Plan: when group is well-formed, assign scheme */
@formation_ok_plan
+formationStatus(ok)[artifact_id(GroupBoard)] : org_name(OrgName) & group_name(GroupName) <-
    .print("Group ", GroupName, " is well-formed.");
    addScheme(SchemeName)[artifact_id(GroupBoard)];
    .print("Assigned scheme ", SchemeName, " to group ", GroupName, "").

/* Log when any agent plays a role */
@play_plan
+play(Ag, Role, GroupId) : true <-
    .print("Agent ", Ag, " adopted the role ", Role, " in group ", GroupId).

/* Plan: start invitation loop */
@invite_missing_roles
+!startInvitations : true <-
    .print("org_agent: starting periodic invitations");
    !invite.

/* Plan: invite missing roles, sleep, repeat */
@invite
+!invite : true <-
    ?roleNeedsPlayers(Role)[artifact_id(OrgBoard)];
    .broadcast(tell, availableRole(Role, OrgName));
    .print("org_agent: invited role ", Role);
    .wait(15000);
    !invite.

-!invite : true <-
    .wait(15000);
    !invite.

/* Includes */
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-rules.asl") }