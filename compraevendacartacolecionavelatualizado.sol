// SPDX-License-Identifier: CC-BY-4.0
pragma solidity ^0.8.4;

contract CompraEVendaCartaColecionavel {
    string public comprador;
    string public vendedor;
    string public cartaColecionavel;
// As edicoes sao Alfa (a primeira de todas as edicoes do jogo e a mais cara), Beta (a sequencia para suprir os estoques) e Unlimited (uma ultima impressao do conteudo original).
// Essas tres edicoes sao de uma lista de edicoes protegidas de reimpressoes, tornando as cartas limitadas e, portanto, aumentando seu valor.
// As qualidades sao nm (praticamente perfeita), sp (levemente gasta), mp (moderadamente gasta), hp (altamente gasta) e d (danificada).
    string[] public edicoesPelaOrdem = ["Alfa", "Beta", "Unlimited"];
    
    constructor() {
        comprador = "Guilherme";
        vendedor = "Josefina";
        cartaColecionavel = "Black Lotus";
    }
    
    function obtemNomeComprador() public view returns (string memory) {
        return comprador;
    }
    
    function obtemNomeVendedor() public view returns (string memory) {
        return vendedor;
    }
    
    function obtemNomeCartaColecionavel() public view returns (string memory) {
        return cartaColecionavel;    
    }    
    
    mapping (string => string) public edicoesDaCartaColecionavel;
    
    function inserirEdicaoPorCartaColecionavel(string memory nomeDaCartaColecionavel, string memory edicaoDaCartaColecionavel) public {
        edicoesDaCartaColecionavel[edicaoDaCartaColecionavel] = nomeDaCartaColecionavel; 
    }
    
        function consultarEdicaoPorCarta(string memory edicaoDaCartaColecionavel) public view returns (string memory){
        return edicoesDaCartaColecionavel[edicaoDaCartaColecionavel];
    }
    
    function push(string memory) public {
        edicoesPelaOrdem.push();
    }
    
    function verificarValorPelaEdicao(uint categoriaEdicao)
    public 
    pure 
    returns (uint precoInteiroDaEdicao) {
        if (categoriaEdicao == 1) {
            return 500000;
        }
        if (categoriaEdicao == 2) {
            return 200000;
        }
        if (categoriaEdicao == 3) {
            return 50000;
        }
    }
    
    function verificarValorPelaQualidade(uint categoriaQualidade)
    public 
    pure 
    returns (uint percentualPelaQualidade) {
        if (categoriaQualidade == 5) {
            return 100;
        }
        if (categoriaQualidade == 4) {
            return 80;
        }
        if (categoriaQualidade == 3) {
            return 65;
        }
        if (categoriaQualidade == 2) {
            return 50;
        }
        if (categoriaQualidade == 1) {
            return 40;
        }
    } 
    
    function calcularValor(uint precoInteiroDaEdicao, uint percentualPelaQualidade)
    public
    pure
    returns(uint valorDoColecionavel) {
        return precoInteiroDaEdicao * percentualPelaQualidade / 100;
    }
    
    function verificarInteresseDeCompra(uint oferta, uint valorDoColecionavel)
    public
    pure
    returns (bool) {
        if (oferta <= valorDoColecionavel) {
            return true;
        } else {
            return false;
        }
    }
}
