// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.4;

/*
O contrato aqui presente norteia a aquisição de um carro duma concessionária qualquer que aceite que o comprador dê seu atual carro como forma de complementar o pagamento.
De todo modo, o valor integral do veículo vendido pela concessionária deve ser depositado num primeiro momento e apenas após a avaliação do veículo dado como pagamento em alguma oficina parceira que o valor será devolvido.
O contrato possui diversos dispositivos que, apesar de parecerem redundantes, servem para minimizar ao máximo a necessidade de tratativas além do próprio contrato.
Dentre os dispositivos que o contrato oferece, temos a possibilidade de:
a) definir etapas que sejam essenciais para que a solução do contrato, assim como a marcação de cumprimento, ou não, da etapa;
b) um estabelecimento da ordem cronológica do que vier a acontecer no contrato para que fique documentado junto ao contrato e o comprador possa checar a qualquer horário para saber o que ocorre;
c) uma espécie de tradutor do percentual da Tabela FIPE pelo qual a empresa tem interesse de comprar o carro entregue a ela;
d) saber quando a empresa dar o carro entregue por ele como comprado através do mapping ao final do contrato.
*/

contract compraEVendaDeCarroComDesconto {
    string public comprador;
    string public vendedor;
    string public carroASerComprado;
    string public carroASerDadoEmTroca;
    uint public valorDoCarroASerCompradoEmReais;
    address payable contaDaConcessionaria;

    constructor() {
        vendedor = "Guilherme Augusto Navarro Sobral Pagliarini de Almeida - LTDA";
        comprador = "Josefina Sobral Navarro";
        carroASerComprado = "Onix Premier 2 Turbo 2021";
        valorDoCarroASerCompradoEmReais = 95000;
        carroASerDadoEmTroca = "Agile LTZ 2014";
    }

    modifier somenteConcessionaria {
        require(msg.sender == contaDaConcessionaria, "Somente a concessionaria pode realizar essa operacao");
        _;
    }    

    struct etapasEssenciais {
        string etapaEssencial;
        bool feito;
    }

    etapasEssenciais[] public etapa;
    
    function definirEtapa(string memory _etapa) public somenteConcessionaria{
        etapa.push(etapasEssenciais(_etapa, false));
    }
    
    function verificarEtapa(uint _index)
    public
    view
    returns (string memory, bool){
       etapasEssenciais storage acao = etapa[_index];
       return (acao.etapaEssencial, acao.feito);
    } 
    
    function atualizarEtapa(uint _index, string memory _etapa) public somenteConcessionaria{
        etapasEssenciais storage acao = etapa[_index];
        acao.etapaEssencial = _etapa;
    }
    
    function marcarEtapaComoConcluida(uint _index) public somenteConcessionaria{
        etapasEssenciais storage acao = etapa[_index];
        acao.feito = !acao.feito;
    }
    
    function verificarPercentualPelaQualidade(uint categoriaQualidade)
    public 
    pure 
    // O valor integral do carro dado em troca é determinado por seu valor na Tabela FIPE à data da entrega do veículo para que seja realizada a avaliação.
    // A porcentagem do valor da Tabela FIPE a ser pago no veículo seguirá critérios avaliatórios próprios da concessionária.
    // Após o cálculo de valor percentual baseado na Tabela FIPE, a concessionária faria a conversão do preço de R$ para Ether no dia da entrega do veículo para avaliação.
    returns (uint percentualPelaQualidade) {
        if (categoriaQualidade == 5) {
            return 100;
        }
        // O veículo que for avaliado em categoria 5 de qualidade não apresenta qualquer defeito.
        if (categoriaQualidade == 4) {
            return 80;
        }
        // O veículo que for avaliado em categoria 4 de qualidade apresenta defeitos tão somente externos e de caráter estético.
        if (categoriaQualidade == 3) {
            return 65;
        }
        // O veículo que for avaliado em categoria 3 de qualidade apresenta defeitos externos tanto estéticos quanto ligados à utilidade do automóvel.
        if (categoriaQualidade == 2) {
            return 50;
        }
        // O veículo que for avaliado em categoria 2 de qualidade apresenta defeitos internos e é da mesma marca que a principal tratada pela concessionária, de modo que o acesso às peças será relativamente mais fácil.
        if (categoriaQualidade == 1) {
            return 40;
        }
        // O veículo que for avaliado em categoria 1 de qualidade apresenta defeitos internos e não é da mesma marca que a principal tratada pela concessionária, de modo que o acesso às peças será mais difícil.
    } 

    function calcularValorDoCarroEmTroca(uint precoDaTabelaFipe, uint percentualPelaQualidade)
    public
    pure
    returns(uint valorDoCarroEmTroca) {
        return precoDaTabelaFipe * percentualPelaQualidade / 100;
    }

    string[] public sumarioDosAtosPraticados;
    
    function inserirAtoPraticado(string memory atoPraticado) public somenteConcessionaria{
        sumarioDosAtosPraticados.push (atoPraticado);
    }
    
    function consultarAtosPraticados(uint256 ordemCronologica) public view returns (string memory) {
        return sumarioDosAtosPraticados[ordemCronologica];
    }

    mapping(address => uint) pagamentos;
    
    event deposito(address emissario, uint valor, uint saldo);
    event retirada(uint quantidade, uint saldo);
    event transferencia(address destinatario, uint quantidade, uint saldo);
    
    function depositar() public payable {
        emit deposito(msg.sender, msg.value, address(this).balance);
            if(msg.value < 1 ether) {
            // O valor aqui é meramente exemplificativo, a concessionária teria que fazer o cálculo para o valor exato do carro em Ether no dia que o contrato fosse ser assinado.
            revert();
        }
    }

    function retirar(uint _quantidade) public payable somenteConcessionaria {
        contaDaConcessionaria.transfer(_quantidade);
        emit retirada(_quantidade, address(this).balance);
    }
    
    function transfer(address payable _destinatario, uint _quantidade) public somenteConcessionaria {
        _destinatario.transfer(_quantidade);
        // Uma vez avaliado o carro submetido à avaliação, o valor é devolvido.
        emit transferencia(_destinatario, _quantidade, address(this).balance);
    }
    
    function verificarSaldo() public view returns (uint) {
        return address(this).balance;
    }
    
    mapping (string => string) public propriedadeDosVeiculos;
    
    function inserirPropriedadeDoVeiculo(string memory parte, string memory carro) public somenteConcessionaria{
        propriedadeDosVeiculos[carro] = parte; 
    }
    
    function retirarPropriedadeDoVeiculo(string memory carro) external somenteConcessionaria{
        delete propriedadeDosVeiculos[carro];
    }
    
    function consultarPropriedadeDoVeiculo(string memory carro) public view returns (string memory){
        return propriedadeDosVeiculos[carro];
    }
}
