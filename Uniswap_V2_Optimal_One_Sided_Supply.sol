//SPDX-License-Identifier: UNLICENSED

/*
    Author: Ankit Mishra
    Uniswap V2 Optimal One Sided Supply
    If the user has both of ETH and the other token in proportionate amount to the pool,
     then he/she can just directly supply them, obtaining maximum efficiency without facing any impermanent loss.

    But this is not always the case. Some users might not have the exact proportion of tokens,
     and even worse they might only have only ETH.

    In Uniswap, assuming the pool is at equilibrium,
     the total value of each asset in the pool should be equal. 
    So, to supply to the pool, we’d also need an equal value of the two assets too.

    A simple, natural solution: swap half of ETH to another asset in equal value!
        Step 1: The pool has 12,000 ETH + 520 WBTC. The user wants to supply 2,500 ETH.
        Step 2: The user swaps in 1,250 ETH and receives 48.92 WBTC (receives slightly less due to 0.3% swap fee).
         The pool now has 13,250 ETH + 471.08 WBTC.
        Step 3: The user supplies 1,250 ETH + 44.44 WBTC to the pool.
         The pool now has 15,000 ETH + 512.52 WBTC, but the user has 0 ETH + 4.48 WBTC remaining.

    There is a total of unutilized 4.48 WBTC remaining in the user's balance.
    
    So, what went wrong? ☠️
    Two major problems arise when swapping from one asset to another:

    Swap fee 💰 (0.3% for Uniswap) - With swap fee,
     the user receives slightly less amount of the swap out asset.
    The new reserve's asset ratio 📊 - The swap alters the reserve ratio,
     increasing the amount of supplied asset and decreasing the amount of the withdrawn asset.

    ****To solve above problem, we are using this contract.****

*/


pragma solidity ^0.8.0;

contract TestUniswapOptimalOneSidedSupply{
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function sqrt(uint y) private pure returns(uint z){
        if(y>3){
            z=y;
            uint x = y /2 +1;
            while (x < z){
                z = x;
                x = (y / x + x) /2;
            }
        } else if(y != 0){
            z =1;
        }
    }

    /*
        s = optimal swap amount
        r = amount of reserve for token a
        a = amount of token a the user currently has (not added to reserve yet)
        f = swap fee percent
        s = (sqrt(((2 - f)r)^2 + 4(1 - f)ar) - (2 - f)r) / (2(1 - f))
    */
    function getSwapAmount(uint r, uint a) public pure returns(uint){
        return (sqrt(r*(r * 3988009 + a * 3988009)) - r * 1997) /1994;
    }

    /* Optimal one-sided supply
        1. Swap optimal amount from token A to token B
        2. Add liquidity
    */

    function zap(address _tokenA, address _tokenB, uint _amountA) external{
        require(_tokenA == WETH || _tokenB == WETH, " not token weth");

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(pair).getReserves();

        uint swapAmount;
        if(IUniswapV2Pair(pair).token0() == _tokenA){
            // swap from token0 to token1
            swapAmount = getSwapAmount(reserve0, _amountA);
        } else {
            // swap from token1 to token0
            swapAmount = getSwapAmount(reserve1, _amountA);
        }

        _swap(_tokenA, _tokenB, swapAmount);
        _addLiquidity(_tokenA, _tokenB);
    }

    function _swap(address _from, address _to, uint _amount) internal {
        IERC20(_from).approve(ROUTER, _amount);

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;

        IUniswapV2Router(ROUTER).swapExactTokensForTokens(_amount, 1, path, address(this), block.timestamp);
    }

    function _addLiquidity(address _tokenA, address _tokenB) internal {
        uint balA = IERC20(_tokenA).balanceOf(address(this));
        uint balB = IERC20(_tokenB).balanceOf(address(this));
        IERC20(_tokenA).approve(ROUTER, balA);
        IERC20(_tokenB).approve(ROUTER, balB);

        IUniswapV2Router(ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            balA,
            balB,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}


interface IUniswapV2Router{
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns(uint amountA, uint amountB, uint liquidity);
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns(uint[] memory amounts);
}

interface IUniswapV2Factory{
    function getPair(address token0, address token1) external view returns(address);
}

interface IUniswapV2Pair {
    function token0() external view returns(address);

    function token1() external view returns(address);
    
    function getReserves() external view returns(
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

interface IERC20 {
    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient, uint amount) external returns(bool);
    
    function allowance(address owner, address spender) external returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns(bool);
}

