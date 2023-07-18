// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "../libraries/GEXLibrary.sol";
import "../interfaces/IGEXFactory.sol";
import "../interfaces/IGEXRouter01.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IWGLCH.sol";

contract GEXRouter02 is IGEXRouter01 {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WGLCH;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "GEXRouter: EXPIRED");
        _;
    }

    constructor(address _factory, address _WGLCH) public {
        factory = _factory;
        WGLCH = _WGLCH;
    }

    receive() external payable {
        assert(msg.sender == WGLCH); // only accept GLCH via fallback from the WGLCH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) private returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IGEXFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IGEXFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = GEXLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = GEXLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "GEXRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = GEXLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "GEXRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function _addLiquidity2(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) public view returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        // if (IGEXFactory(factory).getPair(tokenA, tokenB) == address(0)) {
        //     IGEXFactory(factory).createPair(tokenA, tokenB);
        // }
        (uint reserveA, uint reserveB) = GEXLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = GEXLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "GEXRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = GEXLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "GEXRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function getReverse(address tokenA, address tokenB) external view returns (uint reserveA, uint reserveB) {
        (reserveA, reserveB) = GEXLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );

    }

    function getQuote(uint amountADesired, uint reserveA, uint reserveB) external pure returns (uint amountBOptimal) {
                    amountBOptimal = GEXLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        override
        ensure(deadline)
        returns (uint amountA, uint amountB, uint liquidity)
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = GEXLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IGEXPair(pair).mint(to);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        override
        ensure(deadline)
        returns (uint amountToken, uint amountETH, uint liquidity)
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WGLCH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = GEXLibrary.pairFor(factory, token, WGLCH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWGLCH(WGLCH).deposit{value: amountETH}();
        assert(IWGLCH(WGLCH).transfer(pair, amountETH));
        liquidity = IGEXPair(pair).mint(to);
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
    }
    function addLiquidityETH2(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        // view
        ensure(deadline)
        returns (uint amountToken, uint amountETH, uint liquidity)
    {
        (amountToken, amountETH) = _addLiquidity2(
            token,
            WGLCH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );

        // address pair = GEXLibrary.pairFor(factory, token, WGLCH);
        // TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        // IWGLCH(WGLCH).deposit{value: amountETH}();
        // assert(IWGLCH(WGLCH).transfer(pair, amountETH));
        // liquidity = IGEXPair(pair).mint(to);
        // if (msg.value > amountETH)
        //     TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
    }
    function testDust(
    )
        external
        payable
    {
        // (amountToken, amountETH) = _addLiquidity2(
        //     token,
        //     WGLCH,
        //     amountTokenDesired,
        //     msg.value,
        //     amountTokenMin,
        //     amountETHMin
        // );

        // address pair = GEXLibrary.pairFor(factory, token, WGLCH);
        // TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        uint amountETH = msg.value - 1;
        IWGLCH(WGLCH).deposit{value: amountETH}();
        assert(IWGLCH(WGLCH).transfer(msg.sender, amountETH));
        TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
        // liquidity = IGEXPair(pair).mint(to);
        // if (msg.value > amountETH)
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = GEXLibrary.pairFor(factory, tokenA, tokenB);
        IGEXPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IGEXPair(pair).burn(to);
        (address token0, ) = GEXLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(amountA >= amountAMin, "GEXRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "GEXRouter: INSUFFICIENT_B_AMOUNT");
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        public
        override
        ensure(deadline)
        returns (uint amountToken, uint amountETH)
    {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WGLCH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWGLCH(WGLCH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint amountA, uint amountB) {
        address pair = GEXLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IGEXPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (uint amountToken, uint amountETH) {
        address pair = GEXLibrary.pairFor(factory, token, WGLCH);
        uint value = approveMax ? uint(-1) : liquidity;
        IGEXPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) private {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = GEXLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOut)
                : (amountOut, uint(0));
            address to = i < path.length - 2
                ? GEXLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IGEXPair(GEXLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {
        amounts = GEXLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "GEXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            GEXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {
        amounts = GEXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, "GEXRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            GEXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        payable
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WGLCH, "GEXRouter: INVALID_PATH");
        amounts = GEXLibrary.getAmountsOut(factory, msg.value, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "GEXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWGLCH(WGLCH).deposit{value: amounts[0]}();
        assert(
            IWGLCH(WGLCH).transfer(
                GEXLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WGLCH, "GEXRouter: INVALID_PATH");
        amounts = GEXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, "GEXRouter: EXCESSIVE_INPUT_AMOUNT");
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            GEXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWGLCH(WGLCH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override ensure(deadline) returns (uint[] memory amounts) {
        require(path[path.length - 1] == WGLCH, "GEXRouter: INVALID_PATH");
        amounts = GEXLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "GEXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            GEXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWGLCH(WGLCH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        payable
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WGLCH, "GEXRouter: INVALID_PATH");
        amounts = GEXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, "GEXRouter: EXCESSIVE_INPUT_AMOUNT");
        IWGLCH(WGLCH).deposit{value: amounts[0]}();
        assert(
            IWGLCH(WGLCH).transfer(
                GEXLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]); // refund dust eth, if any
    }

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) public pure override returns (uint amountB) {
        return GEXLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure override returns (uint amountOut) {
        return GEXLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure override returns (uint amountIn) {
        return GEXLibrary.getAmountOut(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view override returns (uint[] memory amounts) {
        return GEXLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view override returns (uint[] memory amounts) {
        return GEXLibrary.getAmountsIn(factory, amountOut, path);
    }
}
