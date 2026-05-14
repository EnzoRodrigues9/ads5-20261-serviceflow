import 'ordens_servico.dart';

class OrdemServicoRepository {
  static final List<OrdemServico> listaOS = [];

  static int _id = 0;

  static int gerarId() {
    _id++;
    return _id;
  }
}