# ChatGPT and Claude integrations

## Goal

Allow ChatGPT and Claude to inspect TEa.G3 projects and request supported editing operations through a secure, typed tool interface.

## Shared tool surface

The first tool set should be intentionally small:

- `get_capabilities`: list actual engine features and version.
- `list_projects`: list projects visible to the authenticated user.
- `get_project`: return project metadata and edit decision list.
- `create_edit_plan`: create a proposed edit plan from a text brief and selected asset IDs.
- `validate_edit_plan`: validate ranges, references, durations, and supported operations.
- `start_render`: start a render only after explicit user approval.
- `get_render_status`: report queued/running/failed/completed state and verified output metadata.

The tool server must authenticate every request, scope access to the user's projects, validate all arguments, and record an audit event for changes.

## ChatGPT

Implement through a supported ChatGPT app/connector or MCP-compatible integration surface available to the target account and deployment. Publish the tool manifest and setup instructions only after the server is reachable over HTTPS and authentication is tested.

A repository skill file alone does not create a ChatGPT extension or automatically connect ordinary ChatGPT chats to the user's projects.

## Claude

Provide:
- an MCP server exposing the shared typed tools;
- the existing Claude Code skill for workflow guidance;
- setup instructions for connecting the MCP server.

A skill is guidance; MCP tools provide actual authenticated operations.

## Confirmation and privacy

- Read-only tools may run after authentication and authorization.
- Changes to an edit plan must be visible to the user.
- Starting a render requires explicit approval.
- Deleting assets/projects or overwriting outputs requires separate confirmation.
- Media content is not sent to a model unless the user explicitly chooses that operation and sees what will be shared.

## Current status

These are integration specifications. No production MCP server, ChatGPT app, or Claude MCP endpoint is deployed by this document.
