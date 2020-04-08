@0xdf85b05eff43f858;
# Cap'n Proto definitions for a subset of the Language Server Protocol, usable with capnp::JsonRpc.
# Currently this is the minimum subset needed for Ekam.

using Json = import "/capnp/compat/json.capnp";

$import "/capnp/c++.capnp".namespace("ekam::lsp");

interface LanguageServer {
  initialize @0 InitializeParams -> (capabilities :ServerCapabilities);

  struct InitializeParams {
    processId @0 :UInt32;  # Technically can be null.
    rootPath @1 :Text;
    rootUri @2 :DocumentUri;
    initializationOptions @3 :Json.Value;
    capabilities @4 :ClientCapabilities;
    trace @5 :Text = "off";
    workspaceFolders @6 :List(WorkspaceFolder);
  }

  shutdown @1 ();
  exit @2 () $Json.notification;

  didOpen @3 () $Json.notification $Json.name("textDocument/didOpen");
  didClose @4 () $Json.notification $Json.name("textDocument/didClose");
  # Ignoring these for now.

  didChange @5 (textDocument :TextDocumentIdentifier,
                # Actually VersionedTextDocumentIdentifier but we don't care.
                contentChanges :List(TextDocumentContentChangeEvent))
      $Json.notification $Json.name("textDocument/didChange");

  didSave @6 (textDocument :TextDocumentIdentifier)
      $Json.notification $Json.name("textDocument/didSave");
  # TODO(someday): Why is this never sent at present?
}

interface LanguageClient {
  publishDiagnostics @0 (uri :DocumentUri, diagnostics :List(Diagnostic)) $Json.notification
      $Json.name("textDocument/publishDiagnostics");
}

struct ClientCapabilities {
  # TODO(someday): workspace, textDocument, experimental
}

struct ServerCapabilities {
  textDocumentSync @0 :TextDocumentSyncOptions;

  # TODO(someday): more
}

struct TextDocumentSyncOptions {
  openClose @0 :Bool = false;
  change @1 :UInt8 = TextDocumentSyncKind.none;
  didSave @2 :Bool = false;
}

struct TextDocumentSyncKind {
  const none :UInt32 = 0;
  const full :UInt32 = 1;
  const incremental :UInt32 = 2;
}

struct WorkspaceFolder {
  uri @0 :Text;
  name @1 :Text;
}

using DocumentUri = Text;

struct Position {
  line @0 :UInt32;
  character @1 :UInt32;
}
struct Range {
  start @0 :Position;
  end @1 :Position;
}
struct Location {
  uri @0 :DocumentUri;
  range @1 :Range;
}

struct Diagnostic {
  range @0 :Range;
  severity @1 :UInt32;
  code @2 :Text;
  source @3 :Text;
  message @4 :Text;
  relatedInformation @5 :List(RelatedInformation);

  struct RelatedInformation {
    location @0 :Location;
    message @1 :Text;
  }

  const severityError :UInt32 = 1;
  const severityWarning :UInt32 = 2;
  const severityInformation :UInt32 = 3;
  const severityHint :UInt64 = 4;
}

struct Command {
  title @0 :Text;
  command @1 :Text;
  arguments @2 :List(Json.Value);
}

struct TextDocumentContentChangeEvent {
  range @0 :Range;
  text @1 :Text;
}

struct TextDocumentIdentifier {
  uri @0 :DocumentUri;
}
