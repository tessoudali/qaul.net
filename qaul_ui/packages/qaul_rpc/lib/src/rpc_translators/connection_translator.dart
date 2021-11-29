part of 'abstract_rpc_module_translator.dart';

class ConnectionTranslator extends RpcModuleTranslator {
  @override
  Modules get type => Modules.CONNECTIONS;

  @override
  Future<RpcTranslatorResponse?> decodeMessageBytes(List<int> data) async {
    final message = Connections.fromBuffer(data);
    switch (message.whichMessage()) {
      case Connections_Message.internetNodesList:
        // TODO: evaluate message info field, show message if error?
        final nodes = message
            .ensureInternetNodesList()
            .nodes
            .map((e) => InternetNode(e.address))
            .toList();
        return RpcTranslatorResponse(Modules.CONNECTIONS, nodes);
      default:
        return super.decodeMessageBytes(data);
    }
  }
}
