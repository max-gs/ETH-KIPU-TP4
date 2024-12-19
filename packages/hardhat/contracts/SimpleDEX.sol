/**
 *Submitted for verification at sepolia.scrollscan.com on 2024-11-25
*/

// SPDX-License-Identifier: MIT
// Compatible con OpenZeppelin Contracts ^5.0.0
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
//el anterior, https://sepolia.scrollscan.com/address/0x4d8b37253190a9c1413bd56572993fe6bf4cc26d#code,  me olvide de poner bien las address de los token 

// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: SimpleDEX.sol


// Compatible con OpenZeppelin Contracts ^5.0.0

//pragma solidity ^0.8.20;
// Versión mínima del compilador Solidity que se puede usar con este contrato

// Importa la interfaz de ERC20 para interactuar con tokens

contract SimpleDEX {
    // Definición del contrato

    IERC20 public tokenA;
    // Token A (TKA)
    IERC20 public tokenB;
    // Token B (TKB)
    mapping(address => uint256) public liquidity;
    // Mapeo para rastrear la liquidez de cada dirección

    event LiquidityAdded(address indexed owner, uint256 amountA, uint256 amountB);
    // Evento para cuando se añade liquidez
    event TokensSwapped(address indexed user, uint256 inputAmount, uint256 outputAmount, string direction);
    // Evento para cuando se realizan intercambios de tokens
    event LiquidityRemoved(address indexed owner, uint256 amountA, uint256 amountB);
    // Evento para cuando se retira liquidez

    constructor(address _tokenA, address _tokenB) {
        // Constructor para inicializar el contrato
        tokenA = IERC20(_tokenA);
        // Inicializa tokenA con la dirección proporcionada
        tokenB = IERC20(_tokenB);
        // Inicializa tokenB con la dirección proporcionada
    }

    function addLiquidity(uint256 amountA, uint256 amountB) external {
        // Función para añadir liquidez al pool
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer failed");
        // Verifica si la transferencia de tokenA es exitosa
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transfer failed");
        // Verifica si la transferencia de tokenB es exitosa
        liquidity[msg.sender] += (amountA + amountB);
        // Actualiza el mapeo de liquidez para el emisor
        emit LiquidityAdded(msg.sender, amountA, amountB);
        // Emite el evento de añadido de liquidez
    }

    function swapAforB(uint256 amountAIn) external {
        // Función para intercambiar TokenA por TokenB
        uint256 amountBOut = calculateOutput(amountAIn);
        // Calcula la cantidad de TokenB a recibir
        
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Transfer failed");
        // Verifica si la transferencia de TokenA es exitosa
        require(tokenB.transfer(msg.sender, amountBOut), "Swap failed");
        // Verifica si la transferencia de TokenB es exitosa

        emit TokensSwapped(msg.sender, amountAIn, amountBOut, "AforB");
        // Emite el evento de intercambio
    }

    function swapBforA(uint256 amountBIn) external {
        // Función para intercambiar TokenB por TokenA
        uint256 amountAOut = calculateOutput(amountBIn);
        // Calcula la cantidad de TokenA a recibir
        
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "Transfer failed");
        // Verifica si la transferencia de TokenB es exitosa
        require(tokenA.transfer(msg.sender, amountAOut), "Swap failed");
        // Verifica si la transferencia de TokenA es exitosa

        emit TokensSwapped(msg.sender, amountBIn, amountAOut, "BforA");
        // Emite el evento de intercambio
    }

    function removeLiquidity(uint256 amountA, uint256 amountB) external {
        // Función para retirar liquidez del pool
        require(liquidity[msg.sender] >= (amountA + amountB), "Insufficient liquidity");
        // Verifica si hay suficiente liquidez para la operación
        
        tokenA.transfer(msg.sender, amountA);
        // Transfiere TokenA al emisor
        tokenB.transfer(msg.sender, amountB);
        // Transfiere TokenB al emisor

        liquidity[msg.sender] -= (amountA + amountB);
        // Actualiza el mapeo de liquidez para el emisor
        emit LiquidityRemoved(msg.sender, amountA, amountB);
        // Emite el evento de retirado de liquidez
    }

    function getPrice(address _token) public view returns (uint256) {
        // Función para obtener el precio relativo de los tokens
        if (_token == address(tokenA)) {
            return tokenB.balanceOf(address(this)) / tokenA.balanceOf(address(this));
        } else if (_token == address(tokenB)) {
            return tokenA.balanceOf(address(this)) / tokenB.balanceOf(address(this));
        }
        revert("Invalid token");
        // Retorna un error si la dirección proporcionada no corresponde a ningún token válido
    }

    function calculateOutput(uint256 inputAmount) internal view returns (uint256) {
        // Función interna para calcular la cantidad de salida en un intercambio
        uint256 totalSupply = tokenA.balanceOf(address(this)) + tokenB.balanceOf(address(this));
        return (inputAmount * tokenB.balanceOf(address(this))) / totalSupply;
    }
}